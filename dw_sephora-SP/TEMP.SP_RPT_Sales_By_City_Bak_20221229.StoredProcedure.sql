/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_By_City_Bak_20221229]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_By_City_Bak_20221229] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-14       wangzhichun        Initial Version
-- ========================================================================================
truncate table DW_OMS.RPT_Sales_By_City;
WITH sales AS
(
 SELECT
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
       ,sum(sales.sap_amount) AS sap_amount
   FROM
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
 SELECT
        sales.sales_order_number
       ,sales.purchase_order_number
       ,sales.store_code
       ,sales.province
       ,sales.city
       ,case
          when sales.source in ( 'POS','HUB')
            then sales.place_time
          else refund.create_time
        end place_time
       ,sales.item_sku_code
       ,sales.source
       ,refund.sync_time
       ,sum(refund.item_quantity)*(-1) as  item_quantity
       ,sum(refund.item_apportion_amount)*(-1) as item_apportion_amount
       ,sum(refund.item_apportion_amount)*(-1) AS sap_amount
   FROM
        DWD.Fact_Refund_Order refund
   left join
        DWD.Fact_Sales_Order sales
     ON
        sales.sales_order_number = refund.sales_order_number
    AND
        sales.item_sku_code = refund.item_sku_code
  GROUP BY
        sales.sales_order_number
       ,sales.purchase_order_number
       ,sales.store_code
       ,sales.province
       ,sales.city
       ,case
          when sales.source in ( 'POS','HUB')
            then sales.place_time
          else refund.create_time
        end
       ,sales.item_sku_code
       ,sales.source
       ,refund.sync_time
),
order_address AS
(
 SELECT *
   FROM
        (
         SELECT
                t.sales_order_number
               ,t1.city
               ,t1.province
               ,t1.create_time
               ,ROW_NUMBER() OVER (PARTITION BY t.sales_order_number,t1.city,t1.province ORDER BY t1.create_time DESC) AS rownum
           FROM stg_oms.Sales_Order t
           LEFT JOIN
                stg_oms.Sales_Order_Address t1
             ON t.sales_order_sys_id = t1.sales_order_sys_id
          GROUP BY
                t.sales_order_number
               ,t1.city
               ,t1.province
               ,t1.create_time
        ) TEMP
  WHERE rownum = 1
)

insert into  DW_OMS.RPT_Sales_By_City
SELECT
       format(TEMP.pos_sync_time, 'yyyy-MM') AS month
      ,city_mapping.province
      ,case
         when temp.source in ( 'POS','HUB')
           then store.sap_city
         else city_mapping.city
       end as city
      ,city_mapping.Region
      ,TEMP.store_code
      ,sum(CASE
             WHEN temp.source in ( 'POS','HUB')
               THEN item_apportion_amount
             ELSE 0
           END) AS retail_sales
      ,sum(CASE
             WHEN temp.source = 'OMS'
               THEN sap_amount
             ELSE 0
           END) AS eb_sap_sales
      ,sum(CASE
             WHEN temp.source in ( 'POS','HUB') and c.store_code is not null
               THEN item_apportion_amount
             ELSE 0
           END) AS retail_comp_sales
      ,sum(CASE
             WHEN temp.source = 'OMS'
               THEN item_apportion_amount
             ELSE 0
           END) AS eb_oms_sales
      ,current_timestamp AS insert_tiemstamp
  FROM
       (
        SELECT
               sales.source
              ,sales.store_code
              ,case
                 when source in ('POS','HUB')
                   then sales.place_time
                 else sales.pos_sync_time
               end as pos_sync_time
              ,CASE
                 WHEN (sales.province IS NOT NULL AND sales.province != N'其他')
                   THEN sales.province
                 ELSE order_address.province
               END AS province
              ,CASE
                 WHEN (sales.city IS NOT NULL AND sales.city != N'其他')
                   THEN sales.city
                 ELSE order_address.city
               END AS city
              ,count(DISTINCT sales.store_code) AS store_cnt
              ,SUM(CAST(ISNULL(item_quantity, 0) AS INT) ) AS quantity
              ,SUM(CAST(ISNULL(item_apportion_amount, 0.0) AS FLOAT) ) AS item_apportion_amount
              ,SUM(CAST(ISNULL(sap_amount, 0.0) AS FLOAT) ) AS sap_amount
          FROM
               sales
          LEFT JOIN
               order_address
            ON
               sales.sales_order_number = order_address.sales_order_number
         GROUP BY
               sales.source
              ,sales.store_code
              ,case
                 when source in ('POS','HUB')
                   then sales.place_time
                 else sales.pos_sync_time
               end
              ,CASE
                 WHEN (sales.province IS NOT NULL AND sales.province != N'其他')
                   THEN sales.province
                 ELSE order_address.province
               END
              ,CASE
                 WHEN (sales.city IS NOT NULL AND sales.city != N'其他')
                   THEN sales.city
                 ELSE order_address.city
               END
       ) TEMP
  LEFT JOIN
       STG_OMS.Province_Region_Mapping city_mapping
    ON
       city_mapping.city_name = TEMP.city
  left join
       STG_OMS.Store_Code_Mapping c
    on
       temp.store_code = c.store_code
  left join
       [DWD].[DIM_Store] store
    on
       temp.store_code=store.store_code
 GROUP BY
       format(TEMP.pos_sync_time, 'yyyy-MM')
      ,city_mapping.province
      ,case
         when temp.source in ( 'POS','HUB')
           then store.sap_city
         else city_mapping.city
       end
      ,city_mapping.Region
      ,TEMP.store_code
;
END

GO
