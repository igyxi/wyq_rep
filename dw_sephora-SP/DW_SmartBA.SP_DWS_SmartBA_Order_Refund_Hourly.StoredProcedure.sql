/****** Object:  StoredProcedure [DW_SmartBA].[SP_DWS_SmartBA_Order_Refund_Hourly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_DWS_SmartBA_Order_Refund_Hourly] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-05-12       wangzhichun        Initial Version
-- 2022-09-26       wubin              update 更改DWS_SKU_Profile表为DIM_SKU_Info
-- 2022-09-28       houshuangqiang     delete sku_mapping logic
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
    c.eb_sku_name_cn as item_name,
    b.number as item_quantity,
    b.amount as item_refund_amount,
    b.real_amount as item_refund_unit,
    c.eb_category as category,
    c.eb_brand_type as brand_type,
    c.eb_brand_name as brand_name,
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
    dwd.dim_sku_info c
on b.sku_code = c.sku_code
end
GO
