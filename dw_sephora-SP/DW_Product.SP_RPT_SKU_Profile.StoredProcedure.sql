/****** Object:  StoredProcedure [DW_Product].[SP_RPT_SKU_Profile]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Product].[SP_RPT_SKU_Profile] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-11       wubin          Initial Version
-- ========================================================================================
truncate table DW_Product.RPT_SKU_Profile;
with prod_sku as
(
    select
        a.sku_id,
        coalesce(a.sku_code,b.sku_code) as sku_code,
        a.link_sku_code,
        a.tags,
        a.store,
        a.sku_type,
        a.value,
        a.sap_price,
        a.sale_attr
    from
    (
        select
            sku_id,
            sku_code,
            link_sku_code,
            tags,
            store,
            sku_type,
            value,
            sap_price,
            sale_attr,
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
        a.link_sku_code,
        ps.tags,
        ps.store,
        a.sku_type,
        ps.value,
        a.sap_price,
        ps.sale_attr
    from
    (
        select
            sku_id,
            sku_code,
            link_sku_code,
            tags,
            store,
            sku_type,
            value,
            sap_price,
            sale_attr,
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
)


insert into DW_Product.RPT_SKU_Profile
select
    pd.sku_id,
    sku.sku_code as sku_cd,
    sku.eb_main_sku_code as main_cd,
    case when json_query(pd.tags,'$.limitedAmount') is null then 0 else 1 end as islimit,
    case when json_query(pd.tags,'$.exclusiveSephora') is null then 0 else 1 end as issephora,
    case when json_query(pd.tags,'$.newTag') is null then 0 else 1 end as isnew,
    case when json_query(pd.tags,'$.exclusiveOnline') is null then 0 else 1 end as isonline,
    case when json_query(pd.tags,'$.memberPrice') is null then 0 else 1 end as ismember,
    case when json_query(pd.tags,'$.prelaunch') is null then 0 else 1 end as isprelaunch,
    case when json_query(pd.tags,'$.discount') is null then 0 else 1 end as isdiscount,
    sku.eb_is_default as is_default,
    sku.eb_status as status,
    sku.eb_product_id as product_id,
    sku.eb_product_name as product_name,
    sku.eb_product_name_cn as product_name_cn,
    sku.eb_brand_id as brand_id,
    sku.eb_brand_type as brand_type,
    sku.eb_brand_name as brand_name,
    sku.eb_brand_name_cn as brand_name_cn,
    sku.eb_sku_type as sku_type,
    sku.eb_sku_name as sku_name,
    sku.eb_sku_name_cn as sku_name_cn,
    sku.category as category,
    sku.range as range_name,
    sku.segment as segment,
    sku.target,
    sku.eb_franchise as franchise,
    sku.first_function,
    cn.dchain_spec_status,      --新增字段
    cn.plant_sp_matl_status,    --新增字段
    pd.store as sale_store,
    pd.value as sale_value,
    pd.sap_price as sap_price,
    sku.eb_level1_id as level1_id,
    sku.eb_level2_id as level2_id,
    sku.eb_level3_id as level3_id,
    sku.eb_level1_name as level1_name,
    sku.eb_level2_name as level2_name,
    sku.eb_level3_name as level3_name,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."31"') else null end as att_31,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."32"') else null end as att_32,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."33"') else null end as att_33,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."34"') else null end as att_34,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."35"') else null end as att_35,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."36"') else null end as att_36,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."37"') else null end as att_37,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."38"') else null end as att_38,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."39"') else null end as att_39,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."41"') else null end as att_41,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."42"') else null end as att_42,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."44"') else null end as att_44,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."47"') else null end as att_47,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."48"') else null end as att_48,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."49"') else null end as att_49,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."50"') else null end as att_50,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."51"') else null end as att_51,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."53"') else null end as att_53,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."54"') else null end as att_54,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."60"') else null end as att_60,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."61"') else null end as att_61,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."63"') else null end as att_63,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."66"') else null end as att_66,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."69"') else null end as att_69,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."72"') else null end as att_72,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."75"') else null end as att_75,
    case when sku.eb_attr is not null then json_value(sku.eb_attr,'$."78"') else null end as att_78,
    case when json_value(pd.sale_attr,'$.specImageUrl') is null then ''
         else json_value(pd.sale_attr,'$.specImageUrl')
    end as image,
    sku.eb_first_publish_time as first_publish_time,
    sku.eb_last_publish_time as last_publish_time,
    current_timestamp as insert_timestamp
from
(
    select
        sku_id,
        sku_code,
        link_sku_code,
        tags,
        store,
        sku_type,
        value,
        sap_price,
        sale_attr
    from prod_sku
    union all
    select
        sku_id,
        sku_code,
        link_sku_code,
        tags,
        store,
        sku_type,
        value,
        sap_price,
        sale_attr
     from ve_prod_sku
) pd
inner join
	dwd.dim_sku_info sku
on
  case when pd.sku_type <> 7 then pd.sku_code else pd.link_sku_code end = sku.sku_code
left join
  STG_Product.PROD_CN_Database cn
on
  cn.material = pd.sku_code
;

END
GO
