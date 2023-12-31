/****** Object:  StoredProcedure [DW_Product].[SP_DWS_Offline_SKU_Mapping]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Product].[SP_DWS_Offline_SKU_Mapping] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-31       tali        Initial Version
-- 2022-09-14       wangzhichun  add distinct
-- ========================================================================================
truncate table [DW_Product].[DWS_Offline_SKU_Mapping];
insert into [DW_Product].[DWS_Offline_SKU_Mapping]
select 
    a.material as sku_code, 
    a.additional_description,
    a.material_description,
    b.category,
    a.category_name,
    a.brand,
    bt.Material as brand_type,
    c.franchise,
    c.range,
    c.segment,
    c.first_function,
    a.target_description,
    a.sls_typ_desc,
    a.range_desc,
    a.pp,
    a.moving_price,
    a.dchain_spec_status,   --新增字段
    a.plant_sp_matl_status,  --新增字段
    current_timestamp as insert_timestamp 
from 
    STG_Product.PROD_CN_Database a
left join
    STG_Product.PROD_Category_Mapping b
on a.category_name = b.category_sub
left join 
    STG_Product.SKU_Classification c 
on a.material = c.sku_code
left join 
(
    select 
        distinct 
        material,
        Local_Market_Description as brand_type
    from 
        ODS_SAP.Material_Status
    where Country_Key = 'CN'

) bt
on a.material = bt.Material
where
    a.category_name in ('SKINCARE','HAIR','MAKE UP','FRAGRANCE','MAKE UP ACCESSORIES','SKINCARE ACCESSORIES','HAIR ACCESSORIES','BATH & GIFT','WELLNESS')
end

GO
