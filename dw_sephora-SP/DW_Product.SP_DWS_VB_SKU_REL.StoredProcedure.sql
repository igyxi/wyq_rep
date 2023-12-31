/****** Object:  StoredProcedure [DW_Product].[SP_DWS_VB_SKU_REL]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Product].[SP_DWS_VB_SKU_REL] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-22       tali           Initial Version
-- ========================================================================================
truncate table DW_Product.DWS_VB_SKU_REL;
insert into DW_Product.DWS_VB_SKU_REL
select
    c.sku_id,
    a.vb_sku_code,
    c.sku_name,
    c.sku_name_cn,
    c.sku_type,
    c.[status] as sku_status,
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
    b.brand_name as bind_sku_brand_name,
    b.brand_name_cn as bind_sku_brand_name_cn,
    b.brand_type as bind_sku_brand_type,
    b.category as bind_sku_category,
    b.sap_price,
    case when ROW_NUMBER() over( partition by vb_sku_code order by 
        case when c.brand_name_cn = b.brand_name_cn and b.sku_type = 1 then 1 
            when c.level1_name = b.level1_name and b.sku_type = 1 then 1
            else 0 
        end desc, 
        b.sap_price desc) = 1 and b.sku_type = 1 then 1 else 0 end as is_main_code,
    -- case when c.brand_name_cn = b.brand_name_cn and b.sku_type = 1 then 1 
    --     when c.level1_name = b.level1_name and b.sku_type = 1 then 1
    --     else 0 
    -- end as is_main_code,
    a.create_time,
    a.update_time,
    CURRENT_TIMESTAMP as insert_timestamp
from
(
    select vb_sku_code, bind_sku_code, quantity, create_time, update_time from STG_Product.PROD_VB_SKU_REL
    union all
    select sku_code as vb_sku_code, link_sku_code as bind_sku_code, 1 as quantity, create_time, update_time from STG_Product.PROD_SKU where sku_type = 7
) a
left join
    DW_Product.DWS_SKU_Profile_New b
on a.bind_sku_code = b.sku_code
join
    DW_Product.DWS_SKU_Profile_New c
on a.vb_sku_code = c.sku_code

END

GO
