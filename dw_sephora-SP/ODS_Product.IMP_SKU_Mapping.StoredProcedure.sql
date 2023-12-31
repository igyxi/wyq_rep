/****** Object:  StoredProcedure [ODS_Product].[IMP_SKU_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Product].[IMP_SKU_Mapping] @dt [varchar](10) AS 
BEGIN
delete from [ODS_Product].[SKU_Mapping] where dt=@dt;
insert into [ODS_Product].[SKU_Mapping]
   select
        sku_cd,
        main_cd,
        sku_name_en,
        sku_name_cn,
        category,
        category_sub,
        brand,
        brand_type,
        franchise,
        range,
        segment,
        first_function,
        target,
        sls_type_cntable,
        range_cntable,
        dchain_spec_status,
        plant_sp_matl_status,
        @dt as dt,
        current_timestamp as insert_timestamp
    from 
        ODS_Product.WRK_SKU_Mapping
    union all
    select 
        a.sku_cd,
        a.main_cd,
        a.sku_name_en,
        a.sku_name_cn,
        a.category,
        a.category_sub,
        a.brand,
        a.brand_type,
        a.franchise,
        a.range,
        a.segment,
        a.first_function,
        a.target,
        a.sls_type_cntable,
        a.range_cntable,
        a.dchain_spec_status,
        a.plant_sp_matl_status,
        @dt as dt,
        current_timestamp as insert_timestamp
    from 
    (
        select * from ODS_Product.SKU_Mapping where dt = cast(dateadd(d,-7,@dt) as date)
    ) a
    left join 
        ODS_Product.WRK_SKU_Mapping b
    on a.sku_cd = b.sku_cd 
    where b.sku_cd is null;
update statistics [ODS_Product].[SKU_Mapping];
end
GO
