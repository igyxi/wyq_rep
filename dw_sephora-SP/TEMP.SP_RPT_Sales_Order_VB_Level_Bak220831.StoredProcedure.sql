/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_Order_VB_Level_Bak220831]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_Order_VB_Level_Bak220831] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-15       wangzhichun        Initial Version
-- 2022-07-27       wangzhichun        update
-- ========================================================================================
truncate table [RPT].[RPT_Sales_Order_VB_Level];
insert into [RPT].[RPT_Sales_Order_VB_Level]
select
    sob.sales_order_sys_id,
    sob.sales_order_number,
    sob.channel_code,
    sob.channel_name,
    sob.sub_channel_code,
    sob.sub_channel_name,
    sob.province,
    sob.city,
    sob.district,
    sob.type_cd,
    sob.basic_status_cd,
    sob.internal_status_cd,
    sob.is_placed,
    sob.place_time,
    sob.place_date,
    sob.super_id,
    sob.sephora_user_id,
    sob.member_id,
    sob.open_id,
    sob.member_card,
    sob.member_card_grade,
    sob.member_card_level,
    sob.member_first_black_card_flag,
    sob.member_mobile,
    sob.member_gender,
    sob.member_birth_date,
    sob.member_age,
    sob.member_new_status,
    sob.member_daily_new_status,
    sob.member_monthly_new_status,
    sob.member_yearly_new_status,
    sob.order_time,
    sob.order_date,
    sob.payment_status_cd,
    sob.payed_amount,
    sob.payment_time,
    sob.payment_date,
    sob.buyer_comment,
    sob.o2o_shop,
    sob.super_order_id,
    t.item_sku,
    t.item_type,
    t.item_name,
    t.item_quantity,
    t.item_market_price,
    t.item_sale_price,
    t.item_adjustment_unit,
    t.item_adjustment_total,
    t.apportion_amount_unit,
    t.apportion_amount,
    t.main_cd,
    t.category,
    t.brand_type,
    t.brand_name,
    t.brand_name_cn,
    t.level1_name,
    t.level2_name,
    t.level3_name,
    t.product_id,    
    sob.smartba_flag,
    sob.all_order_seq,
    sob.all_order_placed_seq,
    sob.channel_order_seq,
    sob.channel_order_placed_seq,
    sob.monthly_member_purchase_status_cd,
    sob.monthly_member_card_grade,
    CURRENT_TIMESTAMP  
from
    [RPT].[RPT_Sales_Order_Basic_Level] sob
left join
(
    select 
        e.sales_order_number as sales_order_number,
        a.sales_order_sys_id,
        a.item_sku,
        a.item_type,
        trim(a.item_name) as item_name,
        a.item_quantity,
        a.item_market_price,
        a.item_sale_price,
        a.item_adjustment_unit,
        a.item_adjustment_total,
        a.apportion_amount_unit,
        a.apportion_amount,
        coalesce(b.main_cd, c.main_cd) as main_cd,
        coalesce(b.category, c.category) as category,
        coalesce(b.brand_type, c.brand_type) as brand_type,
        coalesce(trim(b.brand_name), c.brand) as brand_name,
        trim(b.brand_name_cn) as brand_name_cn,
        trim(b.level1_name) as level1_name,
        trim(b.level2_name) as level2_name,
        trim(b.level3_name) as level3_name,
        b.product_id
    from 
        stg_oms.Sales_Order e
    left join
        STG_OMS.Sales_Order_Item a
    on e.sales_order_sys_id=a.sales_order_sys_id
    left join 
        DW_Product.DWS_SKU_Profile b
    on a.item_sku = b.sku_cd
    left join
        STG_Product.SKU_Mapping c
    on a.item_sku = c.sku_cd
) t
on sob.sales_order_number = t.sales_order_number
;
END 
GO
