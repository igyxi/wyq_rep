/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_SmartBA_Margin_By_Sku_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_SmartBA_Margin_By_Sku_Monthly] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By      Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-04       WuBin           Initial Version
-- 2022-08-24       houshuangqiang  优化取值逻辑，将公共部分逻辑抽出来，sku_name，brand,brand_type,category取值逻辑也做了调整.去掉无关的字段
-- 2023-03-07       houshuangqiang  add store_code
-- 2023-04-27       houshuangqiang  change sap to fact_sales_order_ext
-- 2023-05-05       wangzhichun     change oms_sync_orders_to_sap to Fact_Refund_Order
-- ========================================================================================
truncate table [DW_SmartBA].[RPT_SmartBA_Margin_By_Sku_Monthly];
with smartba_order as
(
	select	purchase_order_number
			,convert(nvarchar(7), fin_time, 120) as month
            ,utm_content as store_code
			,item_sku_cd
			,fin_cd
	from
		   [dw_smartba].[rpt_smartba_orders]
	where
       fin_cd in (1, 2) --  fin_cd:1正向,2:负向
    and
       fin_time >= '2021-02-05'
	group by
			purchase_order_number
			,convert(nvarchar(7), fin_time, 120)
			,utm_content
			,item_sku_cd
			,fin_cd
	union 	all
	select	purchase_order_number
			,convert(nvarchar(7), fin_time, 120) as month
			,utm_content as store_code
			,item_sku_cd
			,fin_cd
	from
		  [dw_smartba].[rpt_smartba_orders_history]
	where
        fin_cd in (1, 2)
	and
        fin_time < '2021-02-05'
	group by
			 purchase_order_number
			 ,convert(nvarchar(7), fin_time, 120)
			 ,utm_content
			 ,item_sku_cd
			 ,fin_cd
),

-- sap 
sap as 
(
	select	purchase_order_number
			,item_sku_code
			,sap_amount
			,sap_ex_vat_amount
			,item_cogs
	from 	DWD.Fact_Sales_Order_EXT
	where 	source = 'OMS'
	and 	sap_store_code is not null 
	group 	by purchase_order_number,item_sku_code,sap_amount,sap_ex_vat_amount,item_cogs
    union all 
    select
            exchange.purchase_order_number
			,b.material_code
			,b.sales_vat as sap_amount
			,b.sales_ex_vat as sap_ex_vat_amount
			,b.cogs as item_cogs
    from 
            DWD.Fact_Exchange_Order exchange 
	inner join
	   [ods_sap].[sales_ticket] b
	on  exchange.invoice_id = substring(b.transaction_number, patindex('%[1-9]%', b.transaction_number), len(b.transaction_number))
	group by
		exchange.purchase_order_number,b.material_code,b.sales_vat,b.sales_ex_vat,b.cogs

)


insert into DW_SmartBA.RPT_SmartBA_Margin_By_Sku_Monthly
select
     p.month
    ,p.store_code
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
	--正向
	select
		 a.month
        ,a.store_code
		,a.item_sku_cd as sku_code
		,sum(sap.sap_amount) as sales_confirmed_sales_level
		,sum(sap.sap_ex_vat_amount) as sales_ex_vat
		,sum(sap.item_cogs) as cogs
	from
		smartba_order a
	inner join sap
    on	 a.purchase_order_number = sap.purchase_order_number
    and	 a.item_sku_cd = sap.item_sku_code
	where
		a.fin_cd = 1 -- 正向
	group by
		a.month
        ,a.store_code
		,a.item_sku_cd
	union all
	select
		 b.month
        ,b.store_code
		,b.item_sku_cd as sku_code
		,sum(b3.sales_vat) as sales_confirmed_sales_level
	    ,sum(b3.sales_ex_vat) as sales_ex_vat
		,sum(b3.cogs) as cogs
	from
		smartba_order b
	inner join
	(
        select
		    b1.purchase_order_number purchase_order_number
			,b2.material_code material_code
			,sum(b2.sales_vat) as sales_vat
			,sum(b2.sales_ex_vat) as sales_ex_vat
			,sum(b2.cogs) as cogs
		from
        (
            select 
                purchase_order_number,invoice_id
            from 
		        DWD.Fact_Refund_Order
            group by purchase_order_number,invoice_id
            union all 
            select 
                related_order_number as purchase_order_number,refund.invoice_id
            from 
                DWD.Fact_Exchange_Order exchange
            left join 
                DWD.Fact_Refund_Order refund
            on exchange.purchase_order_number=refund.purchase_order_number
            and exchange.item_sku_code=refund.item_sku_code
            group by related_order_number,refund.invoice_id
        ) b1
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
      ,b.store_code
	  ,b.item_sku_cd
) p
left  join
	dwd.dim_sku_info p1
on
	p.sku_code = p1.sku_code
group by
 	p.month
    ,p.store_code
    ,p.sku_code
	,isnull(p1.crm_sku_name, p1.eb_product_name_cn)
	,isnull(p1.sap_brand_name, p1.eb_brand_name)
	,isnull(p1.sap_market_description, p1.eb_brand_type)
	,isnull(p1.sap_category_description, p1.eb_category)
end
GO
