/****** Object:  StoredProcedure [TEMP].[SP_RPT_Pending_Orders_BK]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Pending_Orders_BK] @dt [VARCHAR](10) AS
BEGIN
	--[DW_OMS].[SP_RPT_Pending_Orders] '2021-10-18'
	DELETE FROM [DW_OMS].[RPT_Pending_Orders]
	WHERE [dt] = @dt;
	INSERT INTO [DW_OMS].[RPT_Pending_Orders]
		SELECT
			sku.store_cd                    --店铺
		   ,sku.channel_cd                 --渠道
		   ,sku.sales_order_number         --平台订单
		   ,sku.purchase_order_number      --SAP订单号
		   ,CASE
				WHEN sku.type_cd IS NULL THEN sku.so_type_cd
				ELSE sku.type_cd
			END AS type_cd -- SO订单类型
			--    ,po.type_cd AS type_cd				--PO订单类型
		   ,sku.order_time                 --下单时间
		   ,sku.payment_time               -- 支付时间
		   ,sku.place_time                 --有效支付时间
		   ,CASE
				WHEN ISNULL(sku.type_cd, sku.so_type_cd) = 3 AND
					sku.payment_status_cd = 1 THEN payment_time
				ELSE NULL
			END AS balance_payment_time     -- 尾款支付时间
		   ,CASE
				WHEN ISNULL(sku.type_cd, sku.so_type_cd) = 7 THEN sku.presale_shipping_time
				ELSE sku.shipping_time
			END AS shipping_time           -- 预计发货时间
		   ,sku.po_sys_create_time         --SAP创建时间
		   ,sku.split_type_cd              --拆分类型 
		   ,case when sku.purchase_order_number is not null then item_apportion_amount
                 when sku.purchase_order_number is null then payed_amount end  as payed_amount             --支付总额
		   ,sku.internal_status_cd         --订单状态
		   ,sku.item_name
			--,ISNULL(sp.product_name_cn,sp.product_name)                --Article
			--,sp.product_id                  --产品名称
			--,sp.sku_cd
		   ,sku.item_sku_cd
		   ,sku.order_def_ware_house       -- 发货仓库  
		   ,CASE
				WHEN sku.internal_status_cd = 'PENDING' AND
					sku.so_type_cd = 3 AND
					sku.presale_shipping_time <= @dt THEN N'预售_缺库存'
				WHEN so_type_cd = 7 AND
					sku.payment_status_cd = 2 THEN N'定金预售_等待尾款'
				WHEN sku.internal_status_cd = 'WAIT_SAPPROCESS' AND
					t.apply_type != 'MODIFY_ADDRESS_APPLY' AND
					t.apply_type IS NOT NULL THEN N'等待SAP处理_取消'
				WHEN sku.internal_status_cd = 'WAIT_SAPPROCESS' AND
					t.apply_type = 'MODIFY_ADDRESS_APPLY' THEN N'等待SAP处理_更改'
				WHEN sku.internal_status_cd = 'WAIT_SAPPROCESS' AND
					t.apply_type != 'MODIFY_ADDRESS_APPLY' AND
					t.apply_type IS NULL AND
					DATEADD(HOUR, 24, sku.po_sys_create_time) >= @dt THEN N'等待SAP处理_未关闭'
				WHEN sku.internal_status_cd = 'WAIT_SAPPROCESS' AND
					t.apply_type != 'MODIFY_ADDRESS_APPLY' AND
					t.apply_type IS NULL AND
					@dt > DATEADD(HOUR, 24, sku.po_sys_create_time) THEN N'等待SAP处理_未关闭_超时'
				WHEN sku.internal_status_cd = 'EXCEPTION' THEN N'异常'
				WHEN sku.internal_status_cd = 'CANCELLED' AND
					sku.basic_status_cd != 'FINISH' THEN N'其他'
				WHEN sku.internal_status_cd IN ('WAIT_SEND_SAP', 'PARTAIL_CANCEL', 'CANT_CONTACTED', 'WAIT_TMALLPROCESS', 'WAIT_JDPROCESS', 'WAIT_WAREHOUSE_PROCESS', 'SPLITED', 'WAIT_ROUTE_ORDER') THEN N'其他'
			END COLLATE Chinese_PRC_CS_AI_WS AS pending_reason
		   ,DATEDIFF(HOUR, CASE
				WHEN so_type_cd = 7 AND
					sku.payment_status_cd = 1 THEN sku.presale_shipping_time
				ELSE sku.place_time
			END, DATEADD(DAY, 0, CAST(FORMAT(GETDATE(), 'yyyy-MM-dd') AS DATETIME))) AS [delivery_pending_days]
		   ,@dt AS dt
		FROM DW_OMS.RPT_Sales_Order_SKU_Level sku
		-- LEFT JOIN STG_OMS.Purchase_Order po
		-- ON sku.purchase_order_number = po.purchase_order_number
		LEFT JOIN 
        (select distinct purchase_order_number,apply_type from STG_OMS.Purchase_Order_EXT) t
			ON sku.purchase_order_number = t.purchase_order_number
		--LEFT JOIN DW_Product.DWS_SKU_Profile sp
		--	ON sku.item_sku_cd = sp.sku_cd
		WHERE sku.store_cd != 'GWP001'
		AND (sku.is_placed_flag = 1
		OR so_type_cd = 7)
        and isnull(split_type_cd,'')<>'SPLIT_ORIGIN'
        and isnull(type_cd,0)<>2
		AND (
		(
		sku.purchase_order_number IS NOT NULL
		AND sku.type_cd != 2
		AND sku.split_type_cd != 'SPLIT_ORIGIN'
		AND sku.internal_status_cd IN ('PENDING', 'WAIT_SAPPROCESS', 'EXCEPTION')
		AND (sku.basic_status_cd != 'DELETED'
		OR sku.internal_status_cd = 'PARTAIL_CANCEL')
		-- and DATEDIFF(DAY,sku.place_date,cast(ISNULL(sku.shipping_time, dateadd(day,1,@dt)) as date)) < 3
		)
		OR (
		sku.purchase_order_number IS NULL
		AND sku.so_internal_status_cd IN ('EXCEPTION', 'WAIT_JD_CONFIRM', 'PENDING')
		AND sku.so_basic_status_cd != 'DELETED'
		)
		);
END
GO
