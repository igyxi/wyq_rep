/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Sales_Order_SKU_Level_With_Promo_bak20230505]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Sales_Order_SKU_Level_With_Promo_bak20230505] AS
BEGIN
truncate table DW_OMS.RPT_OMS_Sales_Order_SKU_Level_With_Promo;
insert into DW_OMS.RPT_OMS_Sales_Order_SKU_Level_With_Promo
select 
    t1.sales_order_number
    ,t1.purchase_order_number
    ,t1.store_cd
    ,t1.channel_cd
    ,t1.province
    ,t1.city
    ,t1.district
    ,t1.so_type_cd
    ,t1.so_basic_status_cd
    ,t1.so_internal_status_cd
    ,t1.so_cancel_type_cd
    ,t1.type_cd
    ,t1.basic_status_cd
    ,t1.internal_status_cd
    ,t1.split_type_cd
    ,t1.is_valid_flag
    ,t1.is_placed_flag
    ,t1.place_time
    ,t1.place_date
    ,t1.super_id
    ,t1.sephora_user_id
    ,t1.member_id
    ,t1.member_card
    ,t1.member_card_grade
    ,t1.member_card_level
    ,t1.member_first_black_card_flag
    ,t1.member_mobile
    ,t1.member_gender
    ,t1.member_birth_date
    ,t1.member_age
    ,t1.member_new_status
    ,t1.member_daily_new_status
    ,t1.member_monthly_new_status
    ,t1.order_time
    ,t1.order_date
    ,t1.payment_status_cd
    ,t1.payed_amount
    ,t1.payment_time
    ,t1.payment_date
    ,t1.shipping_time
    ,t1.shipping_date
    ,t1.sign_time
    ,t1.sign_date
    ,t1.buyer_comment
    ,t1.shop_cd
    ,t1.order_def_ware_house
    ,t1.order_actual_ware_house
    ,t1.item_sku_cd
    ,t1.item_type_cd
    ,t1.item_name
    ,t1.item_quantity
    ,t1.item_market_price
    ,t1.item_sale_price
    ,t1.item_adjustment_unit
    ,t1.item_adjustment_amount
    ,t1.item_apportion_unit
    ,t1.item_apportion_amount
    ,t1.item_category
    ,t1.item_brand_type
    ,t1.item_brand_name
    ,t1.item_brand_name_cn
    ,t1.item_target
    ,t1.item_segment
    ,t1.item_range
    ,t1.item_level1_name
    ,t1.item_level2_name
    ,t1.item_level3_name
    ,t1.item_product_id
    ,t1.all_order_seq
    ,t1.all_order_valid_seq
    ,t1.all_order_placed_seq
    ,t1.channel_order_seq
    ,t1.channel_order_valid_seq
    ,t1.channel_order_placed_seq
    ,t1.monthly_member_purchase_status_cd
    ,t1.monthly_member_card_grade
    ,t1.po_sys_create_time
    ,t1.po_sys_create_date
    ,t1.po_sys_update_time
    ,t1.po_sys_update_date
    ,null as promotion_code_list
    ,current_timestamp as insert_timestamp 
from 
    [DW_OMS].[RPT_Sales_Order_SKU_Level] t1
where
    isnull(split_type_cd,'')<>'SPLIT_ORIGIN'
and 
    isnull(type_cd,0)<>2
union all 
select 
    a.sales_order_number
    ,null as purchase_order_number
    ,a.store_cd
    ,a.channel_cd
    ,a.province
    ,a.city
    ,a.district
    ,a.type_cd as so_type_cd
    ,a.basic_status_cd as so_basic_status_cd
    ,a.internal_status_cd as so_internal_status_cd
    ,cast(a.cancel_type_cd as varchar(512)) as so_cancel_type_cd
    ,null as type_cd
    ,null as basic_status_cd
    ,null as internal_status_cd
    ,null as split_type_cd 
    ,a.is_valid_flag
    ,a.is_placed_flag
    ,a.place_time
    ,a.place_date
    ,a.super_id
    ,a.sephora_user_id
    ,a.member_id
    ,a.member_card
    ,a.member_card_grade
    ,a.member_card_level
    ,a.member_first_black_card_flag
    ,a.member_mobile
    ,a.member_gender
    ,a.member_birth_date
    ,a.member_age
    ,a.member_new_status
    ,a.member_daily_new_status
    ,a.member_monthly_new_status
    ,a.order_time
    ,a.order_date
    ,a.payment_status_cd
    ,a.payed_amount
    ,a.payment_time
    ,a.payment_date
    ,null as shipping_time
    ,null as shipping_date
    ,null as sign_time
    ,null as sign_date
    ,a.buyer_comment
    ,a.o2o_shop as shop_cd
    ,null as order_def_ware_house
    ,null as order_actual_ware_house
    ,b.coupon_id as item_sku_cd
    ,null as item_type_cd
    ,b.source_promotion_description as item_name 
    ,null as item_quantity
    ,null as item_market_price
    ,null as item_sale_price
    ,null as item_adjustment_unit
    ,null as item_adjustment_amount
    ,null as item_apportion_unit
    ,null as item_apportion_amount
    ,null as item_category
    ,null as item_brand_type
    ,null as item_brand_name
    ,null as item_brand_name_cn
    ,null as item_target
    ,null as item_segment
    ,null as item_range
    ,null as item_level1_name
    ,null as item_level2_name
    ,null as item_level3_name
    ,null as item_product_id
    ,a.all_order_seq
    ,a.all_order_valid_seq
    ,a.all_order_placed_seq
    ,a.channel_order_seq
    ,a.channel_order_valid_seq
    ,a.channel_order_placed_seq
    ,a.monthly_member_purchase_status_cd
    ,a.monthly_member_card_grade
    ,null as po_sys_create_time
    ,null as po_sys_create_date
    ,null as po_sys_update_time
    ,null as po_sys_update_date
    ,null as promotion_code_list
    ,current_timestamp as insert_timestamp 
from 
    [DW_OMS].[RPT_Sales_Order_Basic_Level] a
left join 
    [STG_OMS].[Sales_Order_Promo] b
on a.sales_order_sys_id = b.sales_order_sys_id
where 
    b.crm_coupon_flag = 1
; 

END
GO
