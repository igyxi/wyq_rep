/****** Object:  StoredProcedure [TEMP].[SP_DIM_Store_Clustering_Bak20221123]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Store_Clustering_Bak20221123] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-11       Tali           Initial Version
-- ========================================================================================
truncate table DW_StoreAssortment.DIM_Store_Clustering;
with store_mall_info as
(
    select 
        store_code,
        store_name,
        count(case when upper(brand_type) like 'LUX%' and upper(mall_type) = 'SEPHORA MALL' then brand else null end) as lux_stores_around,
        max(shop_total) as total_shops_3km,
        count(case when upper(brand_type) Like 'BOUTIQUE%' then brand else null end) as total_boutiques_3km
    from 
    (
        select 
            a.store_code, 
            a.store_name, 
            a.mall_type, 
            a.shop_total, 
            a.brand_type, 
            a.brand 
        from
        (
            select distinct
                store_code, 
                store_name, 
                mall_type, 
                shop_total, 
                brand_type, 
                brand_name as brand 
            from
                STG_StoreAssortment.Store_Mall_External_Info
        ) a
        left join
        (
            select distinct
                store_code
            from 
                STG_StoreAssortment.Store_Mall_Info 
            where 
                store_code is not null 
            and store_name is not null 
        ) b
        on a.store_code = b.store_code
        where b.store_code is null

        union all
        select
            d.store_code, 
            d.store_name, 
            c.mall_type, 
            d.shop_total, 
            c.brand_type, 
            c.brand 
        from
        (
            select 
                store_code, store_name, sum(shop_total) as shop_total
            from
            (
                select distinct
                    store_code, store_name, mall_type, shop_total
                from 
                    STG_StoreAssortment.Store_Mall_Info 
                where 
                    store_code is not null 
                and store_name is not null
            )t
            group by store_code, store_name
        ) d
        left join
        (
            select 
                store_code, store_name, mall_type, brand_type, brand
            from 
                STG_StoreAssortment.Store_Mall_Info 
            where 
                store_code is not null 
            and store_name is not null
            and is_in = 'Y'
        ) c
        on c.store_code = d.store_code
    ) t1
    where 
        store_code not in ('6059','6178','6159','6254','6167','6174','6064', '6138')
    group by 
        store_code,
        store_name
),

store_mall_with_scale as 
(
    select 
        store_code,
        store_name,
        lux_stores_around,
        total_shops_3km,
        total_boutiques_3km,
        round((total_shops_3km - cast(t.min_total_shops_3km as float))/t.max_total_shops_3km, 4) as shops_scale,
        round((total_boutiques_3km - cast(t.min_total_boutiques_3km as float))/t.max_total_boutiques_3km,4) as boutiques_scale
    from 
        store_mall_info 
    join
    (
        select
            min(total_shops_3km) min_total_shops_3km,
            MAX(total_shops_3km) max_total_shops_3km,
            min(total_boutiques_3km) min_total_boutiques_3km,
            max(total_boutiques_3km) max_total_boutiques_3km
        from
            store_mall_info
    ) t
    on 1 = 1
),

store_mall_with_city_rank as
(
    select 
        a.*, b.city, c.city_rank
    from 
        store_mall_with_scale a
    left join
    (
        select 
            case when city = 'Xi''an' and province = 'shanxi' then 'xian' 
                when city = 'Xi''Ning' and province = 'qinghai' then 'xining'
                when city = 'Haerbin' and province = 'heilongjiang' then 'harbin'
                else city 
            end as city,
            province, 
            store_name, 
            store_code 
        from 
            ODS_CRM.DimStore
    ) b
    on a.store_code = b.store_code COLLATE Chinese_PRC_CS_AI_WS
    left JOIN
    (    
        select
            case when city = 'jiujiangshi' then 'jiujiang' 
            else city end as city,
            city_rank
        from 
            STG_StoreAssortment.Dim_City
    )c
    on upper(b.city) = upper(c.city) COLLATE Chinese_PRC_CS_AI_WS
)

insert into DW_StoreAssortment.DIM_Store_Clustering
select 
    store_code,
    store_name,
    cluster,
    lux_stores_around,
    city,
    city_rank,
    total_shops_3km,
    total_boutiques_3km,
    CURRENT_TIMESTAMP
from
(
    select 
        *,
        case 
            when lux_stores_around >= 10 then 'Lux'
            when city_rank <= 10 and Density = 'High' then 'A1: Top 10 / High Density'
            when city_rank <= 10 and Density = 'Low' then 'A2: Top 10 / Low Density'
            when city_rank <= 50 and Density = 'High' then 'B1: Top 11-50 / High Density'
            when city_rank <= 50 and Density = 'Low' then 'B2:Top 11-50 / Low Density'
            else 'C: Top51+'
        end as cluster
    from
    (
        select 
            *,
            case when top_10_Density_Score < top_10_Median_Density_Score then 'Low'
                when top_10_Density_Score >= top_10_Median_Density_Score then 'High'
                when top_50_Density_Score < top_50_Median_Density_Score then 'Low'
                when top_50_Density_Score >= top_50_Median_Density_Score then 'High'
                else null
            end as Density
        from
        (
            select 
                t1.*,
                a.top_10_Median_Density_Score,
                a.top_50_Median_Density_Score
            from
            (
                select 
                    *,
                    case when city_rank <= 10 then Density_Score else null end as top_10_Density_Score,
                    case when city_rank > 10 then Density_Score else null end as top_50_Density_Score
                from 
                (
                    select 
                        *, 
                        case when city_rank <= 10 and lux_stores_around < 10 then boutiques_scale*0.6 + shops_scale * 0.4
                            when city_rank <= 50 and lux_stores_around < 10 then boutiques_scale*0.4 + shops_scale * 0.6
                            else null
                        end as Density_Score
                    from 
                        store_mall_with_city_rank
                ) t
            ) t1
            left join
            (
                select distinct top_10_Median_Density_Score, top_50_Median_Density_Score  from [DW_StoreAssortment].[DWS_Store_Density]
            ) a
            on 1=1
        ) t2
    ) t3
) t4

END


GO
