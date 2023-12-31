/****** Object:  StoredProcedure [RPT].[SP_RPT_Sales_By_City]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sales_By_City] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-14       wangzhichun        Initial Version
-- 2022-12-28       litao              Replacement target table
-- 2023-05-28       wangzhichun        update NEW OMS
-- ========================================================================================
truncate table RPT.RPT_Sales_By_City;
with sales as
(
    select
            sales.sales_order_number
        ,sales.purchase_order_number
        ,sales.store_code
        ,sales.province
        ,sales.city
        ,sales.place_time
        ,sales.item_sku_code
        ,sales.source
        ,sales.pos_sync_time
        ,sum(sales.item_quantity) item_quantity
        ,sum(sales.item_apportion_amount) item_apportion_amount
        ,sum(sales.sap_amount) as sap_amount
    from
            DWD.Fact_Sales_Order sales
    group by
            sales.sales_order_number
        ,sales.purchase_order_number
        ,sales.store_code
        ,sales.province
        ,sales.city
        ,sales.place_time
        ,sales.item_sku_code
        ,sales.source
        ,sales.item_quantity
        ,sales.pos_sync_time
    union all
    select
            sales.sales_order_number
        ,sales.purchase_order_number
        ,sales.store_code
        ,sales.province
        ,sales.city
        ,case when sales.source in ( 'POS','HUB') then sales.place_time else refund.create_time end place_time
        ,sales.item_sku_code
        ,sales.source
        ,refund.sync_time
        ,sum(refund.item_quantity)*(-1) as  item_quantity
        ,sum(refund.item_apportion_amount)*(-1) as item_apportion_amount
        ,sum(refund.item_apportion_amount)*(-1) as sap_amount
    from
            DWD.Fact_Refund_Order refund
    left join
            DWD.Fact_Sales_Order sales
        on
            sales.sales_order_number = refund.sales_order_number
        and
            sales.item_sku_code = refund.item_sku_code
    group by
            sales.sales_order_number
        ,sales.purchase_order_number
        ,sales.store_code
        ,sales.province
        ,sales.city
        ,case when sales.source in ( 'POS','HUB') then sales.place_time else refund.create_time end
        ,sales.item_sku_code
        ,sales.source
        ,refund.sync_time
),
order_address as
(
    select
        so.tid as sales_order_number
        ,case 
            when trim(lower(so.receiver_state)) in ('null', '') then null 
            when t1.province_short_name is not null then t1.province_short_name
            else trim(so.receiver_state)
        end as province
        ,case 
            when trim(lower(so.receiver_city)) in ('null', '') then null 
            when t2.city_short_name is not null then t2.city_short_name
            else trim(so.receiver_city)
        end as city
    from
        ODS_OMS_Order.OMS_STD_Trade so
    left join 
    (
        select distinct province_name,province_short_name from DW_Common.DIM_Area
    ) t1
    on trim(so.receiver_state) = t1.province_name
    left join 
    (
        select
            distinct province_short_name, city_name, city_short_name 
        from 
            DW_Common.DIM_Area
     ) t2
    on (case when t1.province_short_name is not null then t1.province_short_name else trim(so.receiver_state) end) = t2.province_short_name
    and trim(so.receiver_city) = t2.city_name
)

insert into  RPT.RPT_Sales_By_City
select
       format(temp.pos_sync_time, 'yyyy-MM') as month
      ,city_mapping.province
      ,case when temp.source in ( 'POS','HUB') then store.sap_city else city_mapping.city end as city
      ,city_mapping.region
      ,temp.store_code
      ,sum(case when temp.source in ( 'POS','HUB') then item_apportion_amount else 0 end) as retail_sales
      ,sum(case when temp.source = 'OMS' then sap_amount else 0 end) as eb_sap_sales
      ,sum(case when temp.source in ( 'POS','HUB') and c.store_code is not null then item_apportion_amount else 0 end) as retail_comp_sales
      ,sum(case when temp.source = 'OMS' then item_apportion_amount else 0 end) as eb_oms_sales
      ,current_timestamp as insert_tiemstamp
  from
       (
        select
               sales.source
              ,sales.store_code
              ,case when source in ('POS','HUB') then sales.place_time else sales.pos_sync_time end as pos_sync_time 
              ,case when (sales.province is not null and sales.province != N'其他') then sales.province else order_address.province end as province
              ,case when (sales.city is not null and sales.city != N'其他') then sales.city else order_address.city end as city
              ,count(distinct sales.store_code) as store_cnt
              ,sum(cast(isnull(item_quantity, 0) as int) ) as quantity
              ,sum(cast(isnull(item_apportion_amount, 0.0) as float) ) as item_apportion_amount
              ,sum(cast(isnull(sap_amount, 0.0) as float) ) as sap_amount
          from
               sales
          left join
               order_address
            on
               sales.sales_order_number = order_address.sales_order_number
         group by
               sales.source
              ,sales.store_code
              ,case when source in ('POS','HUB') then sales.place_time else sales.pos_sync_time end
              ,case when (sales.province is not null and sales.province != N'其他') then sales.province else order_address.province end
              ,case when (sales.city is not null and sales.city != N'其他') then sales.city else order_address.city end
       ) temp
  left join
       ODS_OMS_Order.Province_Region_Mapping city_mapping
    on
       city_mapping.city_name = temp.city
  left join
       [ODS_OMS_Order].[Store_Code_Mapping] c
    on
       temp.store_code = c.store_code
  left join
       DWD.DIM_Store store
    on
       temp.store_code=store.store_code
 group by
       format(temp.pos_sync_time, 'yyyy-MM')
      ,city_mapping.province
      ,case when temp.source in ( 'POS','HUB') then store.sap_city else city_mapping.city end
      ,city_mapping.Region
      ,TEMP.store_code
;
END
GO
