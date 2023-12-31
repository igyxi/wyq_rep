/****** Object:  StoredProcedure [TEMP].[SP_DWS_SmartBA_Order_Refund_Hourly_Bak_20220923]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_SmartBA_Order_Refund_Hourly_Bak_20220923] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-05-12       wangzhichun        Initial Version
-- ========================================================================================
truncate table [DW_SmartBA].[DWS_SmartBA_Order_Refund_Hourly];
insert into [DW_SmartBA].[DWS_SmartBA_Order_Refund_Hourly]
select distinct
    a.id as order_refund_id,
    b.id as order_refund_detail_id,
    a.order_code as sales_order_number,
    a.po_code as purchase_order_number,
    a.return_code as refund_no,
    a.amount as refund_amount,
    a.tenant_id as tenant_id,
    b.vs_code as item_vs_cd,
    b.sku_code as item_sku_cd,
    c.sku_name_cn as item_name,
    b.number as item_quantity,
    b.amount as item_refund_amount,
    b.real_amount as item_refund_unit,
    coalesce(c.category, d.category) as category,
    coalesce(c.brand_type, d.brand_type) as brand_type,
    coalesce(c.brand_name, d.brand) as brand_name,
    c.brand_name_cn,
    c.target,
    c.segment as item_segment,
    c.range_name as item_range,
    c.level1_name,
    c.level2_name,
    c.level3_name,
    c.product_id,
    a.create_time,
    current_timestamp as insert_timestamp
from
    [STG_SmartBA].[T_Order_Refund_Hourly] a
inner join
(
    select
        return_code
    from
        [STG_SmartBA].[T_Order_Refund_DW_Hourly]
    where [status]=1
    group by return_code
) dw
on a.return_code=dw.return_code
left join
    [STG_SmartBA].[T_Order_Refund_Detail_Hourly] b
on a.po_code = b.po_code
and a.return_code = b.return_code
left join
    [DW_Product].[DWS_SKU_Profile] c
on b.sku_code = c.sku_cd
left join
    [STG_Product].[SKU_Mapping] d
on b.sku_code = d.sku_cd;
end

GO
