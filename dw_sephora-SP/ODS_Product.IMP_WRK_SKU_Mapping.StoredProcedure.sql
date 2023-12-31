/****** Object:  StoredProcedure [ODS_Product].[IMP_WRK_SKU_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Product].[IMP_WRK_SKU_Mapping] @dt [varchar](10) AS 
BEGIN
truncate table [ODS_Product].[WRK_SKU_Mapping];
with sap_sku as
(
    select distinct 
        t.material, 
        t.additional_description,
        t.brand,
        t.material_description,
        c.category,
        t.category_name,
        t.target_description,
        t.sls_typ_desc,
        t.range_desc,
        t.rsp,
        t.dchain_spec_status,    --新增字段
        t.plant_sp_matl_status   --新增字段
    from 
    (
        select 
            *
        from
            ODS_Product.PROD_CN_Database 
        where 
            dt = @dt
        and
            category_name in ('SKINCARE','HAIR','MAKE UP','FRAGRANCE','MAKE UP ACCESSORIES','SKINCARE ACCESSORIES','HAIR ACCESSORIES','BATH & GIFT','WELLNESS')
    ) t
    left join
        ODS_Product.PROD_Category_Mapping c
    on 
        c.category_sub = t.category_name
),
vb_sku as
(
    select
        v.vb_sku_code as sku_code,
        v.bind_sku_code as main_cd,
        -- '' as additional_description,
        case when v.name_en is null or trim(v.name_en) = '' then t.brand else v.name_en end as brand,
        case when v.name_en is not null and v.name_en <> t.brand then 0
             else 1 
        end as brand_flag,
        v.product_name as material_description,
        -- t.category_name,
        coalesce(v.category,t.category) as category,
        t.category_name,
        case when v.category is not null and v.category <> t.category then 0
             else 1
        end as category_flag,
        -- '' as t.target_description,
        -- '' as t.sls_typ_desc,
        -- '' as t.range_desc,
        -- row_number() over(partition by v.vb_sku_code order by cast(t.rsp as double) desc) rn
        try_cast(t.rsp as decimal(20,5)) as rsp,
        count(1) over(partition by v.vb_sku_code,t.category_name) as category_cnt
    from 
    (
        select 
            vl.*, 
            c.category 
        from 
        (
            select
                *
            from
                ODS_Product.PROD_VB_List
            where
                dt = @dt
        ) vl 
        left join 
            ODS_Product.PROD_Category_Mapping c 
        on 
            vl.classification = c.category_level1_cn
    ) v
    join 
    (
        select * from sap_sku where brand not in ('BRGWP', 'FIDELITE', 'GWP', 'Other Brand Service')
    ) t
    on v.bind_sku_code = t.material
)

insert into [ODS_Product].[WRK_SKU_Mapping]
select
    ocd.sku_code as sku_cd,
    ocd.main_cd,
    ocd.additional_description as sku_name_en,
    ocd.material_description as sku_name_cn,
    ocd.category,
    ocd.category_name as category_sub,
    ocd.brand,
    obt.market as brand_type,
    ocd.franchise,
    ocd.range,
    ocd.segment,
    ocd.first_function,
    ocd.target_description as target,
    ocd.sls_typ_desc as sls_type_cntable,
    ocd.range_desc as range_cntable,
    ocd.dchain_spec_status,        --新增字段
    ocd.plant_sp_matl_status,      --新增字段
    current_timestamp as insert_timestamp 
from
(
    select 
        sku_code,
        main_cd,
        '' as additional_description,
        brand,
        material_description,
        category,
        category_name,
        '' as target_description,
        '' as sls_typ_desc,
        '' as range_desc,
        '' as franchise,
        '' as range,
        '' as segment,
        '' as first_function,
        '' as dchain_spec_status,
        '' as plant_sp_matl_status
    from 
    (
        select *, row_number() over(partition by sku_code order by category_flag desc, category_cnt desc, brand_flag desc, rsp desc) as rn from vb_sku
    ) t
    where t.rn = 1
    union all
    select 
        s.material as sku_code, 
        s.material as main_cd, 
        s.additional_description,
        s.brand,
        s.material_description,
        s.category,
        s.category_name,
        s.target_description,
        s.sls_typ_desc,
        s.range_desc,
        oc.franchise,
        oc.range,
        oc.segment,
        oc.first_function,
        s.dchain_spec_status,   --新增字段
        s.plant_sp_matl_status  --新增字段
    from 
    (
        select *, row_number() over(partition by material order by additional_description desc) as rn from sap_sku 
    )s
    left join 
    (
        select 
            *
        from
            ODS_Product.PROD_Classification 
        where
            dt=@dt
    )oc 
    on s.material = oc.mat
    where s.rn = 1
) ocd
left join 
(
    select distinct sap_brand, market from ODS_Product.PROD_Brand_Type where dt=@dt
) obt 
on ocd.brand = obt.sap_brand;
update statistics [ODS_Product].[WRK_SKU_Mapping];
end
GO
