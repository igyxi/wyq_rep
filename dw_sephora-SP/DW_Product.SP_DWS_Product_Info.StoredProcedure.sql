/****** Object:  StoredProcedure [DW_Product].[SP_DWS_Product_Info]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Product].[SP_DWS_Product_Info] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-08-17       tali           delete dim_product
-- 2022-11-18       wangzhichun    add category2
-- ========================================================================================
truncate table DW_Product.DWS_Product_Info;
insert into DW_Product.DWS_Product_Info
select
    a.product_id,
    a.name_en,
    a.name_cn,
    a.origin_name_en,
    a.origin_name_cn,
    a.series_name_en,
    a.series_name_cn,
    a.publish_time,
    a.unpublish_time,
    a.store_list,
    a.type,
    a.status,
    a.is_o2o_flag,
    a.is_offline_flag,
    a.is_search_flag,
    a.is_blacklist_flag,
    a.description,
    a.slogan_json,
    a.attr_desc_json,
    b.brand_id,
    b.brand_name_en,
    b.brand_name_cn,
    -- d.market as brand_type,
    -- e.category,
    c.category_level1_id,
    c.category_level1_name_en,
    c.category_level1_name_cn,
    c.category_level2_id,
    c.category_level2_name_en,
    c.category_level2_name_cn,
    c.category_level3_id,
    c.category_level3_name_en,
    c.category_level3_name_cn,
    c2.category2_level1_id as category2_level1_id,
    c2.category2_level1_name_en as category2_level1_name_en,
    c2.category2_level1_name_cn as category2_level1_name_cn,
    c2.category2_level2_id as category2_level2_id,
    c2.category2_level2_name_en as category2_level2_name_en,
    c2.category2_level2_name_cn as category2_level2_name_cn,
    c2.category2_level3_id as category2_level3_id,
    c2.category2_level3_name_en as category2_level3_name_en,
    c2.category2_level3_name_cn as category2_level3_name_cn,
    a.create_time,
    a.update_time,
    current_timestamp
from
(
    select 
        id as product_id,
        type,
        name_en,
        name_cn,
        origin_name_en,
        origin_name_cn,
        series_en as series_name_en,
        series_cn as series_name_cn,
        publish_time,
        unpublish_time,
        store as store_list,
        status,
        o2o as is_o2o_flag,
        [offline] as is_offline_flag,
        is_search as is_search_flag,
        is_black as is_blacklist_flag,
        desc_text as description,
        slogan as slogan_json,
        desc_attr as attr_desc_json,
        create_time,
        update_time
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
                product_id,
                group_data,
                row_number() over(partition by product_id order by id desc) as rn 
            from 
                STG_Product.PROD_Product_Group_REL 
            where catalog_id = '10056'
        ) r
    left join
        DW_Product.DIM_Brand b
    on cast(JSON_VALUE(r.group_data,'$.level1.id') as int) = b.brand_id
    where r.rn = 1
) b
on a.product_id = b.product_id
-- left join
--     STG_Product.PROD_Brand_Type d
-- on b.brand_name_en = d.sap_brand
left join
(
    select
        r.product_id,
        JSON_VALUE(r.group_data, '$.level1.id') as category_level1_id,
        JSON_VALUE(r.group_data, '$.level2.id') as category_level2_id,
        JSON_VALUE(r.group_data, '$.level3.id') as category_level3_id,
        c1.category_name_en as category_level1_name_en,
        c1.category_name_cn as category_level1_name_cn,
        c2.category_name_en as category_level2_name_en,
        c2.category_name_cn as category_level2_name_cn,
        c3.category_name_en as category_level3_name_en,
        c3.category_name_cn as category_level3_name_cn
    from
       (
            select 
                product_id,
                group_data,
                row_number() over(partition by product_id order by id desc) as rn 
            from 
                STG_Product.PROD_Product_Group_REL 
            where catalog_id = '10052'
        ) r
    left join
        (
            select 
                category_id,
                category_name_en,
                category_name_cn
            from 
                DW_Product.DIM_Category 
            where 
                level_id = 1 
        )c1
    on cast(JSON_VALUE(r.group_data, '$.level1.id') as int) = c1.category_id
    left join
        (
            select 
                category_id,
                category_name_en,
                category_name_cn
            from 
                DW_Product.DIM_Category 
            where level_id = 2
        ) c2
    on cast(JSON_VALUE(r.group_data, '$.level2.id') as int) = c2.category_id
    left join
        (
            select 
                category_id,
                category_name_en,
                category_name_cn
            from 
                DW_Product.DIM_Category 
            where level_id = 3
        ) c3
    on cast(JSON_VALUE(r.group_data, '$.level3.id') as int) = c3.category_id
    where r.rn = 1
) c
on a.product_id = c.product_id
left join
(
    select
        r2.product_id as product_id,
        JSON_VALUE(r2.group_data, '$.level1.id') as category2_level1_id,
        JSON_VALUE(r2.group_data, '$.level2.id') as category2_level2_id,
        JSON_VALUE(r2.group_data, '$.level3.id') as category2_level3_id,
        c4.category_name_en as category2_level1_name_en,
        c4.category_name_cn as category2_level1_name_cn,
        c5.category_name_en as category2_level2_name_en,
        c5.category_name_cn as category2_level2_name_cn,
        c6.category_name_en as category2_level3_name_en,
        c6.category_name_cn as category2_level3_name_cn
    from
       (
            select 
                product_id, 
                group_data,
                row_number() over(partition by product_id order by id desc) as rn 
            from 
                STG_Product.PROD_Product_Group_REL 
            where catalog_id = '10053'
        ) r2
    left join
        (
            select 
                category_id,
                category_name_en,
                category_name_cn
            from 
                DW_Product.DIM_Category 
            where level_id = 1 
        ) c4
    on cast(JSON_VALUE(r2.group_data, '$.level1.id') as int) = c4.category_id
    left join
        (
            select 
                category_id,
                category_name_en,
                category_name_cn
            from 
                DW_Product.DIM_Category 
            where level_id = 2
        ) c5
    on cast(JSON_VALUE(r2.group_data, '$.level2.id') as int) = c5.category_id
    left join
        (
            select 
                category_id,
                category_name_en,
                category_name_cn
            from 
                DW_Product.DIM_Category 
            where level_id = 3
        ) c6    
    on cast(JSON_VALUE(r2.group_data, '$.level3.id') as int) = c6.category_id
    where r2.rn = 1
) c2
on a.product_id = c2.product_id
-- left join
--     STG_Product.PROD_Category_Mapping e
-- on c.category_level1_name_cn = e.category_level1_cn
;
END

GO
