/****** Object:  StoredProcedure [DW_SmartBA].[SP_RPT_SmartBA_Margin_By_Sku_Monthly_20220823]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_RPT_SmartBA_Margin_By_Sku_Monthly_20220823] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-04       WuBin          Initial Version
-- ========================================================================================
truncate table [DW_SmartBA].[RPT_SmartBA_Margin_By_Sku_Monthly_20220823];

with smartba_orders as 
(
 select 
        purchase_order_number
       ,convert(NVARCHAR(7), fin_time, 120) as month
       ,item_sku_cd
       ,fin_cd
       ,sum(item_quantity) as item_quantity
       ,sum(item_apportion_amount) as item_apportion_amount
   from 
        [DW_SmartBA].[RPT_SmartBA_Orders_New]
  where 
        fin_cd in (1,2)  --1正向，2负向
    and 
        fin_time >= '2021-02-05'
  group by
        purchase_order_number
       ,convert(NVARCHAR(7), fin_time, 120)
       ,item_sku_cd
       ,fin_cd

  union all

 select 
        purchase_order_number
       ,convert(NVARCHAR(7), fin_time, 120) as month
       ,item_sku_cd
       ,fin_cd
       ,sum(item_quantity) as item_quantity
       ,sum(item_apportion_amount) as item_apportion_amount
   from 
        [DW_SmartBA].[RPT_SmartBA_Orders_New_history]
  where 
        fin_cd in (1,2)
    and 
        fin_time < '2021-02-05'
  group by 
        purchase_order_number
       ,convert(NVARCHAR(7), fin_time, 120)
       ,item_sku_cd
       ,fin_cd
),

sku_info as 
(
select distinct
       a.item_sku_cd as SKU_Code
      ,isnull(d.product_name_cn, e.crm_sku_name) as SKU_Name
      ,isnull(d.brand_name, e.sap_brand_name) as Brand
      ,isnull(e.sap_market_description, d.brand_type) as Brand_Type
      ,isnull(d.category, e.sap_category_description) as category
  from 
       (select distinct item_sku_cd from smartba_orders) a
  left join 
       [DW_Product].[DWS_SKU_Profile] d
    on 
       a.item_sku_cd = d.sku_cd
  left join 
       dwd.dim_sku_info e
    on 
       a.item_sku_cd = e.sku_code
)















insert into DW_SmartBA.RPT_SmartBA_Margin_By_Sku_Monthly_20220823
select 
       T.Month
      ,T.SKU_Code
      ,T1.SKU_Name
      ,T1.Brand
      ,T1.Brand_Type
      ,T1.category
      ,sum(Sales_confirmed_sales_level) as Sales_confirmed_sales_level
      ,sum(Sales_ex_VAT) as Sales_ex_VAT
      ,sum(cogs) as cogs
      ,current_timestamp as insert_timestamp 
  from 
       (
        ---正向
        select 
               month as Month
              ,a.item_sku_cd as SKU_Code
              ,sum(c.sales_vat) as Sales_confirmed_sales_level
              ,sum(c.sales_ex_vat) as Sales_ex_VAT
              ,sum(c.cogs) as cogs
              ,sum(a.item_quantity) as smartba_qty
              ,sum(a.item_apportion_amount) as smartba_amount
              ,sum(c.quantity) as SAP_qty
          from 
               smartba_orders a
         inner join 
               (
                select 
                       a.purchase_order_number
                      ,b.material_code
                      ,sum(b.quantity) as quantity
                      ,sum(b.sales_vat) as sales_vat
                      ,sum(b.sales_ex_vat) as sales_ex_vat
                      ,sum(b.cogs) as cogs
                  from 
                       stg_oms.purchase_to_sap a
                 inner join
                       [ODS_SAP].[Sales_Ticket] b
                    on 
                       a.invoice_id = substring(b.Transaction_Number, patindex('%[1-9]%', b.Transaction_Number), len(b.Transaction_Number))
                 group by
                       a.purchase_order_number
                      ,b.material_code
               ) c
            on 
               a.purchase_order_number = c.purchase_order_number
           and 
               a.item_sku_cd = c.material_code
         where 
               a.fin_cd = 1
         group by 
               month
              ,a.item_sku_cd

         union all

        ---负向
        select 
               month as Month
              ,a.item_sku_cd as SKU_Code
              ,sum(c.sales_vat) as Sales_confirmed_sales_level
              ,sum(c.sales_ex_vat) as Sales_ex_VAT
              ,sum(c.cogs) as cogs
              ,sum(a.item_quantity) as smartba_qty
              ,sum(a.item_apportion_amount) as smartba_amount
              ,sum(c.quantity) as SAP_qty
          from 
               smartba_orders a
         inner join 
               (
                select 
                       a.purchase_order_number
                      ,b.material_code
                      ,sum(b.quantity) as quantity
                      ,sum(b.sales_vat) as sales_vat
                      ,sum(b.sales_ex_vat) as sales_ex_vat
                      ,sum(b.cogs) as cogs
                  from 
                       [STG_OMS].[OMS_Sync_Orders_To_SAP] a
                 inner join
                       [ODS_SAP].[Sales_Ticket] b
                    on 
                       a.invoice_id = substring(b.Transaction_Number, patindex('%[1-9]%', b.Transaction_Number), len(b.Transaction_Number))
                 group by
                       a.purchase_order_number
                      ,b.material_code
               ) c
            on 
               a.purchase_order_number = c.purchase_order_number
           and 
               a.item_sku_cd = c.material_code
         where 
               a.fin_cd = 2
         group by
               month
              ,a.item_sku_cd
       ) T
  left join 
       sku_info T1
    on 
       T.SKU_Code = T1.SKU_Code
 group by
       T.Month
      ,T.SKU_Code
      ,T1.SKU_Name
      ,T1.Brand
      ,T1.Brand_Type
      ,T1.category
;

END
GO
