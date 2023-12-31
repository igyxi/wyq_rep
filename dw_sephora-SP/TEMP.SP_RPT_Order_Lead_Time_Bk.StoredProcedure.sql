/****** Object:  StoredProcedure [TEMP].[SP_RPT_Order_Lead_Time_Bk]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Order_Lead_Time_Bk] AS
BEGIN
	--1.目前报表以place_date为颗粒度，但type=8的订单是货到付款，现在逻辑中把货到付款给排除了；
	--2.部分订单显示已经签收，但没有签收时间，占比大概1/7，查下来是换货订单，不知道还有没有其他原因，现在逻辑中把签收时间为空的排除了。
	--3.大仓收单时间无法获取
	--4. shipping_time/logistics_shipping_time的实际意义待确认
	-- shipping_time 是否为实际仓库发货时间
	-- logistics_shipping_time 是物流发货时间？还是揽收时间
	--5. 数据中存在shipping_time比logistics_shipping_time早，也存在shipping_time比logistics_shipping_tim
	TRUNCATE TABLE DW_OMS.RPT_Order_Lead_Time;
	INSERT INTO DW_OMS.RPT_Order_Lead_Time
		SELECT
			a.place_date
		   ,a.store_cd
		   ,SUM(CAST(DATEDIFF(s, order_time, payment_time) AS BIGINT)) AS [order_to_payment_totaltime]
		   ,SUM(CAST(DATEDIFF(s, payment_time, shipping_time) AS BIGINT)) AS [payment_to_shipping_totaltime]
		   ,SUM(CAST(DATEDIFF(s, shipping_time, logistics_shipping_time) AS BIGINT)) AS [shipping_to_logistic_shipping_totaltime]
		   ,SUM(CAST(DATEDIFF(s, logistics_shipping_time, sign_time) AS BIGINT)) AS [logistic_shipping_to_sign_totaltime]
		   ,SUM(CAST(DATEDIFF(s, payment_time, CAST(SUBSTRING([WMS大仓收单时间],1,23) AS DATETIME)) AS BIGINT)) AS [shipping_to_WMS_recieve_totaltime]
		   ,SUM(CAST(DATEDIFF(s, CAST(SUBSTRING([WMS大仓收单时间],1,23) AS DATETIME), logistics_shipping_time) AS BIGINT)) AS [WMS_recieve_to_logistic_shipping_totaltime]
		   ,SUM(CAST(DATEDIFF(s, order_time, sign_time) AS BIGINT)) AS [totaltime]
		   ,COUNT(DISTINCT a.purchase_order_number) AS [totalorder]
		   ,SUM(CAST(DATEDIFF(s, order_time, payment_time) AS BIGINT)) / COUNT(DISTINCT a.purchase_order_number) AS avg_period_of_order_to_payment
		   ,SUM(CAST(DATEDIFF(s, payment_time, shipping_time) AS BIGINT)) / COUNT(DISTINCT a.purchase_order_number) AS avg_period_of_payment_to_shipping
		   ,SUM(CAST(DATEDIFF(s, shipping_time, logistics_shipping_time) AS BIGINT)) / COUNT(DISTINCT a.purchase_order_number) AS avg_period_of_shipping_to_logistic_shipping
		   ,SUM(CAST(DATEDIFF(s, logistics_shipping_time, sign_time) AS BIGINT)) / COUNT(DISTINCT a.purchase_order_number) AS avg_period_of_logistic_shipping_to_sign
		   ,SUM(CAST(DATEDIFF(s, order_time, sign_time) AS BIGINT)) / COUNT(DISTINCT a.purchase_order_number) AS avg_period_of_total_leadtime
		   ,current_timestamp AS insert_timestamp
		FROM (SELECT DISTINCT
				purchase_order_number
			   ,CASE
					WHEN CHARINDEX('TMALL', store_cd) > 0 THEN channel_cd
					ELSE store_cd
				END AS store_cd
			   ,place_date
			   ,order_time
			   ,payment_time
			   ,shipping_time
			   ,sign_time
			FROM DW_OMS.RPT_Sales_Order_SKU_Level
			WHERE split_type_cd <> 'SPLIT_ORIGIN'
			AND internal_status_cd = 'SIGNED'
			AND type_cd <> 2
			AND store_cd <> 'GWP001'
			AND so_type_cd <> 8
			AND is_placed_flag = 1
			AND basic_status_cd <> 'DELETED'
			AND shipping_time IS NOT NULL
			AND sign_time IS NOT NULL) a
		INNER JOIN (SELECT DISTINCT
				purchase_order_number
			   ,logistics_shipping_time
			FROM DW_OMS.DWS_Purchase_Order
			WHERE split_type <> 'SPLIT_ORIGIN'
			AND type_cd <> 2
			AND store_cd <> 'GWP001'
			AND internal_status = 'SIGNED'
			AND basic_status <> 'DELETED'
			AND type_cd <> 8
			AND logistics_shipping_time IS NOT NULL) b
			ON a.purchase_order_number = b.purchase_order_number
			LEFT JOIN [MANUAL_WMS].[WMS_Order_Detail] c
			ON a.purchase_order_number = c.[EB Order] COLLATE SQL_Latin1_General_CP1_CI_AS
			AND ISDATE([WMS大仓收单时间]) =1
		GROUP BY a.place_date
				,a.store_cd
	;
	UPDATE STATISTICS DW_OMS.RPT_Order_Lead_Time;
END
GO
