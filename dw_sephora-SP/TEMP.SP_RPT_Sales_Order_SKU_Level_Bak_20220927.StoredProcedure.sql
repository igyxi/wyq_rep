/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_Order_SKU_Level_Bak_20220927]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_Order_SKU_Level_Bak_20220927] AS
begin
truncate table DW_OMS.RPT_Sales_Order_SKU_Level;
insert into DW_OMS.RPT_Sales_Order_SKU_Level
select
    a.sales_order_sys_id,
    a.sales_order_number,
    t.purchase_order_number,
    a.store_cd,
    a.channel_cd,
    a.province,
    a.city,
    a.district,
    a.type_cd,
    a.basic_status_cd,
    a.internal_status_cd,
    a.cancel_type_cd,
    t.type_cd,
    t.basic_status,
    t.internal_status,
    t.split_type,
    a.is_valid_flag,
    a.is_placed_flag,
    a.place_time,
    a.place_date,
    a.super_id,
    a.sephora_user_id,
    a.member_id,
    a.open_id,
    a.member_card,
    a.member_card_grade,
    a.member_card_level,
    a.member_first_black_card_flag,
    a.member_mobile,
    a.member_gender,
    a.member_birth_date,
    a.member_age,
    a.member_new_status,
    a.member_daily_new_status,
    a.member_monthly_new_status,
    a.member_yearly_new_status,
    a.order_time,
    a.order_date,
    a.payment_status_cd,
    a.payed_amount,
    a.payment_time,
    cast(a.payment_time as date) as payment_date,
    t.order_shipping_time,
    t.order_shipping_date,
    t.shipping_time,
    t.shipping_date,
    t.sign_time,
    t.sign_date,
    a.buyer_comment,
    a.o2o_shop,
    t.order_def_ware_house,
    t.order_actual_ware_house,
    t.item_sku_cd,
    t.item_type,
    t.item_name,
    t.item_quantity,
    t.item_sale_price,
    t.item_market_price,
    t.item_adjustment_unit_price,
    t.item_adjustment_amount,
    t.item_apportion_unit_price,
    t.item_apportion_amount,
    t.category,
    t.brand_type,
    t.brand_name,
    t.brand_name_cn,
    t.target,
    t.item_segment,
    t.item_range,
    t.level1_name,
    t.level2_name,
    t.level3_name,
    t.product_id,
    a.smartba_flag,
    a.all_order_seq,
    a.all_order_valid_seq,
    a.all_order_placed_seq,
    a.channel_order_seq,
    a.channel_order_valid_seq,
    a.channel_order_placed_seq,
    a.monthly_member_purchase_status_cd,
    a.monthly_member_card_grade,
    t.create_time,
    t.create_date,
    t.update_time,
    t.update_date,
    current_timestamp
from 
    DW_OMS.RPT_Sales_Order_Basic_Level a
left join
(
    select
        b.sales_order_sys_id,
        b.purchase_order_number,
        b.type_cd,
        b.basic_status,
        b.internal_status,
        b.split_type,
        b.order_shipping_time,
        cast(b.order_shipping_time as date) as order_shipping_date,
        b.shipping_time,
        cast(b.shipping_time as date) as shipping_date,
        b.sign_time,
        cast(b.sign_time as date) as sign_date,
        b.order_def_ware_house,
        b.order_actual_ware_house,
        b.item_sku_cd,
        b.item_type,
        b.item_name,
        b.item_quantity,
        b.item_sale_price,
        b.item_market_price,
        b.item_adjustment_unit_price,
        b.item_adjustment_amount,
        b.item_apportion_unit_price,
        b.item_apportion_amount,
        coalesce(dsp.category, c.category) as category,
        coalesce(dsp.brand_type, c.brand_type) as brand_type,
        coalesce(dsp.brand_name, c.brand) as brand_name,
        dsp.brand_name_cn,
        dsp.target,
        dsp.segment as item_segment,
        dsp.range_name as item_range,
        dsp.level1_name,
        dsp.level2_name,
        dsp.level3_name,
        dsp.product_id,
        b.create_time,
        cast(b.create_time as date) as create_date,
        b.update_time,
        cast(b.update_time as date) as update_date
    from
        DW_OMS.DWS_Purchase_Order b
    left join
        DW_Product.dws_sku_profile dsp
    on b.item_sku_cd = dsp.sku_cd
    left join
        STG_Product.SKU_Mapping c
    on b.item_sku_cd = c.sku_cd
) t 
on a.sales_order_sys_id = t.sales_order_sys_id
;
UPDATE STATISTICS DW_OMS.RPT_Sales_Order_SKU_Level;
end

GO
