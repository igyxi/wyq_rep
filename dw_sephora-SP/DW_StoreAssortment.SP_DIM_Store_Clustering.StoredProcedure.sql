/****** Object:  StoredProcedure [DW_StoreAssortment].[SP_DIM_Store_Clustering]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_StoreAssortment].[SP_DIM_Store_Clustering] @cutoff_date [NVARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-11       Tali           Initial Version
-- 2022-11-13       Tali           add filter store code
-- 2022-11-23       Tali           merge store media density
-- 2022-12-01       Tali           add score column
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
                from STG_StoreAssortment.Store_Mall_Info 
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
        t1.store_code not in ('6059','6178','6159','6254','6167','6174','6064', '6138',  '6050', '6302', '6172', '6405', '6440')
    group by 
        store_code,
        store_name
),

store_mall_with_city_rank as
(
    select 
        a.store_code,
        a.store_name,
        a.lux_stores_around,
        a.total_shops_3km,
        a.total_boutiques_3km,
        b.open_date,
        c.city, 
        c.city_rank, 
        case when lux_stores_around >= 10 then 'Lux'
             when city_rank <= 10 then 'A'
             when city_rank <= 50 then 'B'
            else 'C'
        end as cluster 
    from 
        store_mall_info a
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
            store_code,
            open_date
        from 
            ODS_CRM.DimStore
    ) b
    on a.store_code = b.store_code
    left JOIN
    (    
        select
            case when city = 'jiujiangshi' then 'jiujiang' 
            else city end as city,
            city_rank
        from 
            STG_StoreAssortment.Dim_City
    )c
    on upper(b.city) = upper(c.city)
),

median_score as
(
    select 
        *,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY boutiques_scale * 0.6 + shops_scale * 0.4) over(partition by cluster)  as Median_Density_Score
    from
    (
        select 
            *,
            round((total_shops_3km - cast(t.min_total_shops_3km as float))/t.max_total_shops_3km, 4) as shops_scale,
            round((total_boutiques_3km - cast(t.min_total_boutiques_3km as float))/t.max_total_boutiques_3km,4) as boutiques_scale
        from 
        (
            select 
                store_code,
                total_shops_3km,
                total_boutiques_3km,
                cluster,
                min(total_shops_3km) over(partition by cluster) as min_total_shops_3km,
                max(total_shops_3km) over(partition by cluster) as max_total_shops_3km,
                min(total_boutiques_3km) over(partition by cluster) as min_total_boutiques_3km,
                max(total_boutiques_3km) over(partition by cluster) as max_total_boutiques_3km
            from 
                store_mall_with_city_rank
            where
                open_date < @cutoff_date
            and cluster in ('A', 'B')
        ) t
    ) t2
)

insert into DW_StoreAssortment.DIM_Store_Clustering
select 
    store_code,
    store_name,
    cluster_name,
    lux_stores_around,
    city,
    city_rank,
    total_shops_3km,
    total_boutiques_3km,
    boutiques_scale*0.6 + shops_scale * 0.4 as score,
    -- open_date,
    -- boutiques_scale,
    -- shops_scale,
    Median_Density_Score as media_score,
    CURRENT_TIMESTAMP as insert_timestamp
from
(
    select 
        *,
        case 
            when cluster = 'Lux' then 'Lux'
            when cluster = 'A' and Density = 'High' then 'A1: Top 10 / High Density'
            when cluster = 'A' and Density = 'Low' then 'A2: Top 10 / Low Density'
            when cluster = 'B' and Density = 'High' then 'B1: Top 11-50 / High Density'
            when cluster = 'B' and Density = 'Low' then 'B2:Top 11-50 / Low Density'
            when cluster = 'C' then 'C: Top51+'
        end as cluster_name
    from
    (
        select 
            *,
            case when boutiques_scale*0.6 + shops_scale * 0.4 >= Median_Density_Score then 'High' 
                when boutiques_scale*0.6 + shops_scale * 0.4 < Median_Density_Score then 'Low' 
            end as Density
        from
        (
            select 
                a.*,
                b.Median_Density_Score,
                round((a.total_shops_3km - cast(b.min_total_shops_3km as float))/b.max_total_shops_3km, 4) as shops_scale,
                round((a.total_boutiques_3km - cast(b.min_total_boutiques_3km as float))/b.max_total_boutiques_3km,4) as boutiques_scale
            from
                store_mall_with_city_rank a
            left join
            (
                select distinct cluster,
                    Median_Density_Score,
                    min_total_shops_3km, 
                    max_total_shops_3km,
                    min_total_boutiques_3km, 
                    max_total_boutiques_3km
                from
                    median_score
            ) b
            on a.cluster = b.cluster
        ) t2
    ) t3
) t4
END


GO
