/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_By_City_v2_bak]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_By_City_v2_bak] AS
BEGIN
--DECLARE @start_date DATE
--	,@end_date DATE
--SET @start_date = '2021-01-01'
--SET @end_date = '2021-07-01';
truncate table DW_OMS.RPT_Sales_By_City
;WITH sales
AS (
	SELECT sales.sales_order_number
		,sales.purchase_order_number
		,sales.store_code
		,sales.province
		,sales.city
		,sales.place_time
		,sales.item_sku_code
		,sales.source
		,sum(sales.item_quantity) item_quantity
		,sum(sales.item_apportion_amount) item_apportion_amount
		,sum(refund.item_qauntity) AS refund_quantity
		,sum(sales.sap_amount) AS sap_amount
		,sum(refund.item_apportion_amount) AS refund_amount
	FROM DWD.Fact_Sales_Order sales
	LEFT JOIN DWD.Fact_Refund_Order refund ON sales.sales_order_number = refund.sales_order_number
		AND sales.item_sku_code = refund.item_sku_code
	--where sales.sales_order_number='1374981616176762'
	--WHERE sales.place_time >= @start_date
	--	AND sales.place_time < @end_date
	GROUP BY sales.sales_order_number
		,sales.purchase_order_number
		,sales.store_code
		,sales.province
		,sales.city
		,sales.place_time
		,sales.item_sku_code
		,sales.source
	)
	,order_address
AS (
	SELECT *
	FROM (
		SELECT t.sales_order_number
			,t1.city
			,t1.province
			,t1.create_time
			,row_number() OVER (
				PARTITION BY t.sales_order_number
				,t1.city
				,t1.province ORDER BY t1.create_time DESC
				) AS rownum
		FROM stg_oms.Sales_Order t
		LEFT JOIN stg_oms.Sales_Order_Address t1 ON t.sales_order_sys_id = t1.sales_order_sys_id
		--WHERE t.payment_time >= @start_date
		--	AND t.payment_time < @end_date
		GROUP BY t.sales_order_number
			,t1.city
			,t1.province
			,t1.create_time
		) TEMP
	WHERE rownum = 1
	)
	
	insert into  DW_OMS.RPT_Sales_By_City
SELECT format(TEMP.place_time, 'yyyy-MM') AS month
	,city_mapping.province
	,case when temp.source='POS' then store.sap_city else city_mapping.city end as city
	,city_mapping.Region
	,TEMP.store_code
	,sum(CASE 
			WHEN temp.source = 'POS'
				THEN item_apportion_amount
			ELSE 0
			END) AS retail_sales
	,sum(CASE 
			WHEN temp.source = 'OMS'
				THEN sap_amount
			ELSE 0
			END) AS eb_sap_sales
	,sum(CASE 
			WHEN temp.source = 'POS' and c.store_code is not null
				THEN item_apportion_amount
			ELSE 0
			END) AS retail_comp_sales
	,--- need to change
	sum(CASE 
			WHEN temp.source = 'OMS'
				THEN item_apportion_amount
			ELSE 0
			END) AS eb_oms_sales
	,current_timestamp AS insert_tiemstamp

FROM (
	SELECT
		--sales.sales_order_number,sales.purchase_order_number,sales.place_time,sales.item_sku_code,
		sales.source
		,sales.store_code
		,sales.place_time
		,CASE 
			WHEN (
					sales.province IS NOT NULL
					AND sales.province != N'其他'
					)
				THEN sales.province
			ELSE order_address.province
			END AS province
		,CASE 
			WHEN (
					sales.city IS NOT NULL
					AND sales.city != N'其他'
					)
				THEN sales.city
			ELSE order_address.city
			END AS city
		,count(DISTINCT sales.store_code) AS store_cnt
		,SUM(CAST(ISNULL(item_quantity, 0) AS INT) - CAST(ISNULL(refund_quantity, 0) AS INT)) AS quantity
		,SUM(CAST(ISNULL(item_apportion_amount, 0.0) AS FLOAT) - CAST(ISNULL(refund_amount, 0.0) AS FLOAT)) AS item_apportion_amount
		,SUM(CAST(ISNULL(sap_amount, 0.0) AS FLOAT) - CAST(ISNULL(refund_amount, 0.0) AS FLOAT)) AS sap_amount
	FROM sales
	LEFT JOIN order_address ON sales.sales_order_number = order_address.sales_order_number
	GROUP BY
		--sales.sales_order_number,sales.purchase_order_number,sales.place_time,sales.item_sku_code,
		--sales.store_code,
		sales.source
		,sales.store_code
		,sales.place_time
		,CASE 
			WHEN (
					sales.province IS NOT NULL
					AND sales.province != N'其他'
					)
				THEN sales.province
			ELSE order_address.province
			END
		,CASE 
			WHEN (
					sales.city IS NOT NULL
					AND sales.city != N'其他'
					)
				THEN sales.city
			ELSE order_address.city
			END
	) TEMP
LEFT JOIN STG_OMS.DIM_Province_Region_Mapping city_mapping ON city_mapping.city_name = TEMP.city
left join STG_OMS.DIM_Store_Code_Mapping c
on temp.store_code = c.store_code
left join [DWD].[DIM_Store] store on temp.store_code=store.store_code
GROUP BY format(TEMP.place_time, 'yyyy-MM')
	,city_mapping.province
	,case when  temp.source='POS' then store.sap_city else city_mapping.city end 
	,city_mapping.Region
	,TEMP.store_code
;
END

GO
