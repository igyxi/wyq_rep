/****** Object:  StoredProcedure [TEMP].[SP_Fact_OMS_Sales_Order_With_Coupon_Bak_20230224]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_OMS_Sales_Order_With_Coupon_Bak_20230224] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-05-03       Tali           Initial Version
-- 2022-05-09       Tali           change oms coupon
-- 2022-05-19       Tali           add district
-- 2022-05-30       wangzhichun    add smartba_flag
-- 2022-07-06       Tali           change to DWS_Sales_Order_With_SKU
-- 2022-08-16       Tali           add TRP001 sku for shipping
-- 2022-09-09       Tali           delete virtual_bind_quantity
-- ========================================================================================
truncate table [DWD].[Fact_OMS_Sales_Order_With_Coupon];
insert into [DWD].[Fact_OMS_Sales_Order_With_Coupon]
select
    a.sales_order_number,
    a.purchase_order_number,
    a.invoice_no,
    a.invoice_id,
    a.channel_code,
    a.channel_name,
    a.sub_channel_code,
    a.sub_channel_name,
    a.store_code,
    a.province,
    a.city,
    a.district,
    a.type_code,
    a.member_id,
    a.member_card,
    a.member_card_grade,
    a.payment_status,
    a.order_status,
    a.order_time,
    a.payment_time,
    a.is_placed,
    a.place_time,
    a.smartba_flag as smartba_flag,
    b.item_sku_code,
    b.item_sku_name,
    b.item_quantity as item_quantity,
    0 as item_total_amount,
    0 as item_apportion_amount,
    0 as item_discount_amount,
    null as virtual_sku_code,
    null as virtual_quantity,
    null as virtual_apportion_amount,
    null as virtual_discount_amount,
    -- null as virtual_bind_quantity,
    a.shipping_time,
    a.shipping_amount,
    a.def_warehouse,
    a.actual_warehouse,
    a.pos_sync_time,
    a.pos_sync_status,
    CURRENT_TIMESTAMP as insert_timestamp
from 
(
    select distinct 
        sales_order_number, 
        purchase_order_number,
        invoice_no,
        invoice_id,
        channel_code,
        channel_name,
        sub_channel_code,
        sub_channel_name,
        store_code,
        province,
        city,
        district,
        type_code,
        member_id,
        member_card,
        member_card_grade,
        payment_status,
        order_status,
        order_time,
        payment_time,
        is_placed,
        place_time,
        smartba_flag,
        shipping_time,
        shipping_amount,
        def_warehouse,
        actual_warehouse,
        pos_sync_time,
        pos_sync_status
    from
        DW_OMS.DW_Sales_Order_With_SKU
)a
join
(
    select 
        a.invc_no, 
        a.item_sku_code, 
        a.item_sku_name,
        a.item_quantity
    from 
        DW_CRM.DWS_Trans_Order_With_SKU a
    join
        DW_CRM.DIM_SKU b
    on a.item_sku_code = b.sku_code
    and b.is_offer = 1
    where 
        a.channel_code <> 'OFF_LINE'
    and a.item_quantity >= 0
    and b.brand <> 'GWP'
    and a.item_apportion_amount = 0
    and a.trans_type = 1
) b
on a.invoice_no = b.invc_no

-- union all
-- select
--     a.sales_order_number,
--     a.purchase_order_number,
--     a.invoice_id,
--     a.channel_code,
--     a.channel_name,
--     a.sub_channel_code,
--     a.sub_channel_name,
--     a.store_code,
--     a.province,
--     a.city,
--     a.district,
--     a.type_code,
--     a.member_id,
--     a.member_card,
--     a.member_card_grade,
--     a.payment_status,
--     a.order_status,
--     a.order_time,
--     a.payment_time,
--     a.is_placed,
--     a.place_time,
--     a.smartba_flag as smartba_flag,
--     b.item_sku_code,
--     b.item_sku_name,
--     b.item_quantity as item_quantity,
--     b.item_total_amount,
--     b.item_apportion_amount,
--     0 as item_discount_amount,
--     null as virtual_sku_code,
--     null as virtual_quantity,
--     null as virtual_apportion_amount,
--     null as virtual_discount_amount,
--     -- null as virtual_bind_quantity,
--     a.shipping_time,
--     a.shipping_amount,
--     a.def_warehouse,
--     a.actual_warehouse,
--     a.pos_sync_time,
--     a.pos_sync_status,
--     CURRENT_TIMESTAMP as insert_timestamp
-- from 
-- (
--     select distinct 
--         sales_order_number, 
--         purchase_order_number,
--         invoice_id,
--         channel_code,
--         channel_name,
--         sub_channel_code,
--         sub_channel_name,
--         store_code,
--         province,
--         city,
--         district,
--         type_code,
--         member_id,
--         member_card,
--         member_card_grade,
--         payment_status,
--         order_status,
--         order_time,
--         payment_time,
--         is_placed,
--         place_time,
--         smartba_flag,
--         shipping_time,
--         shipping_amount,
--         def_warehouse,
--         actual_warehouse,
--         pos_sync_time,
--         pos_sync_status
--     from
--         DW_OMS.DWS_Sales_Order_With_SKU
-- )a
-- join
-- (
--     select distinct
--         purchase_order_number,
--         'TRP001' as item_sku_code,
--         N'EB虚拟券' as item_sku_name,
--         1 as item_quantity, 
--         shipping_amount as item_total_amount,
--         shipping_amount as item_apportion_amount
--     from
--         DW_OMS.DWS_Sales_Order_With_SKU
--     where
--         shipping_amount > 0
-- ) b
-- on a.purchase_order_number = b.purchase_order_number
;

END
GO
