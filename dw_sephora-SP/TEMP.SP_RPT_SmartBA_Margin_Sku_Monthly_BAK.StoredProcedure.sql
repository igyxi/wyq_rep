/****** Object:  StoredProcedure [TEMP].[SP_RPT_SmartBA_Margin_Sku_Monthly_BAK]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_SmartBA_Margin_Sku_Monthly_BAK] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By      Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-04       WuBin           Initial Version
-- 2022-08-24       houshuangqiang  优化取值逻辑，将公共部分逻辑抽出来，sku_name，brand,brand_type,category取值逻辑也做了调整
-- ========================================================================================
truncate table [DW_SmartBA].[RPT_SmartBA_Margin_Sku_Monthly_BAK];
with smartba_order as 
(
	select	purchase_order_number
			,convert(nvarchar(7), fin_time, 120) as month
			,item_sku_cd
			,fin_cd
			--,sum(item_quantity) as item_quantity
			--,sum(item_apportion_amount) as item_apportion_amount
	from
		   [dw_smartba].[rpt_smartba_orders_new]
	where
       fin_cd in (1, 2) --  fin_cd:1正向,2:负向
    and
       fin_time >= '2021-02-05'
	group by
			purchase_order_number
			,convert(nvarchar(7), fin_time, 120)
			,item_sku_cd
			,fin_cd
	union 	all 
	select	purchase_order_number
			,convert(nvarchar(7), fin_time, 120) as month
			,item_sku_cd
			,fin_cd
			--,sum(item_quantity) as item_quantity
			--,sum(item_apportion_amount) as item_apportion_amount
	from
		  [dw_smartba].[rpt_smartba_orders_new_history]
	where
        fin_cd in (1, 2)
	and
        fin_time < '2021-02-05' 
	group by
			 purchase_order_number
			 ,convert(nvarchar(7), fin_time, 120)
			 ,item_sku_cd
			 ,fin_cd
)

insert into DW_SmartBA.RPT_SmartBA_Margin_Sku_Monthly_BAK
select 
     p.month
    ,p.sku_code	 
	,isnull(p1.crm_sku_name, p1.eb_product_name_cn) as sku_name -- eb_product_name_cn 是dw_product.dws_sku_profile 的 product_name_cn
	,isnull(p1.sap_brand_name, p1.eb_brand_name) as brand -- eb_brand_name 是dw_product.dws_sku_profile 的 brand_name
	,isnull(p1.sap_market_description, p1.eb_brand_type) as brand_type -- eb_brand_type 是dw_product.dws_sku_profile 的 brand_type
	,isnull(p1.sap_category_description, p1.eb_category) as category -- eb_category 是dw_product.dws_sku_profile 的 category
    ,sum(p.sales_confirmed_sales_level) as sales_confirmed_sales_level
    ,sum(p.sales_ex_vat) as sales_ex_vat
    ,sum(p.cogs) as cogs
    ,current_timestamp as insert_timestamp 
from 
(
	---正向
	select
		 a.month
		,a.item_sku_cd as sku_code
		,sum(c.sales_vat) as sales_confirmed_sales_level
		,sum(c.sales_ex_vat) as sales_ex_vat
		,sum(c.cogs) as cogs
		--,sum(a.item_quantity) as smartba_qty -- 这些字段，目标表没有用到，先注释掉，下一个版本调整时，直接将这些多余的字段删除，不做保留
		--,sum(a.item_apportion_amount) as smartba_amount
		--,sum(c.quantity) as sap_qty
	from
		smartba_order a
	inner join
	(
		select
			a.purchase_order_number
			,b.material_code
			--,sum(b.quantity) as quantity
			,sum(b.sales_vat) as sales_vat
			,sum(b.sales_ex_vat) as sales_ex_vat
			,sum(b.cogs) as cogs
		from
		  stg_oms.purchase_to_sap a
		inner join
		  [ods_sap].[sales_ticket] b
		on
		  a.invoice_id = substring(b.transaction_number, patindex('%[1-9]%', b.transaction_number), len(b.transaction_number))
		group by
		   a.purchase_order_number
			,b.material_code
	) c
    on
        a.purchase_order_number = c.purchase_order_number
    and
        a.item_sku_cd = c.material_code
	where 
		a.fin_cd = 1 -- 正向 
	group by 
		a.month
		,a.item_sku_cd	    
	union all 
	select
		 b.month
		,b.item_sku_cd as sku_code
		,sum(b3.sales_vat) as sales_confirmed_sales_level
	    ,sum(b3.sales_ex_vat) as sales_ex_vat
		,sum(b3.cogs) as cogs
		--,sum(b.item_quantity) as smartba_qty
		--,sum(b.item_apportion_amount) as smartba_amount
		--,sum(b3.quantity) as sap_qty
	from	
		smartba_order b  
	inner join
	(
		select
		    b1.purchase_order_number
			,b2.material_code
			--,sum(b2.quantity) as quantity
			,sum(b2.sales_vat) as sales_vat
			,sum(b2.sales_ex_vat) as sales_ex_vat
			,sum(b2.cogs) as cogs
		from
		   [stg_oms].[oms_sync_orders_to_sap] b1
		inner join
		   [ods_sap].[sales_ticket] b2
			on b1.invoice_id = substring(b2.transaction_number, patindex('%[1-9]%', b2.transaction_number), len(b2.transaction_number))
		group by
			b1.purchase_order_number
			,b2.material_code
		) b3
   on
      b.purchase_order_number = b3.purchase_order_number
   and
      b.item_sku_cd = b3.material_code
   and 
	  b.fin_cd = 2 -- 负向 
   group by 
	  b.month
	  ,b.item_sku_cd
) p 
left  join 
	dwd.dim_sku_info p1 
on  
	p.sku_code = p1.sku_code
group by 
 	p.month
    ,p.sku_code
	,isnull(p1.crm_sku_name, p1.eb_product_name_cn)
	,isnull(p1.sap_brand_name, p1.eb_brand_name)
	,isnull(p1.sap_market_description, p1.eb_brand_type)
	,isnull(p1.sap_category_description, p1.eb_category)
;
end 
GO
