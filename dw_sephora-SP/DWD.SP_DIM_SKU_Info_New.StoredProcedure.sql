/****** Object:  StoredProcedure [DWD].[SP_DIM_SKU_Info_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_SKU_Info_New] AS
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
-- 2023-03-21       houshuangqiang add Governence.DIM_SKU_Info_Manual
-- ========================================================================================

truncate table DWD.DIM_SKU_Info_New;
insert into [DWD].DIM_SKU_Info_New
select
    a.id as sku_id,
    a.Material_Code as sku_code,
    coalesce(manual.sap_sku_name, a.Material_Description) as sap_sku_name,
    a.Material_Store_Description as sap_store_description,
    a.Material_Group as sap_group_code,
    a.Material_Hierarchy_Code as sap_hierarchy_code,
    a.EAN_Code as sap_ean_code,
    a.Material_Create_Date as sap_create_date,
    coalesce(manual.sap_brand_code,a.Brand_Code) as sap_brand_code,
    coalesce(manual.sap_brand_name,a.Brand_Description) as sap_brand_name,
    a.Sub_Brand_Code,
    a.Sub_brand_Description as sub_brand_name,
    a.Market_Code,
    isnull(b.Local_Market_Description, a.Market_Description) as market_name,
    a.Market_Sort,
    a.Target_Code,
    a.Target_Description,
    a.Target_Sort,
    a.Category_Code,
    a.Category_Description as category_name,
    a.Category_Sort,
    a.TO_Ex,
    a.Sales_Nature_Code,
    a.Sales_Nature_Description,
    a.Turnsales_Type_Display_Order,
    a.Range_Code,
    a.Range_Description,
    a.Range_Sort,
    a.Nature_Code,
    a.Nature_Description,
    a.Nature_Sort,
    a.Department_Code,
    a.Department_Sort,
    a.Department_Description,
    a.Loading_Group,
    a.Loading_Description,
    a.PCB,
    a.Lock,
    a.Purchase_Classification_Part1,
    a.Purchase_Classification_Part2,
    a.Purchase_Classification_Part3,
    a.Material_Type,
    a.Material_Type_Description,
    a.Material_Function,
    a.Material_Function_Description,
    a.Sub_Franchise_Code,
    a.Sub_Franchise_Description,
    a.Finish,
    a.Finish_Description,
    a.Container,
    a.Container_Description,
    a.SPF,
    a.SPF_Description,
    a.Skin_type,
    a.Skin_type_Description,
    a.Asso_Category_Code,
    a.Asso_Category_Desc,
    a.Market_Area,
    d.sku_id as eb_sku_id,
    coalesce(manual.eb_sku_name, d.sku_name) as EB_sku_name,
    coalesce(manual.eb_sku_name_cn, d.sku_name_cn) as EB_sku_name_cn,
    null as eb_main_sku_code,
    -- d.main_cd as eb_main_sku_code,
    d.sku_type as EB_sku_type,
    d.product_id as EB_product_id,
    d.product_name as EB_product_name,
    d.product_name_cn as  EB_product_name_cn,
    d.brand_type,
    d.brand_id as eb_brand_id,
    coalesce(manual.eb_brand_name, d.brand_name) as eb_brand_name,
    coalesce(manual.eb_brand_name_cn, d.brand_name_cn) as EB_brand_name_cn,
    d.category as EB_category,
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
    d.first_function as EB_first_function,
    d.sku_attr as sku_attr,
    d.first_publish_time as EB_first_publish_time,
    d.last_publish_time as EB_last_publish_time,
    d.franchise as EB_franchise,
    d.sale_store as EB_sale_store,
    d.sale_value as EB_sale_value,
    d.segment as EB_segment,
    d.tags as eb_tags,
    d.is_default as EB_is_default,
    d.status as EB_status,
    d.sap_price as EB_sap_price,
    c.sku_name as CRM_sku_name,
    c.brand as CRM_brand,
    c.brand_type as CRM_brand_type,
    c.category as CRM_category,
    c.target as crm_target,
    c.range as crm_range,
    c.segment as CRM_Segment,
    c.skincare_function as CRM_skincare_function,
    c.product_line as CRM_Product_Line,
    c.price as CRM_price,
    c.is_offer as CRM_isoffer,
    c.is_men as CRM_is_men,
    coalesce(manual.brand, sc.brand) as brand,
    coalesce(manual.category, sc.category) as  category,
    sc.franchise as franchise,
    d.target as target,
    coalesce(manual.range, sc.range) as range,
    coalesce(manual.segment, sc.segment) as segment,
    coalesce(manual.sub_segment, sc.sub_segment) as sub_segment,
    sc.first_function as first_function,
    sc.second_function as second_function,
    'SAP' as source,
    CURRENT_TIMESTAMP AS INSERT_TIMESTAMP
from
    [ODS_SAP].[Dim_Material] a
left join
(
    select distinct material, Local_Market_Description from [ODS_SAP].[Material_Status] where Country_Key = 'CN'
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
left join
    Governence.DIM_SKU_Info_Manual manual
on  a.Material_Code = manual.sku_code

union all
select
    d.sku_id as sku_id,
    d.vb_sku_code as sku_code,
    coalesce(manual.sap_sku_name, d.sku_name) as sap_sku_name,
    null as Material_Store_Description,
    null as Material_Group,
    null as Material_Hierarchy_Code,
    null as EAN_Code,
    null as Material_Create_Date,
    manual.sap_brand_code as sap_brand_code,
    manual.sap_brand_name as sap_brand_name,
    null as Sub_Brand_Code,
    null as Sub_brand_Description,
    null as Market_Code,
    null as Market_Description,
    null as Market_Sort,
    null as Target_Code,
    null as Target_Description,
    null as Target_Sort,
    null as Category_Code,
    null as Category_Description,
    null as Category_Sort,
    null as TO_Ex,
    null as Sales_Nature_Code,
    null as Sales_Nature_Description,
    null as Turnsales_Type_Display_Order,
    null as Range_Code,
    null as Range_Description,
    null as Range_Sort,
    null as Nature_Code,
    null as Nature_Description,
    null as Nature_Sort,
    null as Department_Code,
    null as Department_Sort,
    null as Department_Description,
    null as Loading_Group,
    null as Loading_Description,
    null as PCB,
    null as Lock,
    null as Purchase_Classification_Part1,
    null as Purchase_Classification_Part2,
    null as Purchase_Classification_Part3,
    null as Material_Type,
    null as Material_Type_Description,
    null as Material_Function,
    null as Material_Function_Description,
    null as Sub_Franchise_Code,
    null as Sub_Franchise_Description,
    null as Finish,
    null as Finish_Description,
    null as Container,
    null as Container_Description,
    null as SPF,
    null as SPF_Description,
    null as Skin_type,
    null as Skin_type_Description,
    null as Asso_Category_Code,
    null as Asso_Category_Desc,
    null as Market_Area,
    d.sku_id as eb_sku_id,
    coalesce(manual.eb_sku_name, d.sku_name) as EB_sku_name,
    coalesce(manual.eb_sku_name_cn, d.sku_name_cn) as EB_sku_name_cn,
    d.bind_sku_code as eb_main_sku_code,
    d.sku_type as EB_sku_type,
    d.product_id as EB_product_id,
    d.product_name as EB_product_name,
    d.product_name_cn as  EB_product_name_cn,
    d.bind_sku_brand_type,
    d.bind_sku_brand_id as EB_brand_id,
    coalesce(manual.eb_brand_name, d.bind_sku_brand_name) as eb_brand_name,
    coalesce(manual.eb_brand_name_cn, d.bind_sku_brand_name_cn) as EB_brand_name_cn,
    d.bind_sku_category as eb_category,
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
    null as EB_first_function,
    -- d.bind_sku_first_function as EB_first_function,
    d.sku_attr as eb_sku_attr,
    d.first_publish_time as EB_first_publish_time,
    d.last_publish_time as EB_last_publish_time,
    null as EB_franchise,
    -- d.bind_sku_franchise as EB_franchise,
    d.sale_store as EB_sale_store,
    d.sale_value as EB_sale_value,
    null as EB_segment,
    -- d.segment as EB_segment,
    d.tags as EB_tags,
    d.is_default as EB_is_default,
    d.sku_status as EB_status,
    d.sap_price as EB_sap_price,
    null as CRM_sku_name,
    null as CRM_brand,
    null as CRM_brand_type,
    null as CRM_category,
    null as crm_target,
    null as crm_range,
    null as CRM_Segment,
    null as CRM_skincare_function,
    null as CRM_Product_Line,
    null as CRM_price,
    null as CRM_isoffer,
    null as CRM_is_men,
    coalesce(manual.brand, d.bind_sku_brand_name) as brand,
    coalesce(manual.category, d.bind_sku_category) as category,
    d.bind_sku_franchise as franchise,
    d.bind_sku_target as target,
    coalesce(manual.range, d.bind_sku_range) as range,
    coalesce(manual.segment, d.bind_sku_segment) as segment,
    coalesce(manual.sub_segment, d.bind_sku_sub_segment) as sub_segment,
    d.bind_sku_first_function as first_function,
    d.bind_sku_second_function as second_function,
    'OMS' as source,
    CURRENT_TIMESTAMP AS INSERT_TIMESTAMP
from
(
    select *, ROW_NUMBER() over(partition by vb_sku_code order by is_main_code desc) rownum from DWD.DIM_VB_SKU_REL
) d
-- left join
--     STG_Product.SKU_Classification sc
-- on d.bind_sku_code = sc.sku_code
left join
    Governence.DIM_SKU_Info_Manual manual
on  d.vb_sku_code = manual.sku_code
where
    d.rownum = 1

union all
select
    c.sku_id,
    c.sku_code,
    coalesce(manual.sap_sku_name, c.sku_name) as sap_sku_name,
    null as Material_Store_Description,
    null as Material_Group,
    null as Material_Hierarchy_Code,
    null as EAN_Code,
    null as Material_Create_Date,
    manual.sap_brand_code,
    manual.sap_brand_name,
    null as Sub_Brand_Code,
    null as Sub_brand_Description,
    null as Market_Code,
    null as Market_Description,
    null as Market_Sort,
    null as Target_Code,
    null as Target_Description,
    null as Target_Sort,
    null as Category_Code,
    null as Category_Description,
    null as Category_Sort,
    null as TO_Ex,
    null as Sales_Nature_Code,
    null as Sales_Nature_Description,
    null as Turnsales_Type_Display_Order,
    null as Range_Code,
    null as Range_Description,
    null as Range_Sort,
    null as Nature_Code,
    null as Nature_Description,
    null as Nature_Sort,
    null as Department_Code,
    null as Department_Sort,
    null as Department_Description,
    null as Loading_Group,
    null as Loading_Description,
    null as PCB,
    null as Lock,
    null as Purchase_Classification_Part1,
    null as Purchase_Classification_Part2,
    null as Purchase_Classification_Part3,
    null as Material_Type,
    null as Material_Type_Description,
    null as Material_Function,
    null as Material_Function_Description,
    null as Sub_Franchise_Code,
    null as Sub_Franchise_Description,
    null as Finish,
    null as Finish_Description,
    null as Container,
    null as Container_Description,
    null as SPF,
    null as SPF_Description,
    null as Skin_type,
    null as Skin_type_Description,
    null as Asso_Category_Code,
    null as Asso_Category_Desc,
    null as Market_Area,
    d.sku_id as eb_sku_id,
    coalesce(manual.eb_sku_name, d.sku_name) as EB_sku_name,
    coalesce(manual.eb_sku_name_cn, d.sku_name_cn) as EB_sku_name_cn,
    null as eb_main_sku_code,
    d.sku_type as EB_sku_type,
    d.product_id as EB_product_id,
    d.product_name as EB_product_name,
    d.product_name_cn as  EB_product_name_cn,
    d.brand_type,
    d.brand_id as EB_brand_id,
    coalesce(manual.eb_brand_name, d.brand_name) as eb_brand_name,
    coalesce(manual.eb_brand_name_cn, d.brand_name_cn) as EB_brand_name_cn,
    d.category as EB_category,
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
    d.first_function as EB_first_function,
    d.sku_attr as eb_sku_attr,
    d.first_publish_time as EB_first_publish_time,
    d.last_publish_time as EB_last_publish_time,
    d.franchise as EB_franchise,
    d.sale_store as EB_sale_store,
    d.sale_value as EB_sale_value,
    d.segment as EB_segment,
    d.tags as EB_tags,
    d.is_default as EB_is_default,
    d.status as EB_status,
    d.sap_price as EB_sap_price,
    c.sku_name as CRM_sku_name,
    c.brand as CRM_brand,
    c.brand_type as CRM_brand_type,
    c.category as CRM_category,
    c.target as crm_target,
    c.range as crm_range,
    c.Segment as CRM_Segment,
    c.skincare_function as CRM_skincare_function,
    c.Product_Line as CRM_Product_Line,
    c.price as CRM_price,
    c.is_offer as CRM_isoffer,
    c.is_men as CRM_is_men,
    coalesce(manual.brand, sc.brand) as brand,
    coalesce(manual.category, sc.category) as category,
    sc.franchise as franchise,
    c.target as target,
    coalesce(manual.range, sc.range) as range,
    coalesce(manual.segment, sc.segment) as segment,
    coalesce(manual.sub_segment, sc.sub_segment) as sub_segment,
    sc.first_function as first_function,
    sc.second_function as second_function,
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
left join
    Governence.DIM_SKU_Info_Manual manual
on c.sku_code = manual.sku_code
where
    a.material_code is null
and c.rownum=1

END


GO
