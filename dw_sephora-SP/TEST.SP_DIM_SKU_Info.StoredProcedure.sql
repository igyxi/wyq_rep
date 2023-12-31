/****** Object:  StoredProcedure [TEST].[SP_DIM_SKU_Info]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_DIM_SKU_Info] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       Eric           Initial Version
-- 2022-01-17       Tali           update
-- 2022-01-27       Tali           delete collate
-- 2022-03-10       tali           update
-- 2022-07-25       tali           add eb_brand_type and eb_category
-- 2022-08-15       tali           add Local_Market_Description for sap_brand_type
-- 2022-09-01       tali           feat DWS_SKU_Profile_New
-- 2022-10-17       wubin          update DWS_SKU_Profile_New->DWS_SKU_Profile
-- 2022-11-21       wangzhichun    add category2
-- 2023-02-22       tali           add eb_sku_id
-- 2023-06-16       wangziming     delete governance field  and add column material_description
-- ========================================================================================

truncate table DWD.DIM_SKU_Info;
insert into DWD.DIM_SKU_Info
select
    a.id as sku_id,
    a.Material_Code as sku_code,
    a.Material_Description as sap_sku_name,
    a.Brand_Code,
    a.Brand_Description as brand_name,
    a.Sub_Brand_Code,
    a.Sub_brand_Description as sub_brand_name,
    isnull(b.Local_Market_Description, a.Market_Description) as market_name,
    a.Target_Description,
    a.Department_Code,
    a.Material_Function,
    a.Material_Function_Description,
    d.sku_id as eb_sku_id,
    d.sku_name as EB_sku_name,
    d.sku_name_cn as EB_sku_name_cn,
    null as eb_main_sku_code,
    d.product_id as EB_product_id,
    d.product_name as EB_product_name,
    d.product_name_cn as  EB_product_name_cn,
    d.brand_name_cn as EB_brand_name_cn,
    d.level1_id as EB_level1_id,
    d.level1_name as EB_level1_name,
    d.level2_id as EB_level2_id,
    d.level2_name as EB_level2_name,
    d.level3_id as EB_level3_id,
    d.level3_name as EB_level3_name,
    d.category2_level1_id as EB_category2_level1_id,
    d.category2_level1_name as EB_category2_level1_name,
    d.category2_level2_id as EB_category2_level2_id,
    d.category2_level2_name as EB_category2_level2_name,
    d.category2_level3_id as EB_category2_level3_id,
    d.category2_level3_name as EB_category2_level3_name,
    d.sku_attr as sku_attr,
    d.sale_value as EB_sale_value,
    c.skincare_function as CRM_skincare_function,
    c.price as CRM_price,
    sc.brand as brand,
    sc.category as  category,
    sc.franchise as franchise,
    d.target as target,
    sc.range as range,
    sc.segment as segment,
    sc.sub_segment as sub_segment,
    sc.first_function as first_function,
    sc.second_function as second_function,
	b.material_description as material_description,
    'SAP' as source,
    CURRENT_TIMESTAMP AS INSERT_TIMESTAMP
from 
    [ODS_SAP].[Dim_Material] a
left join 
(
    select distinct material, Local_Market_Description,material_description from [ODS_SAP].[Material_Status] where Country_Key = 'CN'
)b 
on a.material_code =b.material
left join  
(
    select *, ROW_NUMBER() over(partition by sku_code order by sku_id desc) AS rownum from DW_CRM.DIM_SKU
)c  
on 
    a.material_code = c.sku_code 
and rownum=1
left join 
    DW_Product.DWS_SKU_Profile d 
on a.material_code = d.sku_code
left join
    STG_Product.SKU_Classification sc
on a.material_code = sc.sku_code

union all
select
    d.sku_id as sku_id,
    d.vb_sku_code as sku_code,
    d.sku_name,
    null as Brand_Code,
    null as Brand_Description,
    null as Sub_Brand_Code,
    null as Sub_brand_Description,
    null as Market_Description,
    null as Target_Description,
    null as Department_Code,
    null as Material_Function,
    null as Material_Function_Description,
    d.sku_id as eb_sku_id,
    d.sku_name as EB_sku_name,
    d.sku_name_cn as EB_sku_name_cn,
    d.bind_sku_code as eb_main_sku_code,
    d.product_id as EB_product_id,
    d.product_name as EB_product_name,
    d.product_name_cn as  EB_product_name_cn,
    d.bind_sku_brand_name_cn as EB_brand_name_cn,
    d.bind_sku_level1_id as EB_level1_id,
    d.bind_sku_level1_name as EB_level1_name,
    d.bind_sku_level2_id as EB_level2_id,
    d.bind_sku_level2_name as EB_level2_name,
    d.bind_sku_level3_id as EB_level3_id,
    d.bind_sku_level3_name as EB_level3_name,
    d.bind_sku_category2_level1_id as EB_category2_level1_id,
    d.bind_sku_category2_level1_name as EB_category2_level1_name,
    d.bind_sku_category2_level2_id as EB_category2_level2_id,
    d.bind_sku_category2_level2_name as EB_category2_level2_name,
    d.bind_sku_category2_level3_id as EB_category2_level3_id,
    d.bind_sku_category2_level3_name as EB_category2_level3_name,
    d.sku_attr as eb_sku_attr,
    d.sale_value as EB_sale_value,
    null as CRM_skincare_function,
    null as CRM_price,
    d.bind_sku_brand_name as brand,
    d.bind_sku_category as category,
    d.bind_sku_franchise as franchise,
    d.bind_sku_target as target,
    d.bind_sku_range as range,
    d.bind_sku_segment as segment,
    d.bind_sku_sub_segment as sub_segment,
    d.bind_sku_first_function as first_function,
    d.bind_sku_second_function as second_function,
	null as material_description,
    'OMS' as source,
    CURRENT_TIMESTAMP AS INSERT_TIMESTAMP
from  
(
    select *, ROW_NUMBER() over(partition by vb_sku_code order by is_main_code desc) rownum from DWD.DIM_VB_SKU_REL
) d
-- left join
--     STG_Product.SKU_Classification sc
-- on d.bind_sku_code = sc.sku_code
where 
    d.rownum = 1

union all
select
    c.sku_id,
    c.sku_code,
    c.sku_name,
    null as Brand_Code,
    null as Brand_Description,
    null as Sub_Brand_Code,
    null as Sub_brand_Description,
    null as Market_Description,
    null as Target_Description,
    null as Department_Code,
    null as Material_Function,
    null as Material_Function_Description,
    d.sku_id as eb_sku_id,
    d.sku_name as EB_sku_name,
    d.sku_name_cn as EB_sku_name_cn,
    null as eb_main_sku_code,
    d.product_id as EB_product_id,
    d.product_name as EB_product_name,
    d.product_name_cn as  EB_product_name_cn,
    d.brand_name_cn as EB_brand_name_cn,
    d.level1_id as EB_level1_id,
    d.level1_name as EB_level1_name,
    d.level2_id as EB_level2_id,
    d.level2_name as EB_level2_name,
    d.level3_id as EB_level3_id,
    d.level3_name as EB_level3_name,
    d.category2_level1_id as EB_category2_level1_id,
    d.category2_level1_name as EB_category2_level1_name,
    d.category2_level2_id as EB_category2_level2_id,
    d.category2_level2_name as EB_category2_level2_name,
    d.category2_level3_id as EB_category2_level3_id,
    d.category2_level3_name as EB_category2_level3_name,
    d.sku_attr as eb_sku_attr,
    d.sale_value as EB_sale_value,
    c.skincare_function as CRM_skincare_function,
    c.price as CRM_price,
    sc.brand as brand,
    sc.category as category,
    sc.franchise as franchise,
    c.target as target,
    sc.range as range,
    sc.segment as segment,
    sc.sub_segment as sub_segment,
    sc.first_function as first_function,
    sc.second_function as second_function,
	null as material_description,
    'CRM' as source,
    CURRENT_TIMESTAMP AS INSERT_TIMESTAMP
from 
(
    select *, ROW_NUMBER() over(partition by sku_code order by sku_id desc) AS rownum from DW_CRM.DIM_SKU
) c 
left join
    [ODS_SAP].[Dim_Material] a 
on a.material_code = c.sku_code
left join 
    DW_Product.DWS_SKU_Profile d
on d.sku_code = c.sku_code 
left join
    STG_Product.SKU_Classification sc
on c.sku_code = sc.sku_code
where 
    a.material_code is null
and c.rownum=1
END
GO
