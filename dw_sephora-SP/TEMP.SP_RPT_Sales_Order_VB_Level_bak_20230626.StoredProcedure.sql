/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_Order_VB_Level_bak_20230626]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_Order_VB_Level_bak_20230626] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By   Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun  Initial Version
-- 2022-10-17       wubin        update DWS_SKU_Profile/SKU_Mapping --> DWS_SKU_Profile_New
-- 2023-01-10       wangzhichun  add split_flag
-- ========================================================================================
truncate table DW_OMS.RPT_Sales_Order_VB_Level;
insert into DW_OMS.RPT_Sales_Order_VB_Level
select
    sob.sales_order_sys_id,
    sob.sales_order_number,
    sob.store_cd,
    sob.channel_cd,
    sob.province,
    sob.city,
    sob.district,
    sob.type_cd,
    sob.basic_status_cd,
    sob.internal_status_cd,
    sob.is_valid_flag,
    sob.is_placed_flag,
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
    sob.split_flag,
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
    sob.all_order_valid_seq,
    sob.all_order_placed_seq,
    sob.channel_order_seq,
    sob.channel_order_valid_seq,
    sob.channel_order_placed_seq,
    sob.monthly_member_purchase_status_cd,
    sob.monthly_member_card_grade,
    current_timestamp
from
    [DW_OMS].[RPT_Sales_Order_Basic_Level] sob
left join
(
      select 
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
          b.eb_main_sku_code as main_cd,
          b.eb_category as category,
          b.eb_brand_type as brand_type,
          trim(b.eb_brand_name) as brand_name,
          trim(b.eb_brand_name_cn) as brand_name_cn,
          trim(b.eb_level1_name) as level1_name,
          trim(b.eb_level2_name) as level2_name,
          trim(b.eb_level3_name) as level3_name,
          b.eb_product_id as product_id
      from
          STG_OMS.Sales_Order_Item a
      left join
          dwd.dim_sku_info b
      on a.item_sku = b.sku_code

) t
on sob.sales_order_sys_id = t.sales_order_sys_id
;
UPDATE STATISTICS DW_OMS.RPT_Sales_Order_VB_Level;
end
GO
