/****** Object:  StoredProcedure [DW_Common].[SP_FACT_ORDER]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Common].[SP_FACT_ORDER] AS
 BEGIN
--    DECLARE @Date DATE
--	DECLARE @Month NVARCHAR(6)
--	DECLARE @Start_Date NVARCHAR(10)
--	DECLARE @End_Date NVARCHAR(10)
--	DECLARE @POS_Start_Date NVARCHAR(10)
--	DECLARE @POS_End_Date NVARCHAR(10)
--	DECLARE @load_Time DATETIME
--	SET @load_Time=GETDATE()
--	SET @Date= CASE WHEN  @Day ='' THEN GETDATE()-1 ELSE CAST(@Day as date) END
--	------月份
--	SET @Month= CONVERT(NVARCHAR(6),DATEADD(MONTH, DATEDIFF(MONTH, 0, cast(@Date as datetime)), 0),112)
--	------当月第一天
--	SET @Start_date= CONVERT(NVARCHAR(8),DATEADD(MONTH, DATEDIFF(MONTH, 0, cast(@Date as datetime)), 0),112)
--	------当月最后一天
--	SET @End_date= CONVERT(NVARCHAR(8),DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, 1,@Date)), 0),112)
--	------上月第一天
--	SET @POS_Start_Date=  CONVERT(NVARCHAR(10),DATEADD(MONTH, DATEDIFF(MONTH, 0, cast(@Date as datetime)-30), 0),112)
--	------一年后日期，因为OMS 到 SAP有跨月，把这个时间范围放宽，可以刷新历史数据
--	SET @POS_End_Date=   CONVERT(NVARCHAR(10),DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, 1, cast(@Date as datetime)+365)), -1),112)
--	--SELECT @Start_date,@End_date,@POS_Start_Date,@POS_End_Date
--select top 1* from [DW_Common].[FACT_ORDER]
DELETE FROM [DW_Common].[FACT_ORDER] --WHERE MONTH = @Month
INSERT INTO  [DW_Common].[FACT_ORDER] 
SELECT 
       source
	   ,TLOG.szBarcodeComplete 
	   ,'' as purchase_order_number
	   ,'' AS INVOICE_ID
	   ,TLOG.POS_Date 
	   ,TLOG.ARTICLE_szPOSItemID
	   ,TLOG.Hdr_lTaCreatedRetailStoreID 
	   ,'' as EB_channel_code
	   ,'' AS SUPER_ID
	   ,'' as szEmplName
	   ,1 AS IS_PLACED_FLAG
	   ,1 AS IS_VALID_FLAG
	   ,1 AS POS_SYNC_STATUS
	   ,'' AS TYPE_CODE
	   ,'' AS SO_INTERNAL_STATUS_CD
	   ,'' AS PO_INTERNAL_STATUS_CD
	   ,SUM(TLOG.dTaQty) AS source_QTY
       ,SUM(TLOG.Pos_Amount) AS source_AMT  
	   ,SAP.SAP_COMBINE_KEY 
	   ,SAP.Ticket_Date
	   ,SAP.Store_Code
       ,SUM(ISNULL(SAP.SAP_QTY,0)) AS SAP_QTY
       ,SUM(ISNULL(SAP.SAP_AMOUNT,0)) AS SAP_AMT
	   ,CRM.invc_no	   
	   ,CRM.account_number
	   ,SUM(ISNULL(CRM.qtys,0)) AS CRM_QTY
       ,SUM(ISNULL(CRM.sales,0)) AS CRM_AMT
	   ,SUM(TLOG.dTaQty)-SUM(ISNULL(SAP.SAP_QTY,0)) AS GAP_QTY_source_Vs_SAP
	   ,SUM(TLOG.Pos_Amount) - SUM(ISNULL(SAP.SAP_AMOUNT,0)) AS GAP_AMT_source_Vs_SAP
	   ,SUM(TLOG.dTaQty) -SUM(ISNULL(CRM.qtys,0)) AS GAP_QTY_source_Vs_CRM
       ,SUM(TLOG.Pos_Amount)-SUM(ISNULL(CRM.sales,0)) AS GAP_AMT_source_Vs_CRM
	   ,GETDATE() AS INSERT_TIMESTAMP
  FROM  (
		 SELECT 
		       'TLOG'AS source 
			   ,SUBSTRING(POS.szBarcodeComplete,17,8) AS POS_Date----,LEFT(Hdr_szTaCreatedDate,8) AS POS_Date
		       --,pos.szEmplName as szEmplName
			   ,POS.szBarcodeComplete
			   ,POS.ARTICLE_szPOSItemID
			   ,POS.Hdr_lTaCreatedRetailStoreID
			   --,SUM (CAST(ISNULL(POS.dTaQty,0.0) AS float)+CAST(ISNULL(POS_RETURN.dTaQty,0.0) AS float))  AS dTaQty
			   --,SUM(CAST(ISNULL(POS.dTaTotal,0.0) AS float)+CAST(ISNULL(POS.dTaTotalDiscounted,0.0) AS float)+CAST(ISNULL(POS_RETURN.dTaTotal,0.0) AS float)+CAST(ISNULL(POS_RETURN.dTaDiscount,0.0) AS float)) AS Pos_Amount 
			   ,SUM (CAST(ISNULL(POS.dTaQty,0.0) AS float))  AS dTaQty
			   ,SUM(CAST(ISNULL(POS.dTaTotal,0.0) AS float)+CAST(ISNULL(POS.dTaTotalDiscounted,0.0) AS float)) AS Pos_Amount 
		FROM [ODS_POS].[TLOG_ART_SALE] POS
			--LEFT JOIN [ODS_POS].[TLOG_ART_RETURN] POS_RETURN
			--ON POS.szBarcodeComplete=POS_RETURN.szBarcodeComplete
			--AND POS.ARTICLE_szPOSItemID=POS_RETURN.ARTICLE_szPOSItemID
			--AND POS.Hdr_lTaCreatedRetailStoreID=POS_RETURN.Hdr_lTaCreatedRetailStoreID
	    ----WHERE [Hdr_szTaCreatedDate] >=@Start_date AND [Hdr_szTaCreatedDate] <@End_date
		WHERE SUBSTRING(POS.szBarcodeComplete,17,8)>='20100101'--@Start_date 
		--AND SUBSTRING(POS.szBarcodeComplete,17,8)<@End_date		
		GROUP BY SUBSTRING(POS.szBarcodeComplete,17,8)
		         ,POS.szBarcodeComplete
				-- ,isnull(pos.szEmplName,POS_RETURN.szEmplName) 
				-- ,pos.szEmplName
				 ,POS.ARTICLE_szPOSItemID
				 ,POS.Hdr_lTaCreatedRetailStoreID
        ) TLOG
  LEFT JOIN 
        (
    	 SELECT  '66'+CAST(a.Store_Code AS NVARCHAR)+CAST (RIGHT( a.till_number,3) AS NVARCHAR)+CAST(RIGHT(a.Transaction_Number,7) AS NVARCHAR)+CAST( a.Ticket_Date AS NVARCHAR)+  CASE WHEN LEN(a.ticket_hour)=3 THEN '0'+CAST(a.ticket_hour AS NVARCHAR) ELSE CAST(ticket_hour AS NVARCHAR) END AS sales_order_number,
		'' as purchase_order_number,
		a.store_code,
		'' province,
		b.city,
		a.ticket_date,
		material_code,
		'SAP' as Source,
		sum(Quantity) as item_quantity,
		sum(Sales_VAT) as item_apportion_amount,
		0 as refund_quantity,
		sum(Sales_VAT) as sap_amount,
		0 as refund_amount
		FROM [ODS_SAP].[Sales_Ticket] a
		  join ods_sap.dim_store b
		  on a.store_code=b.store_code and b.Country_Code='CN'
		  where 1=1
		 -- and store_code='6160'
		  and ticket_date>='20220501' 
		  and ticket_date<'20220601' 
		  and Sales_Area not like '%eStore%'
		  group by 
		  '66'+CAST(a.Store_Code AS NVARCHAR)+CAST (RIGHT( a.till_number,3) AS NVARCHAR)+CAST(RIGHT(a.Transaction_Number,7) AS NVARCHAR)+CAST( a.Ticket_Date AS NVARCHAR)+  CASE WHEN LEN(a.ticket_hour)=3 THEN '0'+CAST(a.ticket_hour AS NVARCHAR) ELSE CAST(ticket_hour AS NVARCHAR) END, 
		a.store_code,
		b.city,
		a.ticket_date,
		a.material_code
        ) SAP
   ON LEFT(TLOG.szBarcodeComplete,28)=SAP.SAP_COMBINE_KEY
   AND TLOG.ARTICLE_szPOSItemID=SAP.Material_Code
   AND TLOG.Hdr_lTaCreatedRetailStoreID=SAP.Store_Code
	----WHERE --ARTICLE_szPOSItemID='549366' AND
	----szBarcodeComplete='666245001008065920211115212421'
  LEFT JOIN 
      (
    	 SELECT dProd.sku_code
		        ,trans.invc_no
				,dStore.store_code
				,trans.account_id
				,DIM_ACCOUNT.account_number
				,SUM(CAST(ISNULL(trans.qtys,0.0) AS float)) AS qtys
				,SUM(CAST(ISNULL(trans.sales,0.0) AS float)) AS sales
            FROM [ODS_CRM].[FactTrans] trans 
            LEFT JOIN  [ODS_CRM].[DimProduct] dProd 
                ON trans.product_id=dProd.product_id 
			LEFT JOIN  [ODS_CRM].[DimStore] dStore
			    ON trans.store_id=dStore.store_id
			LEFT JOIN ods_crm.dimaccount DIM_ACCOUNT
			    ON trans.account_id=DIM_ACCOUNT.account_id
				where CAST(ISNULL(trans.qtys,0.0) AS float)>=0
            --WHERE trans.trans_time>=@POS_Start_Date 
			--AND trans.trans_time<@POS_End_Date
			GROUP BY dProd.sku_code
			         ,trans.invc_no
					 ,dStore.store_code
					 ,trans.account_id
				     ,DIM_ACCOUNT.account_number
        ) CRM
   ON TLOG.szBarcodeComplete='66'+CRM.invc_no 
   AND TLOG.ARTICLE_szPOSItemID=CRM.sku_code
   AND TLOG.Hdr_lTaCreatedRetailStoreID=CRM.store_code
GROUP BY 
        source
	   ,TLOG.szBarcodeComplete 
	   ,TLOG.POS_Date 
	   ,TLOG.ARTICLE_szPOSItemID
	   ,TLOG.Hdr_lTaCreatedRetailStoreID 
	  -- ,TLOG.szEmplName 
	   ,SAP.SAP_COMBINE_KEY 
	   ,SAP.Ticket_Date
	   ,SAP.Store_Code
	   ,CRM.invc_no	   
	   ,CRM.account_number
----HAVING SUM(TLOG.dTaQty)-SUM(ISNULL(SAP.SAP_QTY,0))<>0  OR SAP.SAP_COMBINE_KEY IS NULL OR SUM(TLOG.dTaQty) -SUM(ISNULL(CRM.qtys,0))<>0 OR CRM.invc_no IS NULL 
----OR ABS(SUM(TLOG.Pos_Amount) - SUM(ISNULL(SAP.SAP_AMOUNT,0))) >=0.1  OR ABS(SUM(TLOG.Pos_Amount)-SUM(ISNULL(CRM.sales,0))) >=0.1
------ORDER BY 1,2
INSERT INTO  [DW_Common].[FACT_ORDER] 
SELECT 
	   source 
	   ,EB.sales_order_number collate Chinese_PRC_CI_AS
	   ,EB.purchase_order_number
	   ,EB.invoice_id 
	   ,EB.EB_Date collate Chinese_PRC_CI_AS
	   ,EB.SKU_CODE collate Chinese_PRC_CI_AS 
	   ,coalesce(sap.store_code, crm.store_code,EB.store_cd collate Chinese_PRC_CI_AS)  as store_code
	   ,EB.channel_cd collate Chinese_PRC_CI_AS
	   ,EB.super_id
	   ,''as szEmplName
	   ,EB.is_placed_flag
	   ,EB.is_valid_flag
	   ,EB.pos_sync_status 
	   ,EB.type_cd 
	   ,EB.so_internal_status_cd
	   ,EB.internal_status_cd 
	   ,SUM(EB.EB_QTY  ) AS source_QTY
       ,SUM(EB.EB_AMOUNT ) AS source_AMT  
	   ,SAP.SAP_COMBINE_KEY 
	   ,SAP.Ticket_Date
	   ,SAP.Store_Code
       ,SUM(ISNULL(SAP.SAP_QTY  ,0)) AS SAP_QTY
       ,SUM(ISNULL(SAP.SAP_AMOUNT  ,0)) AS SAP_AMT
	   ,CRM.invc_no 
	   ,CRM.account_id AS account_id
	   ,SUM(ISNULL(CRM.qtys ,0)) AS CRM_QTY
       ,SUM(ISNULL(CRM.sales  ,0)) AS CRM_AMT
       ,SUM(EB.EB_QTY  )-SUM(ISNULL(SAP.SAP_QTY,0)) AS GAP_QTY_source_Vs_SAP
	   ,SUM(EB.EB_AMOUNT ) - SUM(ISNULL(SAP.SAP_AMOUNT,0)) AS GAP_AMT_source_Vs_SAP
	   ,SUM(EB.EB_QTY ) -SUM(ISNULL(CRM.qtys,0)) AS GAP_QTY_source_Vs_CRM
       ,SUM(EB.EB_AMOUNT  )-SUM(ISNULL(CRM.sales,0)) AS GAP_AMT_source_Vs_CRM
	   ,GETDATE() AS Insert_timestamp
  FROM  (
		SELECT 'OMS' AS source 
		       ,CONVERT(NVARCHAR(10),RPT_EB.Place_date,112) AS EB_Date
			   ,RPT_EB.sales_order_number
	           ,RPT_EB.purchase_order_number
			   ,RPT_EB.member_card
			   ,RPT_EB.item_sku_cd AS SKU_CODE
			   ,RPT_EB.store_cd
			   ,RPT_EB.channel_cd
			   ,RPT_EB.so_internal_status_cd
			   ,RPT_EB.internal_status_cd
			   ,RPT_EB.is_placed_flag
			   ,purchase_order.is_valid_flag
			   ,MAP.pos_sync_status
			   ,RPT_EB.type_cd
			   ,MAP.invoice_id
			   ,RPT_EB.super_id
			   ,SUM(RPT_EB.item_quantity) AS EB_QTY
			   ,SUM(RPT_EB.item_apportion_amount) AS EB_AMOUNT
        FROM [DW_OMS].[RPT_Sales_Order_SKU_Level] RPT_EB
		LEFT JOIN [STG_OMS].[Purchase_To_SAP] MAP ON RPT_EB.Purchase_order_number=MAP.Purchase_order_number
		LEFT JOIN DW_OMS.DWS_PURCHASE_ORDER purchase_order  
		ON RPT_EB.purchase_order_number=purchase_order.purchase_order_number
		AND RPT_EB.item_sku_cd=purchase_order.item_sku_cd
		WHERE RPT_EB.Place_date>='20200101'--@Start_date 
		--AND RPT_EB.Place_date<@End_date
		AND split_type_cd <>'SPLIT_ORIGIN'
		--AND purchase_order.is_valid_flag=1
		--AND RPT_EB.store_cd <>'GWP001'
        GROUP BY CONVERT(NVARCHAR(10),RPT_EB.Place_date,112)
			   ,RPT_EB.sales_order_number
	           ,RPT_EB.purchase_order_number
			   ,RPT_EB.member_card
			   ,RPT_EB.item_sku_cd 
			   ,RPT_EB.store_cd
			   ,RPT_EB.channel_cd
			   ,RPT_EB.so_internal_status_cd
			   ,RPT_EB.internal_status_cd
			   ,RPT_EB.is_placed_flag
			   ,purchase_order.is_valid_flag
			   ,MAP.pos_sync_status
			   ,RPT_EB.type_cd
			   ,MAP.invoice_id
			   ,RPT_EB.super_id
        ) EB
  LEFT JOIN 
        (
    	  SELECT Ticket_Date
		        ,Material_Code
		        ,Store_Code
		        ,substring(Transaction_Number,patindex('%[1-9]%',Transaction_Number),len(Transaction_Number)-1) AS SAP_COMBINE_KEY
				,SUM(CAST(ISNULL(Quantity,0.0) AS float)) AS SAP_QTY
				,SUM(CAST(ISNULL(Sales_VAT,0.0) AS float)) AS SAP_AMOUNT
            FROM [ODS_SAP].[Sales_Ticket]
            WHERE --Ticket_Date>=@POS_Start_Date AND
			-- Ticket_Date<@POS_End_Date AND
			 ISNULL(Quantity,0.0)>=0 --正向订单
			GROUP BY Material_Code
			         ,Store_Code
			         ,substring(Transaction_Number,patindex('%[1-9]%',Transaction_Number),len(Transaction_Number)-1)
					 ,Ticket_Date
        ) SAP
   ON EB.invoice_id collate Chinese_PRC_CI_AS =SAP.SAP_COMBINE_KEY
   AND EB.SKU_CODE collate Chinese_PRC_CI_AS =SAP.Material_Code
  -- AND EB.store_cd collate Chinese_PRC_CI_AS =SAP.Store_Code
	----WHERE --ARTICLE_szPOSItemID='549366' AND
	----szBarcodeComplete='666245001008065920211115212421'
  LEFT JOIN 
      (
    	 SELECT dProd.sku_code
		        ,trans.invc_no
				,dStore.store_code
				,account_id
				,SUM(CAST(ISNULL(trans.qtys,0.0) AS float)) AS qtys
				,SUM(CAST(ISNULL(trans.sales,0.0) AS float)) AS sales
            FROM [ODS_CRM].[FactTrans] trans 
            LEFT JOIN  [ODS_CRM].[DimProduct] dProd 
                ON trans.product_id=dProd.product_id 
			LEFT JOIN  [ODS_CRM].[DimStore] dStore
			    ON trans.store_id=dStore.store_id
            WHERE --trans.trans_time>=@POS_Start_Date  AND
			-- trans.trans_time<@POS_End_Date AND
			 CAST(ISNULL(trans.qtys,0.0) AS float)>=0 --正向单
			GROUP BY dProd.sku_code
			         ,trans.invc_no
					 ,dStore.store_code
					 ,account_id
        ) CRM
   ON EB.purchase_order_number collate Chinese_PRC_CI_AS=CRM.invc_no 
    AND EB.SKU_CODE collate Chinese_PRC_CI_AS =CRM.sku_code
--WHERE so_internal_status_cd<>'CANCELLED'--非取消订单
--      AND so_internal_status_cd<>'REJECTED'--非拒收订单
--	    AND EB.is_placed_flag=1 --已成功付款，预售付尾款
--	    AND pos_sync_status=1 --成功同步到SAP
--      AND TYPE_CD<>'2'--换货
GROUP BY  source 
	   ,EB.sales_order_number collate Chinese_PRC_CI_AS
	   ,EB.purchase_order_number
	   ,EB.invoice_id 
	   ,EB.EB_Date collate Chinese_PRC_CI_AS
	   ,EB.SKU_CODE collate Chinese_PRC_CI_AS 
	   ,coalesce(sap.store_code, crm.store_code,EB.store_cd collate Chinese_PRC_CI_AS)
	   ,EB.channel_cd collate Chinese_PRC_CI_AS
	   ,EB.super_id
	   ,EB.is_placed_flag
	   ,EB.is_valid_flag
	   ,EB.pos_sync_status 
	   ,EB.type_cd 
	   ,EB.so_internal_status_cd
	   ,EB.internal_status_cd 
	   ,SAP.SAP_COMBINE_KEY 
	   ,SAP.Ticket_Date
	   ,SAP.Store_Code
	   ,CRM.invc_no 
	   ,CRM.account_id 
----HAVING 
-----------数据匹配不成功的记录
----SUM(EB.EB_QTY)-SUM(ISNULL(SAP.SAP_QTY,0))<>0 -- EB SAP QTY
----OR SAP.SAP_COMBINE_KEY IS NULL --Missed in SAP
----OR SUM(EB.EB_QTY) -SUM(ISNULL(CRM.qtys,0))<>0  --EB CRM QTY
----OR CRM.invc_no IS NULL  --Missed in CRM
----OR ABS(SUM(EB.EB_AMOUNT) - SUM(ISNULL(SAP.SAP_AMOUNT,0))) >=0.1 --EB SAP Amount
----OR ABS(SUM(EB.EB_AMOUNT)-SUM(ISNULL(CRM.sales,0))) >=0.1--EB CRM Amount
--------------数据匹配成功的记录
------------SUM(EB.EB_QTY) -SUM(ISNULL(CRM.qtys,0))=0
------ORDER BY 1,2
 END
GO
