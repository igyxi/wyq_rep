/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sales_Order_VB_Level_New_Bak_20230620]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sales_Order_VB_Level_New_Bak_20230620] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-15       wangzhichun        Initial Version
-- 2022-07-27       wangzhichun        update
-- 2022-08-31       tali               update cd
-- 2022-10-11       wangzhichun        update
-- 2023-01-10       wangzhichun        add split_flag
-- 2023-06-07       wangzhichun    update new oms
-- ========================================================================================
truncate table [RPT].[RPT_Sales_Order_VB_Level_New];
insert into [RPT].[RPT_Sales_Order_VB_Level_New]
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
    sob.order_type,
    sob.order_status,
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
    sob.payment_status,
    sob.payed_amount,
    sob.payment_time,
    sob.payment_date,
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
    t.main_code,
    t.category,
    t.brand_type,
    t.brand_name,
    t.brand_name_cn,
    t.level1_name,
    t.level2_name,
    t.level3_name,
    t.eb_product_id,
    sob.o2o_store_code,
    sob.smartba_flag,
    sob.all_order_seq,
    sob.all_order_placed_seq,
    sob.channel_order_seq,
    sob.channel_order_placed_seq,
    sob.member_monthly_purchase_status,
    sob.member_monthly_card_grade,
    CURRENT_TIMESTAMP  
from
    [RPT].[RPT_Sales_Order_Basic_Level_New] sob
left join
(
    select 
        e.tid as sales_order_number,
        null as sales_order_sys_id,
        a.item_sku,
        case when a.item_type = '1' then N'NORMAL'
              when a.item_type = '2' then N'FREE_SAMPLE'
              when a.item_type = '3' then N'VALUE_SET'
              when a.item_type = '4' then N'GWP'
              when a.item_type = '7' then N'VE'
              when a.item_type = '99' then N'BUNDLE'
              else a.item_type
        end as item_type,
        trim(a.item_name) as item_name,
        a.item_quantity,
        a.item_market_price,
        a.item_sale_price,
        a.item_adjustment_total / nullif(a.item_quantity, 0) as item_adjustment_unit,
        a.item_adjustment_total,
        a.apportion_amount_unit,
        a.apportion_amount,
        b.eb_main_sku_code as main_code,
        b.eb_category as category,
        b.eb_brand_type as brand_type,
        trim(b.eb_brand_name) as brand_name,
        trim(b.eb_brand_name_cn) as brand_name_cn,
        trim(b.eb_level1_name) as level1_name,
        trim(b.eb_level2_name) as level2_name,
        trim(b.eb_level3_name) as level3_name,
        b.eb_product_id
    from 
        ODS_New_OMS.OMS_STD_Trade e
    -- inner  	join  stg_oms.oms_to_oims_sync_fail_log fail
	-- on     	e.tid = fail.sales_order_number
	-- and   	fail.sync_status = 1
	-- and   	fail.update_time >= '2023-05-25 18:39:22'
	-- and   	fail.update_time <= '2023-05-26 00:03:00'
    left join
        (
            select  tid as sales_order_number
                    ,outer_sku_id as item_sku
                    ,title as item_name
                    ,gift_type as item_type
                    ,sum(num) as item_quantity
                    ,max(list_price) as item_market_price
                    ,max(sales_price) as item_sale_price
                    ,sum(discount_fee) as item_adjustment_total
                    ,max(divide_price) as apportion_amount_unit
                    ,sum(payment) as apportion_amount
                    ,sum(merchant_discount_fee) as merchant_discount_fee 
            from    ODS_New_OMS.OMS_STD_Trade_Item
            group   by tid,outer_sku_id,gift_type
        )  a
    on e.tid = a.sales_order_number
    left join 
        DWD.DIM_SKU_Info b
    on a.item_sku = b.sku_code
) t
on sob.sales_order_number = t.sales_order_number
;
END 
GO
