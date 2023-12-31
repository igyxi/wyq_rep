/****** Object:  StoredProcedure [TEMP].[SP_DWS_SKU_Profile_Bak_20221017]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_SKU_Profile_Bak_20221017] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-08-17       tali           update dws_product_info
-- ========================================================================================
truncate table DW_Product.DWS_SKU_Profile_Bak_20221017;
with prod_sku as
(
    select 
        a.sku_id,
        coalesce(a.sku_code,b.sku_code) as sku_code,
        coalesce(a.sku_name,b.sku_name) as sku_name,
        a.tags,
        a.is_default,
        a.status,
        a.product_id,
        a.sku_type,
        a.store,
        a.value,
        a.sap_price,
        a.sale_attr,
        a.link_sku_code,
        a.link_sku_id,
        a.first_pubilsh_time,
        a.last_publish_time
    from 
    (
        select 
            *,
            row_number() over(partition by sku_code order by tags desc) as rn 
        from 
            STG_Product.PROD_SKU 
        where
            sku_type<>7
    ) a
    FULL OUTER JOIN
        STG_Product.SAP_SKU b
    on
        a.sku_id = b.id
    where a.rn = 1
),
ve_prod_sku as
(
    select 
        a.sku_id,
        a.sku_code as sku_code,
        ps.sku_name as sku_name,
        ps.tags,
        ps.is_default,
        a.status,
        ps.product_id,
        a.sku_type,
        ps.store,
        ps.value,
        a.sap_price,
        ps.sale_attr,
        a.link_sku_code,
        a.link_sku_id,
        a.first_pubilsh_time,
        a.last_publish_time
    from 
    (
        select 
            *,
            row_number() over(partition by sku_code order by tags desc) as rn 
        from 
            STG_Product.PROD_SKU 
        where
            sku_type=7
    ) a
    left JOIN 
       prod_sku ps
    on 
        a.link_sku_code = ps.sku_code
    where 
        a.rn = 1
),
sku_attrval as 
(
    select 
        sku_id, 
        attr_id, 
        STRING_AGG(value, ',') as value
    from
    (
        select distinct
            psar.sku_id, 
            psar.attr_id,
            pal.value
        from 
            STG_Product.PROD_SKU_Attrval_REL psar
        left join
        (
            select * from STG_Product.PROD_Attrval where is_deleted = 0 and is_disable =0
        ) pal
        on psar.attrval_id = pal.id
    ) t
    -- where sku_id = 20018
    group by sku_id, attr_id
)

insert into DW_Product.DWS_SKU_Profile_Bak_20221017
select
    ps.sku_id,
    ps.sku_code,
    case when ps.sku_type = 7 then ps.link_sku_code else sm.main_cd end as main_cd,
    case when JSON_QUERY(ps.tags,'$.limitedAmount') is null then 0 else 1 end as isLimit,
    case when JSON_QUERY(ps.tags,'$.exclusiveSephora') is null then 0 else 1 end as isSephora,
    case when JSON_QUERY(ps.tags,'$.newTag') is null then 0 else 1 end as isNew,
    case when JSON_QUERY(ps.tags,'$.exclusiveOnline') is null then 0 else 1 end as isOnline,
    case when JSON_QUERY(ps.tags,'$.memberPrice') is null then 0 else 1 end as isMember,
    case when JSON_QUERY(ps.tags,'$.prelaunch') is null then 0 else 1 end as isPrelaunch,
    case when JSON_QUERY(ps.tags,'$.discount') is null then 0 else 1 end as isDiscount,
    ps.is_default,
    ps.status,
    ps.product_id,
    upper(pp.product_name),
    pp.product_name_cn,
    pp.brand_id,
    upper(sm.brand_type),
    case when sm.brand is null then upper(pp.brand_name) else upper(sm.brand) end as brand_name,
    pp.brand_name_cn,
    ps.sku_type,
    upper(sm.sku_name_en) as sku_name,
    case when sm.sku_name_cn is null then ps.sku_name else sm.sku_name_cn end as sku_name_cn,
    upper(sm.category),
    upper(sm.range),
    upper(sm.segment),
    sm.target,
    sm.franchise,
    sm.first_function,
    sm.dchain_spec_status,      --新增字段
    sm.plant_sp_matl_status,    --新增字段
    ps.store as sale_store,
    ps.value as sale_value,
    ps.sap_price,
    pp.level1_id,
    pp.level2_id,
    pp.level3_id,
    pp.level1_name_cn,
    pp.level2_name_cn,
    pp.level3_name_cn,
    sa.att_31,
    sa.att_32,
    sa.att_33,
    sa.att_34,
    sa.att_35,
    sa.att_36,
    sa.att_37,
    sa.att_38,
    sa.att_39,
    sa.att_41,
    sa.att_42,
    sa.att_44,
    sa.att_47,
    sa.att_48,
    sa.att_49,
    sa.att_50,
    sa.att_51,
    sa.att_53,
    sa.att_54,
    sa.att_60,
    sa.att_61,
    sa.att_63,
    sa.att_66,
    sa.att_69,
    sa.att_72,
    sa.att_75,
    sa.att_78,
    case when JSON_VALUE(ps.sale_attr,'$.specImageUrl') is null then '' else JSON_VALUE(ps.sale_attr,'$.specImageUrl') end as image,
    ps.first_pubilsh_time as first_publish_time,
    ps.last_publish_time,
    current_timestamp
from
(
    select * from prod_sku
    union all
    select * from ve_prod_sku
) ps
left join
(
    select * from STG_Product.SKU_Mapping
) sm
on case when ps.sku_type <> 7 then ps.sku_code else ps.link_sku_code end = sm.sku_cd
left join
    DW_Product.DWS_Product_Info pp
on ps.product_id = pp.product_id
left join
(
    select sku_id, 
        [31] as att_31,
        [32] as att_32,
        [33] as att_33,
        [34] as att_34,
        [35] as att_35,
        [36] as att_36,
        [37] as att_37,
        [38] as att_38,
        [39] as att_39,
        [41] as att_41,
        [42] as att_42,
        [44] as att_44,
        [47] as att_47,
        [48] as att_48,
        [49] as att_49,
        [50] as att_50,
        [51] as att_51,
        [53] as att_53,
        [54] as att_54,
        [60] as att_60,
        [61] as att_61,
        [63] as att_63,
        [66] as att_66,
        [69] as att_69,
        [72] as att_72,
        [75] as att_75,
        [78] as att_78    
    from sku_attrval 
    PIVOT(
        max(value) for attr_id in ([31],[32],[33],[34],[35],[36],[37],[38],[39],[41],[42],[44],[47],[48],[49],[50],[51],[53],[54],[60],[61],[63],[66],[69],[72],[75],[78])
    ) as pvt
) sa
on case when ps.sku_type <> 7 then ps.sku_id else ps.link_sku_id end = sa.sku_id;
END

GO
