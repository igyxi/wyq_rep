/****** Object:  StoredProcedure [TEMP].[SP_DWS_SmartBA_Order_Package_Bak_20220928]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_SmartBA_Order_Package_Bak_20220928] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-04       wangzhichun    Initial Version
-- ========================================================================================
truncate table [DW_SmartBA].[DWS_SmartBA_Order_Package];
insert into [DW_SmartBA].[DWS_SmartBA_Order_Package]
select 
    a.id as order_package_id,
    b.id as order_package_detail_id,
    a.order_code as sales_order_number,
    a.po_code as purchase_order_number,
    a.po_amount as payed_amount,
    a.type as [type],
    a.express_code as express_code,
    a.express_name as express_name,
    a.po_type,
    a.shipping_time as shipping_time,
    a.finish_time as finish_time,
    a.tenant_id as tenant_id,
    b.sku_code as item_sku_cd,
    b.sku_name as item_name,
    b.number as item_quantity,
    b.amount as item_apportion_unit,
    b.real_amount as item_apportion_amount,
    coalesce(c.eb_category, d.category) as category,
    coalesce(c.eb_brand_type, d.brand_type) as brand_type,
    coalesce(c.eb_brand_name, d.brand) as brand_name,
    c.eb_brand_name_cn as brand_name_cn,
    c.target as item_target,
    c.eb_segment as item_segment,
    c.range as item_range,
    c.eb_level1_name as level1_name,
    c.eb_level2_name as level2_name,
    c.eb_level3_name as level3_name,
    c.eb_product_id as product_id,
    a.create_time,
    current_timestamp as insert_timestamp
from
    [STG_SmartBA].[T_Order_Package] a
left join
    [STG_SmartBA].[T_Order_Package_Detail] b
on a.po_code = b.po_code
-- left join
--     [DW_Product].[DWS_SKU_Profile] c
-- on b.sku_code = c.sku_cd
left join 
    dwd.dim_sku_info c
on b.sku_code = c.sku_code
left join
    [STG_Product].[SKU_Mapping] d
on b.sku_code = d.sku_cd
;
end

GO
