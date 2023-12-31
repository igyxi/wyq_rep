/****** Object:  StoredProcedure [TEMP].[SP_DWS_SKU_Profile_New_Bak20220915]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_SKU_Profile_New_Bak20220915] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-08-17       tali           update dws_product_info
-- 2022-08-30       tali           add SAP_SKU
-- ========================================================================================
truncate table DW_Product.DWS_SKU_Profile_New;
with prod_sku as
(
    select 
        t.sku_id,
        t.sku_code,
        t.sku_name,
        t.tags,
        t.is_default,
        t.status,
        t.product_id,
        t.sku_type,
        t.store,
        t.value,
        t.sap_price,
        t.sale_attr,
        t.link_sku_code,
        t.link_sku_id,
        t.first_pubilsh_time,
        t.last_publish_time,
        t.create_time,
        t.update_time
    from 
    (
        select 
            isnull(a.sku_id, b.id) as sku_id,
            isnull(a.sku_code, b.sku_code) as sku_code,
            isnull(a.sku_name, b.sku_name) as sku_name,
            a.tags,
            a.is_default,
            isnull(a.[status], b.[status]) as status,
            a.product_id,
            a.sku_type,
            a.store,
            a.[value],
            isnull(a.sap_price, b.sap_price) as sap_price,
            a.sale_attr, 
            a.link_sku_code,
            a.link_sku_id,
            a.first_pubilsh_time,
            a.last_publish_time,
            isnull(a.create_time, b.create_time) as create_time,
            isnull(a.update_time, b.update_time) as update_time
            -- row_number() over(partition by sku_code order by tags desc) as rn 
        from 
        (
            select *, row_number() over(partition by sku_code order by create_time desc) rownum from STG_Product.PROD_SKU
        ) a
        full outer join
        (
            select *, row_number() over(partition by sku_code order by create_time desc) rownum from STG_Product.SAP_SKU
        ) b
        on
            a.sku_code = b.sku_code
        and a.rownum = 1
        and b.rownum = 1
        where 
            a.rownum = 1
        or b.rownum = 1
    ) t
),
sku_attrval as 
(
    select sku_id, concat('{',STRING_AGG(sku_attr, ','), '}') sku_attr from
    (
        select 
            sku_id, 
            attr_id, 
            name,
            concat_ws(':', concat('"',attr_id,'"'), concat('"',STRING_AGG(value, ','),'"')) as sku_attr
        from
        (
            select distinct
                psar.sku_id, 
                psar.attr_id,
                pal.value,
                c.name
            from 
                STG_Product.PROD_SKU_Attrval_REL psar
            left join
            (
                select * from STG_Product.PROD_Attrval where is_deleted = 0 and is_disable =0
            ) pal
            on psar.attrval_id = pal.id
            left join
                STG_Product.PROD_ATTR c
            on psar.attr_id = c.id
        ) t
        group by 
            sku_id, attr_id, name
    ) t1
    group by sku_id
)


insert into DW_Product.DWS_SKU_Profile_New
select
    ps.sku_id,
    ps.sku_code,
    -- case when ps.sku_type = 7 then ps.link_sku_code else sm.main_cd end as main_cd,
    upper(sm.sku_name) as sku_name,
    case when sm.sku_name_cn is null then ps.sku_name else sm.sku_name_cn end as sku_name_cn,
    ps.sku_type,
    ps.status,
    case when JSON_QUERY(ps.tags,'$.limitedAmount') is null then 0 else 1 end as isLimit,
    case when JSON_QUERY(ps.tags,'$.exclusiveSephora') is null then 0 else 1 end as isSephora,
    case when JSON_QUERY(ps.tags,'$.newTag') is null then 0 else 1 end as isNew,
    case when JSON_QUERY(ps.tags,'$.exclusiveOnline') is null then 0 else 1 end as isOnline,
    case when JSON_QUERY(ps.tags,'$.memberPrice') is null then 0 else 1 end as isMember,
    case when JSON_QUERY(ps.tags,'$.prelaunch') is null then 0 else 1 end as isPrelaunch,
    case when JSON_QUERY(ps.tags,'$.discount') is null then 0 else 1 end as isDiscount,
    ps.is_default,
    ps.store as sale_store,
    ps.value as sale_value,
    ps.sap_price,
    ps.product_id,
    upper(pp.product_name),
    pp.product_name_cn,
    pp.brand_id,
    isnull(upper(sm.brand), upper(pp.brand_name)) as brand_name,
    pp.brand_name_cn,
    upper(sm.brand_type) as brand_type,
    upper(sm.category) as category,
    pp.level1_id,
    pp.level2_id,
    pp.level3_id,
    pp.level1_name_cn,
    pp.level2_name_cn,
    pp.level3_name_cn,
    upper(sm.range),
    upper(sm.segment),
    sm.target,
    sm.franchise,
    sm.first_function,
    sm.dchain_spec_status,      --新增字段
    sm.plant_sp_matl_status,    --新增字段
    sa.sku_attr,
    case when JSON_VALUE(ps.sale_attr,'$.specImageUrl') is null then '' else JSON_VALUE(ps.sale_attr,'$.specImageUrl') end as image,
    ps.first_pubilsh_time as first_publish_time,
    ps.last_publish_time,
    ps.create_time,
    ps.update_time,
    current_timestamp
from
    prod_sku ps
left join
    DW_Product.DWS_Offline_SKU_Mapping sm
on ps.sku_code = sm.sku_code
-- left join
--     STG_Product.SKU_Classification c 
-- on ps.sku_code = c.sku_code
left join
    DW_Product.DWS_Product_Info pp
on ps.product_id = pp.product_id
left join
    sku_attrval  sa
on ps.sku_id = sa.sku_id;
END

GO
