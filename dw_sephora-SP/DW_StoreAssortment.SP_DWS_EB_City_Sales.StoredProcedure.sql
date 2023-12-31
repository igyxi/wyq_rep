/****** Object:  StoredProcedure [DW_StoreAssortment].[SP_DWS_EB_City_Sales]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_StoreAssortment].[SP_DWS_EB_City_Sales] @start_date [VARCHAR](10),@dt [VARCHAR](10) AS
BEGIN
truncate table DW_StoreAssortment.DWS_EB_City_Sales;
with eb_sales as 
(
    select 
        a.store_code,
        a.province_cn,
        a.city_cn,
        a.[date],
        a.[month],
        a.[year],
        a.sku_code,
        a.qty,
        a.brand_raw,
        a.sales,
        b.brand,
        b.category,
        b.[Range], 
        b.Segment, 
        b.product_name_en,
        b.[target]
    from
    (
        select 
            store_cd as store_code, 
            province  as province_cn, 
            case when province in (N'上海', N'北京', N'天津', N'重庆') then province else city end as city_cn, 
            place_date as [date],
            format(place_date, 'yyyy-MM') as [month],
            year(place_date) as [year],
            item_sku_cd as sku_code, 
            -- item_name as sku_name, 
            item_quantity as qty, 
            item_brand_name as brand_raw, 
            item_apportion_amount as sales 
        from 
            DW_OMS.RPT_Sales_Order_SKU_Level 
        where 
            split_type_cd <> 'SPLIT_ORIGIN'
        and type_cd <> 2
        and province is not null 
        and city is not null 
        and place_date >= @start_date
    ) a
    join
    (
        select distinct
            sku_code,
            p.brand,
            case when c.category is not null then category_new 
                 when p.brand in (
                    'BIOTHERM',
                    'CLARINS',
                    'CLINIQUE',
                    'DIOR',
                    'DTRT',
                    'JACK BLACK',
                    'LAB SERIES',
                    'SEPHORA',
                    'SHISEIDO',
                    'VS',
                    'SEBASTIAN'
                ) then 'MEN_SC'
                when p.brand = 'CHLOE' and p.category = 'FRAGRANCE' and p.product_name like '%ATELIER DES FLEURS%' then 'CHLOE_ADF'
            else p.category end as category,
            ISNULL([Range], '_NaN') as [Range], 
            ISNULL(Segment, '_NaN') as Segment, 
            product_name_en,
            [target] 
        from 
            ODS_CRM.DimProduct p
        left join
            ods_storeassortment.DIM_Brand_Category_Correction c
        on p.brand = c.brand
        and p.category = c.category
        where 
            p.brand is not null
    ) b
    on a.sku_code = b.sku_code COLLATE Chinese_PRC_CS_AI_WS
) ,
eb_city_monthly_avg as (
    select 
        province_cn,
        city_cn,
        AVG(sales) as city_level_sales
    from
    (
        select 
            [month],
            province_cn,
            city_cn,
            sum(sales) as sales
        from 
            eb_sales
        group by 
            [month],
            city_cn,
            province_cn
    ) t
    group by 
        province_cn,
        city_cn
),
eb_city_brand_categroy_monthly_avg as (
    select 
        province_cn,
        city_cn,
        brand,
        category,
        avg(sales) as sales
    from 
    (
        select 
            [month],
            province_cn,
            city_cn,
            brand,
            category,
            sum(sales) as sales
        from 
            eb_sales
        group by 
            [month],
            city_cn,
            province_cn,
            brand,
            category
    ) t
    group by 
        city_cn,
        province_cn,
        brand,
        category
)
insert into DW_StoreAssortment.DWS_EB_City_Sales
select 
    t1.province_cn,
    t1.city_cn,
    t1.brand,
    t1.category,
    t1.sales as sales_eb,
    t1.city_level_sales as city_level_sales_eb,
    t1.sales_share as sales_share_eb,
    t1.sales_median,
    c.city,
    c.province,
    CURRENT_TIMESTAMP as insert_timestamp
from 
(
    select
        a.province_cn,
        a.city_cn,
        a.city_level_sales,
        b.brand,
        b.category,
        b.sales,
        b.sales/a.city_level_sales as sales_share,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY b.sales) over(partition by a.province_cn, a.city_cn, b.category) as sales_median
    from    
        eb_city_monthly_avg a
    join 
        eb_city_brand_categroy_monthly_avg b
    on 
        a.city_cn = b.city_cn COLLATE Chinese_PRC_CS_AI_WS
    and a.province_cn = b.province_cn COLLATE Chinese_PRC_CS_AI_WS
) t1
join
(
    select 
        province_cn, 
        city_cn, 
        case when city_cn = '杭州' then 'hangzhou'
             when city_cn= '广州' then 'guangzhou'
            else city
        end as city, 
        province 
    from 
        ODS_StoreAssortment.Dim_City_CN_EN 
    where 
        dt = @dt
)  c
on t1.city_cn = c.city_cn COLLATE Chinese_PRC_CS_AI_WS
and t1.province_cn = c.province_cn COLLATE Chinese_PRC_CS_AI_WS
END

GO
