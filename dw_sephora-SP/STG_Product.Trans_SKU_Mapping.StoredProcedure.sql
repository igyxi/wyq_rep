/****** Object:  StoredProcedure [STG_Product].[Trans_SKU_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[Trans_SKU_Mapping] @dt [varchar](10) AS 
BEGIN
truncate table [STG_Product].[SKU_Mapping];
insert into [STG_Product].[SKU_Mapping]
select
    case when trim(sku_cd) in ('null', '') then null else trim(sku_cd) end as sku_cd,
    case when trim(main_cd) in ('null', '') then null else trim(main_cd) end as main_cd,
    case when trim(sku_name_en) in ('null', '') then null else trim(sku_name_en) end as sku_name_en,
    case when trim(sku_name_cn) in ('null', '') then null else trim(sku_name_cn) end as sku_name_cn,
    case when trim(category) in ('null', '') then null else trim(category) end as category,
    case when trim(category_sub) in ('null', '') then null else trim(category_sub) end as category_sub,
    case when trim(brand) in ('null', '') then null else trim(brand) end as brand,
    case when trim(brand_type) in ('null', '') then null else trim(brand_type) end as brand_type,
    case when trim(franchise) in ('null', '') then null else trim(franchise) end as franchise,
    case when trim(range) in ('null', '') then null else trim(range) end as range,
    case when trim(segment) in ('null', '') then null else trim(segment) end as segment,
    case when trim(first_function) in ('null', '') then null else trim(first_function) end as first_function,
    case when trim(target) in ('null', '') then null else trim(target) end as target,
    case when trim(sls_type_cntable) in ('null', '') then null else trim(sls_type_cntable) end as sls_type_cntable,
    case when trim(range_cntable) in ('null', '') then null else trim(range_cntable) end as range_cntable,
    case when trim(dchain_spec_status) in ('null', '') then null else trim(dchain_spec_status) end as dchain_spec_status,
    case when trim(plant_sp_matl_status) in ('null', '') then null else trim(plant_sp_matl_status) end as plant_sp_matl_status,
    current_timestamp as insert_timestamp
from 
    ODS_Product.SKU_Mapping
where
    dt=@dt;
update statistics [STG_Product].[SKU_Mapping];
END
GO
