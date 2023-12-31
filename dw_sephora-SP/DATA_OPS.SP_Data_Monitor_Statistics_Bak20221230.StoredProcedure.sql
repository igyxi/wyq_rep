/****** Object:  StoredProcedure [DATA_OPS].[SP_Data_Monitor_Statistics_Bak20221230]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_Data_Monitor_Statistics_Bak20221230] @start_date [VARCHAR](10) AS
BEGIN
	DECLARE
		@end_date AS NVARCHAR(20),
		@pos_date AS NVARCHAR(8)

	--set  @start_date = convert(nvarchar(10),dateadd(hh,8,getutcdate()-2),120)
	SET @end_date=CONVERT(NVARCHAR(10),DATEADD(DAY,1,@start_date),120)
	SET @pos_date=CONVERT(NVARCHAR(8),CAST(@start_date AS DATE),112)

	--select  @start_date,@end_date,@pos_date
	WHILE @start_date<=CONVERT(NVARCHAR(10),DATEADD(HH,8,GETUTCDATE()-1),120)
	BEGIN
		--set @start_date=dateadd(day,1,@start_date)

		DELETE FROM [DATA_OPS].[Data_Monitor_Statistics] WHERE [date_id]=@pos_date and Category not in ('ADW_New','ADW')

		--select * from [DATA_OPS].[Data_Monitor_Statistics]
		INSERT INTO [DATA_OPS].[Data_Monitor_Statistics]
		--SELECT
		--	CONVERT(NVARCHAR(8),create_time,112) AS [date_id]
		--	,store_code 
		--	,channel_id AS 'Category'
		--	,'[ODS_OrderHub].[Store_Order_Statistics]' AS Source
		--	,SUM(sales_amount-refund_amount) AS [Sales_VAT]
		--	,DATEADD(HH,8,GETUTCDATE()) AS Insert_timestamp
		--FROM [ODS_OrderHub].[Store_Order_Statistics] 
		--WHERE create_time >=@start_date AND create_time<@end_date AND dt=@start_date
		--	--and synt_flag=1
		--GROUP BY CONVERT( NVARCHAR(8),create_time,112),store_code,channel_id

		SELECT
			CONVERT(NVARCHAR(8),complete_date,112) AS [date_id]
			,shop_code as store_code 
			,'O2O' AS 'Category'
			,'[STG_New_OMS].[OMNI_Order_Statistics]' AS Source
			,SUM(sales_amount-isnull(refund_amount,0)-isnull(return_amount,0)) AS [Sales_VAT]
			,DATEADD(HH,8,GETUTCDATE()) AS Insert_timestamp
		FROM [STG_New_OMS].[OMNI_Order_Statistics]
		WHERE complete_date >=@start_date AND complete_date<@end_date --AND dt=@start_date
			--and synt_flag=1
		GROUP BY CONVERT( NVARCHAR(8),complete_date,112),shop_code

		--union all
		--SELECT a.date_key
		--,a.[Store_Code]
		--,'ADW' as channel_id
		--,'dw_sap.fact_sales' as Source
		--,sum(a.[Sales_VAT]) as [Sales_VAT]--41720880.94
		--,getdate()
		--FROM dw_sap.fact_sales a
		--inner Join
		--  (
		--  select  * from [ODS_SAP].[Dim_Store]
		--  where Country_Code='CN' 
		--  ) b
		--on a.Store_Code=b.Store_Code
		--where a.date_key=@pos_date  
		----  and a.store_code not  in('6223','6010'
		----,'6403','6425','6426','6438','6465')
		--group by a.date_key,a.[Store_Code]
		UNION all
		SELECT
			--b.szbusinessdate,
			substring(a.szBarcodeComplete,17,8) as szbusinessdate,
			a.[Hdr_lTaCreatedRetailStoreID]
			,'POS'
			,'[ODS_POS].[TLOG_ART_SALE]'
			,SUM(CAST(ISNULL([dTaTotal],0.0) AS FLOAT) + CAST(ISNULL([dTaTotalDiscounted],0.0) AS FLOAT)) AS [SalesAmount]
			,DATEADD(HH,8,GETUTCDATE())
		FROM [ODS_POS].[TLOG_ART_SALE] a 
		LEFT JOIN [ODS_POS].[TLOG_HEADER] b ON a.[szBarcodeComplete] = b.[szBarcodeComplete]
		WHERE 
			--b.szbusinessdate=@pos_date AND a.[Hdr_szTaCreatedDate] < FORMAT(CAST(@end_date AS DATE),'yyyyMMdd') + '000000'
			
			substring(a.szBarcodeComplete,17,8)=@pos_date
			
			--  (b.szbusinessdate='20220215'
			--  or (a.[Hdr_szTaCreatedDate] >=  format(CAST(CONVERT(nvarchar(10), DATEADD([hour], 8, GETUTCDATE()) - 3, 120) AS date),'yyyyMMdd') + '000000'
			--AND a.[Hdr_szTaCreatedDate] <  format(CAST(CONVERT(nvarchar(10), DATEADD([hour], 8, GETUTCDATE())-2, 120) AS date),'yyyyMMdd') + '000000'))
			and b.szTatype in ('SA','RT')
			--and  a.[Hdr_lTaCreatedRetailStoreID]=6300
		GROUP BY a.[Hdr_lTaCreatedRetailStoreID],
		substring(a.szBarcodeComplete,17,8)
		--b.szbusinessdate
		UNION ALL
		SELECT 
			--b.szbusinessdate
			substring(a.szBarcodeComplete,17,8) as szbusinessdate
			,a.[Hdr_lTaCreatedRetailStoreID] collate Chinese_PRC_CS_AI_WS
			,'POS'
			,'[ODS_POS].[TLOG_ART_RETURN]'
			,SUM(CAST(ISNULL([dTaTotal],0.0) AS FLOAT) + CAST(ISNULL([dTaDiscount],0.0) AS FLOAT))
			,DATEADD(HH,8,GETUTCDATE())
		FROM [ODS_POS].[TLOG_ART_RETURN] a 
		LEFT JOIN [ODS_POS].[TLOG_HEADER] b ON a.[szBarcodeComplete] = b.[szBarcodeComplete]
		WHERE 1 = 1
			--AND b.szbusinessdate=@pos_date AND a.[Hdr_szTaCreatedDate] < FORMAT(CAST(@end_date AS date),'yyyyMMdd') + '000000'
			and substring(a.szBarcodeComplete,17,8)=@pos_date
			--  and (b.szbusinessdate='20220215'
			--  or (a.[Hdr_szTaCreatedDate] >=  format(CAST(CONVERT(nvarchar(10), DATEADD([hour], 8, GETUTCDATE()) - 3, 120) AS date),'yyyyMMdd') + '000000'
			--AND a.[Hdr_szTaCreatedDate] <  format(CAST(CONVERT(nvarchar(10), DATEADD([hour], 8, GETUTCDATE())-2, 120) AS date),'yyyyMMdd') + '000000'))
			AND b.szTatype in ('SA','RT')
			--and a.[Hdr_lTaCreatedRetailStoreID]=6300
		GROUP BY a.[Hdr_lTaCreatedRetailStoreID],
		substring(a.szBarcodeComplete,17,8)
		--b.szbusinessdate

		SET @start_date=CONVERT(NVARCHAR(10),DATEADD(DAY,1,@start_date),120)
		SET @end_date=CONVERT(NVARCHAR(10),DATEADD(DAY,1,@start_date),120)
		SET @pos_date= CONVERT(NVARCHAR(8),CAST(@start_date AS DATE),112)
		--select  @start_date,@end_date,@pos_date
	END
END
GO
