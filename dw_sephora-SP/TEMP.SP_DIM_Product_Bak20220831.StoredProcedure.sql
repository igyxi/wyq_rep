/****** Object:  StoredProcedure [TEMP].[SP_DIM_Product_Bak20220831]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Product_Bak20220831] AS
BEGIN
truncate table DWD.DIM_Product;
with DIM_Category as (
    select
        id as category_id,
        name_en as category_name_en,
        name_cn as category_name_cn,
        level as level_id
    from
        STG_Product.prod_group
    where 
        catalog_id = 10052
),
DIM_Brand as (
    select 
        id as brand_id,
        name_en as brand_name_en,
        name_cn as brand_name_cn
    from 
        STG_Product.PROD_Group 
    where 
        catalog_id = 10056 
    and parent_id = 0
)

insert into DWD.DIM_Product
select distinct
    a.product_id,
    a.type_cd,
    a.name_en,
    a.name_cn,
    a.origin_name_en,
    a.origin_name_cn,
    a.series_name_en,
    a.series_name_cn,
    a.publish_time,
    a.unpublish_time,
    a.store_list,
    a.status_code,
    a.is_o2o,
    a.is_offline,
    a.is_search,
    a.is_blacklist,
    b.brand_id,
    b.brand_name_en,
    b.brand_name_cn,
    c.category_level1_id,
    c.category_level1_name_en,
    c.category_level1_name_cn,
    c.category_level2_id,
    c.category_level2_name_en,
    c.category_level2_name_cn,
    c.category_level3_id,
    c.category_level3_name_en,
    c.category_level3_name_cn,
    a.create_time,
    a.update_time,
    'OMS' as source,
    current_timestamp
from
(
    select 
        id as product_id,
        type as type_cd,
        name_en,
        name_cn,
        origin_name_en,
        origin_name_cn,
        series_en as series_name_en,
        series_cn as series_name_cn,
        publish_time,
        unpublish_time,
        store as store_list,
        status as status_code,
        o2o as is_o2o,
        [offline] as is_offline,
        is_search as is_search,
        is_black as is_blacklist,
        desc_text,
        slogan as slogan_json,
        desc_attr as attr_json,
        null as create_time,
        update_time,
        current_timestamp as insert_timestamp
    from
        STG_Product.PROD_Product
) a
left join
(
    select
        r.product_id,
        JSON_VALUE(r.group_data,'$.level1.id') as brand_id,
        b.brand_name_en,
        b.brand_name_cn
    from
    (
        select 
            *, row_number() over(partition by product_id order by id desc) as rn 
        from 
            STG_Product.PROD_Product_Group_REL 
        where 
            catalog_id = '10056'
    ) r
    left join
        DIM_Brand b
    on cast(JSON_VALUE(r.group_data,'$.level1.id') as int) = b.brand_id
    where r.rn = 1
) b
on a.product_id = b.product_id
left join
(
    select
        r.product_id,
        r.category_level1_id,
        r.category_level2_id,
        r.category_level3_id,
        c1.category_name_en as category_level1_name_en,
        c1.category_name_cn as category_level1_name_cn,
        c2.category_name_en as category_level2_name_en,
        c2.category_name_cn as category_level2_name_cn,
        c3.category_name_en as category_level3_name_en,
        c3.category_name_cn as category_level3_name_cn
    from
    (
        select 
            *,
            cast(JSON_VALUE(group_data, '$.level1.id') as int) as category_level1_id,
            cast(JSON_VALUE(group_data, '$.level2.id') as int) as category_level2_id,
            cast(JSON_VALUE(group_data, '$.level3.id') as int) as category_level3_id,
            row_number() over(partition by product_id order by id desc) as rn 
        from 
            STG_Product.PROD_Product_Group_REL 
        where 
            catalog_id = '10052'
    ) r
    left join
        (select * from DIM_Category where level_id = 1 )c1
    on category_level1_id = c1.category_id
    left join
        (select * from DIM_Category where level_id = 2) c2
    on category_level2_id = c2.category_id
    left join
        (select * from DIM_Category where level_id = 3) c3
    on category_level3_id = c3.category_id
    where r.rn = 1
) c
on a.product_id = c.product_id;
end
GO
