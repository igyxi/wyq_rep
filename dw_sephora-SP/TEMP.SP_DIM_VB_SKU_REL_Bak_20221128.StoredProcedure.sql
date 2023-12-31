/****** Object:  StoredProcedure [TEMP].[SP_DIM_VB_SKU_REL_Bak_20221128]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_VB_SKU_REL_Bak_20221128] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-01       tali           Initial Version
-- 2022-10-13       tali           add tags
-- 2022-10-17       wubin          update DWS_SKU_Profile_New->DWS_SKU_Profile
-- ========================================================================================
truncate table DWD.DIM_VB_SKU_REL;
insert into DWD.DIM_VB_SKU_REL
select
    c.sku_id,
    a.vb_sku_code,
    c.sku_name,
    c.sku_name_cn,
    c.sku_type,
    c.[status] as sku_status,
    c.tags,
    c.product_id,
    c.product_name,
    c.product_name_cn,
    c.brand_name,
    c.brand_name_cn,
    c.level1_name as category,
    a.bind_sku_code,
    b.sku_name as bind_sku_name,
    b.sku_name_cn as bind_sku_name_cn,
    b.sku_type as bind_sku_type,
    a.quantity as bind_sku_quantity,
    b.brand_id as bind_sku_brand_id,
    b.brand_name as bind_sku_brand_name,
    b.brand_name_cn as bind_sku_brand_name_cn,
    b.brand_type as bind_sku_brand_type,
    b.category as bind_sku_category,
    b.level1_id as bind_sku_level1_id,
    b.level1_name as bind_sku_level1_name,
    b.level2_id as bind_sku_level2_id,
    b.level2_name as bind_sku_level2_name,
    b.level3_id as bind_sku_level3_id,
    b.level3_name as bind_sku_level3_name,
    b.franchise as bind_sku_franchise,
    b.target as bind_sku_target,
    b.range as bind_sku_range,
    b.segment as bind_sku_segment,
    b.sub_segment as bin_sku_sub_segment,
    b.first_function as bind_sku_first_function,
    b.second_function as bind_sku_second_function,
    b.sap_price as bind_sku_sap_price,
    c.sap_price,
    c.sku_attr,
    c.first_publish_time,
    c.last_publish_time,
    c.sale_store,
    c.sale_value,
    c.is_default,
    case when ROW_NUMBER() over( partition by vb_sku_code order by 
        case when c.brand_name_cn = b.brand_name_cn and c.level1_name = b.level1_name and b.sku_type = 1 then 3
            when c.brand_name_cn = b.brand_name_cn and b.sku_type = 1 then 2 
            when c.level1_name = b.level1_name and b.sku_type = 1 then 1
            else 0 
        end desc, 
        b.sap_price desc) = 1 and b.sku_type = 1 then 1 else 0 
    end as is_main_code,
    -- case when c.brand_name_cn = b.brand_name_cn and b.sku_type = 1 then 1 
    --     when c.level1_name = b.level1_name and b.sku_type = 1 then 1
    --     else 0 
    -- end as is_main_code,
    a.create_time,
    a.update_time,
    CURRENT_TIMESTAMP as insert_timestamp
from
(
    select 
        vb_sku_code, bind_sku_code, quantity, create_time, update_time 
    from 
        STG_Product.PROD_VB_SKU_REL
    union all
    select 
        sku_code as vb_sku_code, link_sku_code as bind_sku_code, 1 as quantity, create_time, update_time 
    from 
        STG_Product.PROD_SKU 
    where 
        sku_type = 7 
        or sku_code like 'VG%'
) a
left join
    DW_Product.DWS_SKU_Profile b
on a.bind_sku_code = b.sku_code
join
    DW_Product.DWS_SKU_Profile c
on a.vb_sku_code = c.sku_code
;
END
GO
