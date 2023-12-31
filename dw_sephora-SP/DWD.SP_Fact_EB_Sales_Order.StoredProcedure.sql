/****** Object:  StoredProcedure [DWD].[SP_Fact_EB_Sales_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_EB_Sales_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-05       LeoZhai    Initial Version
-- ========================================================================================
truncate table [DWD].[Fact_EB_Sales_Order];
insert into DWD.Fact_EB_Sales_Order
select
    so.sales_order_sys_id,
    so.sales_order_number,
    so.channel_code,
    so.channel_name,
    so.sub_channel_code,
    so.sub_channel_name,
    so.province,
    so.city,
    so.district,
    so.[type] as order_type,
    so.order_internal_status as order_status,
    so.is_placed,
    so.place_time,
    so.place_date,
    so.super_id,
    so.member_id,
    so.open_id,
    so.member_card,
    so.member_card_grade,
    so.member_card_level,    
    so.mobile_guid as member_mobile,
    so.order_time,
    format(so.order_time, 'yyyy-MM-dd') as order_date,
    so.payment_status,
    so.payed_amount,
    so.payment_time,
    format(so.payment_time, 'yyyy-MM-dd') as payment_date,
    so.split_flag,
    tc.item_sku as item_sku_code,
    tc.item_type,
    tc.item_name,
    tc.item_quantity,
    tc.item_market_price,
    tc.item_sale_price,
    tc.item_adjustment_unit,
    tc.item_adjustment_total as item_adjustment_amount,
    tc.apportion_amount_unit as item_apportion_unit,
    tc.apportion_amount as item_apportion_amount,
    b.eb_main_sku_code as item_main_code,
    b.eb_category as item_category,
    b.eb_brand_type as item_brand_type,
    trim(b.eb_brand_name) as item_brand_name,
    trim(b.eb_brand_name_cn) as item_brand_name_cn,
    trim(b.eb_level1_name) as item_level1_name,
    trim(b.eb_level2_name) as item_level2_name,
    trim(b.eb_level3_name) as item_level3_name,
    b.eb_product_id as item_product_id,
    so.o2o_shop_cd as o2o_shop_cd,
    so.smartba_flag,
    so.ouid,
    current_timestamp as insert_timestamp
from
    DW_OMS.DW_Sales_Order so
left join
    STG_OMS.Sales_Order_item tc
on so.sales_order_sys_id = tc.sales_order_sys_id
left join 
    DWD.DIM_SKU_Info b
on tc.item_sku = b.sku_code
;

end
GO
