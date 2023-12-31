/****** Object:  StoredProcedure [DATA_OPS].[SP_Data_Monitor_SmartBA_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_Data_Monitor_SmartBA_Detail] @dt [VARCHAR](10) AS
BEGIN

-- DECLARE @dt NVARCHAR(10) = '2022-04-03'
-- EXEC [DATA_OPS].[SP_Data_Monitor_SmartBA_Detail] '2022-04-03'

declare @month nvarchar(6);
set @month = left(replace(@dt, '-', ''), 6);

delete from [DATA_OPS].[Data_Monitor_SmartBA_Detail]
where dt = @dt
-- where source not like 'EB%'
--     and left(date_id, 6) = @month

insert into [DATA_OPS].[Data_Monitor_SmartBA_Detail]
-- ===== DW.OMS =====
-- ===== sales =====
SELECT convert(NVARCHAR(8), a.shipping_time, 112) AS dateid
	,'DW_OMS.RPT_Sales_Order_SKU_Level' as source
	,'OMS Sales' as kpi
	,a.sales_order_number
	,a.purchase_order_number
	,a.shipping_time
	,sum(item_apportion_amount) AS sales_amount
	,CURRENT_TIMESTAMP AS [insert_timestamp]
	,@dt as dt
FROM DW_OMS.RPT_Sales_Order_SKU_Level A
LEFT JOIN (
	SELECT DISTINCT sales_order_number
		,smartba_flag
		,product_total
		,payment_status
	FROM STG_OMS.Sales_Order
	) B ON a.sales_order_number = b.sales_order_number
WHERE b.smartba_flag = 1
	AND a.type_cd <> 2
	AND a.split_type_cd <> 'SPLIT_ORIGIN'
	AND b.payment_status = 1
	AND a.shipping_time IS NOT NULL
	AND left(convert(NVARCHAR(10), shipping_time, 112), 6) = @month
	-- convert(NVARCHAR(8), dateadd(day, - 1, getdate()), 112)
GROUP BY convert(NVARCHAR(8), a.shipping_time, 112)
	,a.sales_order_number
	,a.purchase_order_number
	,a.shipping_time

union ALL
-- ===== OMS_Order_Refund Refund =====
SELECT 
	convert(NVARCHAR(8), a.create_time, 112) AS dateid
	,'STG_OMS.OMS_Order_Refund' as source
	,'OMS Refund' as kpi
	,a.oms_order_code
	,a.refund_no
	,a.update_time
	,-1 * sum(a.refund_sum) as oms_refund_sum
	,CURRENT_TIMESTAMP AS [insert_timestamp]
	,@dt as dt
from [STG_OMS].[OMS_Order_Refund] A
	LEFT JOIN (
		SELECT sales_order_number,
			smartba_flag,
			payment_status
		FROM STG_OMS.Sales_Order
	) B ON a.oms_order_code = b.sales_order_number
WHERE b.smartba_flag = 1
	AND left(convert(NVARCHAR(8), a.create_time, 112), 6) = @month
group by convert(NVARCHAR(8), a.create_time, 112)
	,a.oms_order_code
	,a.refund_no
	,a.update_time

union all
-- ===== T_Order_Package.smartba =====
-- ===== sales =====
-- SELECT 
-- '202204'
-- ,count(distinct sales_order_number) as so_cnt
-- ,count(distinct purchase_order_number) as po_cnt
-- ,sum(sales_amount) as sales_amount
-- from(
SELECT 
	convert(NVARCHAR(8), shipping_time, 112) AS dateid
	,'STG_SmartBA.T_Order_Package' as source
	,'SmartBA Sales' as kpi
	,order_code as sales_order_number
	,po_code as purchase_order_number
	,shipping_time
	,SUM(po_amount) AS sales_amount
	,CURRENT_TIMESTAMP AS [insert_timestamp]
	,@dt as dt
FROM stg_smartba.t_order_package 
WHERE left(convert(NVARCHAR(8), shipping_time, 112), 6) = @month
-- convert(NVARCHAR(8), dateadd(day, - 1, getdate()), 112)
group by 
	convert(NVARCHAR(8), shipping_time, 112)
	,order_code
	,po_code
	,shipping_time
-- ) a

-- =======T_Order_Package end ============

union all
-- ===== T_Order_Refund Refund =====
SELECT 	
	convert(NVARCHAR(8), create_time, 112) AS dateid
	,'STG_SmartBA.T_Order_Refund' as source
	,'SmartBA Refund' as kpi
	,order_code as sales_order_number
	,return_code as purchase_order_number
	,create_time
	,-1 * SUM(amount) AS sales_amount
	,CURRENT_TIMESTAMP AS [insert_timestamp]
	,@dt as dt
FROM STG_SmartBA.T_Order_Refund
WHERE left(convert(NVARCHAR(8), create_time, 112), 6) = @month
-- convert(NVARCHAR(8), dateadd(day, - 1, getdate()), 112)
group by convert(NVARCHAR(8), create_time, 112)
	,order_code
	,return_code
	,create_time
-- ======= T_Order_Refund end ===========

union all
-- ===== RPT.smartba =====
-- ===== sales =====
-- SELECT 
-- '202204'
-- ,count(distinct sales_order_number) as so_cnt
-- ,count(distinct purchase_order_number) as po_cnt
-- ,sum(sales_amount) as sales_amount
-- from(
SELECT 
	convert(NVARCHAR(8), shipping_time, 112) AS dateid
	,'DW_SmartBA.RPT_SmartBA_Orders' as source
	,'SmartBA Sales' as kpi
	,sales_order_number
	,purchase_order_number
	,shipping_time
	,SUM(item_apportion_amount) AS sales_amount
	,CURRENT_TIMESTAMP AS [insert_timestamp]
	,@dt as dt
FROM DW_SmartBA.RPT_SmartBA_Orders
WHERE shipping_time IS NOT NULL
	AND payment_time IS NOT NULL
	AND fin_cd <> 2
	AND left(convert(NVARCHAR(8), shipping_time, 112), 6) = @month
	-- convert(NVARCHAR(8), dateadd(day, - 1, getdate()), 112)
GROUP BY 
	convert(NVARCHAR(8), shipping_time, 112)
	,sales_order_number
	,purchase_order_number
	,shipping_time
-- ) a

union all
-- ===== RPT_SmartBA_Orders Refund =====
-- 该表 purchase_order_number 非 refund_no，去重计数有差
-- month	so_cnt	refund_cnt	refund_amount
-- 202204	103	110	-77348.36000
-- -- SELECT 
-- -- '202204'
-- -- ,count(distinct sales_order_number) as so_cnt
-- -- ,count(distinct purchase_order_number) as refund_cnt
-- -- ,sum(sales_amount) as refund_amount
-- -- from(
-- SELECT 
-- 	convert(NVARCHAR(8), fin_time, 112) AS dateid
-- 	,'DW_SmartBA.RPT_SmartBA_Orders' as source
-- 	,'SmartBA Refund' as kpi
-- 	,sales_order_number
-- 	,purchase_order_number
-- 	,fin_time
-- 	,SUM(item_apportion_amount) AS sales_amount
-- 	,CURRENT_TIMESTAMP AS [insert_timestamp]
-- 	,@dt as dt
-- FROM DW_SmartBA.RPT_SmartBA_Orders
-- WHERE shipping_time IS NOT NULL
-- 	AND payment_time IS NOT NULL
-- 	AND fin_cd = 2
-- 	AND left(convert(NVARCHAR(8), fin_time, 112), 6) = @month
-- 	-- convert(NVARCHAR(8), dateadd(day, - 1, getdate()), 112)
-- GROUP BY convert(NVARCHAR(8), fin_time, 112)
-- 	,sales_order_number
-- 	,purchase_order_number
-- 	,fin_time
-- -- ) a
-- ========RPT_SmartBA_Orders end ===========

-- union ALL

-- ===== DWS_SmartBA_Order_Refund's summary ====
-- month	so_cnt	refund_cnt	refund_amount
-- 202204	103	148	-77348.36000

-- SELECT 
-- '202204'
-- ,count(distinct sales_order_number) as so_cnt
-- ,count(distinct refund_no) as refund_cnt
-- ,-1 * sum(sales_amount) as refund_amount
-- from(
SELECT 
	convert(NVARCHAR(8), create_time, 112) AS dateid
	,'DW_SmartBA.DWS_SmartBA_Order_Refund' as source
	,'SmartBA Refund' as kpi
	,sales_order_number
	,refund_no
	,create_time
	,-1 * SUM(item_refund_amount) AS sales_amount
	,CURRENT_TIMESTAMP AS [insert_timestamp]
	,@dt as dt
from [DW_SmartBA].[DWS_SmartBA_Order_Refund]
where left(convert(NVARCHAR(8), create_time, 112), 6) = @month 
group by convert(NVARCHAR(8), create_time, 112)
	,sales_order_number
	,refund_no
	,create_time
-- ) a
-- ========DWS_SmartBA_Order_Refund end ============

end
GO
