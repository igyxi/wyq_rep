/****** Object:  StoredProcedure [RPT].[SP_RPT_Sales_Order_Basic_Level_Bak_20220801]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sales_Order_Basic_Level_Bak_20220801] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-15       wangzhichun        Initial Version
-- 2022-07-27       wangzhichun        update
-- ========================================================================================
truncate table [RPT].[RPT_Sales_Order_Basic_Level];
with order_seq as
(
    select
        *,
        rank() over (partition by super_id order by order_time) as all_order_seq,
        rank() over (partition by super_id, is_placed order by place_time) as all_order_placed_seq,
        rank() over (partition by super_id, sub_channel_code  order by order_time) as chanel_order_seq,
        rank() over (partition by super_id, is_placed, sub_channel_code order by place_time) as chanel_order_placed_seq,
        rank() over (partition by super_id, is_placed order by place_date) as member_daily_seq,
        rank() over (partition by super_id, is_placed order by year(place_time), month(place_time)) as member_monthly_seq,
        rank() over (partition by super_id, is_placed order by year(place_time)) as member_yearly_seq,
        FIRST_VALUE(case when t.is_placed = 1 then t.member_card_level else null end) over (partition by super_id, is_placed order by place_time asc, member_card_level desc ROWS UNBOUNDED PRECEDING) as first_member_card_level,
        FIRST_VALUE(case when t.is_placed = 1 then t.member_card_level else null end) over (partition by super_id, is_placed, place_date order by place_time asc, member_card_level desc ROWS UNBOUNDED PRECEDING) as member_daily_card_level,
        FIRST_VALUE(case when t.is_placed = 1 then t.member_card_level else null end) over (partition by super_id, is_placed, year(place_time), month(place_time) order by place_time asc ,member_card_level desc ROWS UNBOUNDED PRECEDING) as member_monthly_card_level,
        FIRST_VALUE(case when t.is_placed = 1 then t.member_card_level else null end) over (partition by super_id, is_placed, year(place_time) order by place_time asc ,member_card_level desc ROWS UNBOUNDED PRECEDING) as member_yearly_card_level,
        max(member_card_level) over (partition by super_id, year(place_time), month(place_time)) as monthly_card_level
    from
    (
        select distinct
        sales_order_number,
        channel_code,
        channel_name,
        sub_channel_code,
        sub_channel_name,
        province,
        city,
        district,
        member_id,
        member_card,
        member_card_grade,
        case 
            when channel_code = 'SOA' then  COALESCE(member_card,member_id)
            when sub_channel_code='DOUYIN001' then  concat(member_id,province,city,district)
            else member_id
        end as super_id,
        case 
            when member_card_grade= 'PINK'  then 1
            when member_card_grade = 'NEW' then 2
            when member_card_grade = 'WHITE' then 3
            when member_card_grade = 'BLACK' then 4
            when member_card_grade = 'GOLD' then 5
            else 0
        end as member_card_level, 
        payment_status,
        order_time,
        payment_time,
        is_placed as is_placed,
        cast(place_time as date) as place_date,
        place_time,
        smartba_flag
        --so.shipping_total as shipping_amount
    from
        DW_OMS.DWS_Sales_Order_With_SKU sku
    ) t
),
user_info as (
    select 
        user_id,
        card_no,
        gender,
        dateofbirth,
        row_number() over(partition by card_no order by gender,dateofbirth desc,user_id desc) as rn
    from 
        stg_user.user_profile
    where 
        card_no is not null
        and gender is not null
),
order_so as (
    select
        a.sales_order_sys_id,
        sales_order_number,
        related_order_number,
        open_id,
        platform_flag,
        create_time,
        basic_status,
        order_internal_status,
        product_total,
        [type],
        black_card_user_flag,
        order_consumer,
        order_amount,
        payed_amount,
        product_total as product_amount,
        adjustment_total as adjustment_amount,
        coupon_adjustment_total as coupon_adjustment_amount,
        promotion_adjustment_total as promotion_adjustment_amount,
        shipping_type,
        shipping_total as shipping_amount,
        order_expected_ware_house as shipping_expected_warehouse,
        seller_delivery_time,
        packing_box_flag,
        packing_box_price,
        cancel_type,
        times_flag as cancel_times_flag,
        need_invoice_flag as buyer_need_invoice_flag,
        buyer_comment,
        buyer_memo,
        case when store_id = 'S001' and channel_id = 'O2O' then substring(buyer_memo,1,4) else null end as o2o_shop_cd,
        shop_pick,
        super_order_id,
        food_order_flag,
        smartba_flag,
        cast(create_time as date) as create_date,
        update_time,
        cast(update_time as date) as update_date,
        end_time,
        cast(end_time as date) as end_date,
        version,
        is_delete,
        gi.mobile_guid as member_mobile
    from 
        stg_oms.Sales_Order a
    left join 
    (
        select sales_order_sys_id,cast(mobile_guid as varchar) as mobile_guid from STG_OMS.Order_Guid_Info
    ) gi
    on a.sales_order_sys_id = gi.sales_order_sys_id
)


insert into [RPT].[RPT_Sales_Order_Basic_Level]
select
    a.sales_order_sys_id,
    so.sales_order_number,
    a.related_order_number,
    so.channel_code,
    so.channel_name,
    so.sub_channel_code,
    so.sub_channel_name,
    a.platform_flag,
    so.province,
    so.city,
    so.district,
    a.[type] as type_cd,
    a.basic_status,
    a.order_internal_status as internal_status,
    so.is_placed,
    so.place_time,
    so.place_date,
    so.super_id,
    case when so.channel_code='SOA' then coalesce(try_cast(so.member_id as bigint),user_info.user_id)
    else user_info.user_id end as sephora_user_id,
    so.member_id,
    a.open_id,
    so.member_card,
    so.member_card_grade,
    so.member_card_level,
    a.black_card_user_flag,
    a.order_consumer,
    a.member_mobile,
    user_info.gender as member_gender,
    user_info.dateofbirth as member_birth_date,
    year(place_date)-year(user_info.dateofbirth) as member_age,
    case when is_placed = 0 then 'NULL'
         when all_order_placed_seq = 1 and first_member_card_level >= 3 then 'CONVERT_NEW'
         when all_order_placed_seq = 1 and first_member_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_new_status,
    case when is_placed = 0 then 'NULL'
         when member_daily_seq = 1 and member_daily_card_level >= 3 then 'CONVERT_NEW'
         when member_daily_seq = 1 and member_daily_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_daily_new_status, 

    case when is_placed = 0 then 'NULL'
         when member_monthly_seq = 1 and member_monthly_card_level >= 3 then 'CONVERT_NEW'
         when member_monthly_seq = 1 and member_monthly_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_monthly_new_status, 

    case when is_placed = 0 then 'NULL'
         when member_yearly_seq = 1 and member_yearly_card_level >= 3 then 'CONVERT_NEW'
         when member_yearly_seq = 1 and member_yearly_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_yearly_new_status, 
    so.order_time,
    so.order_time,
    a.order_amount,
    a.product_amount,
    a.adjustment_amount,
    a.coupon_adjustment_amount,
    a.promotion_adjustment_amount,
    so.payment_status,
    a.payed_amount,
    so.payment_time,
    so.payment_time,
    a.shipping_type,
    a.shipping_amount,
    a.shipping_expected_warehouse,
    a.seller_delivery_time,
    a.seller_delivery_time,
    a.packing_box_flag,
    a.packing_box_price,
    a.cancel_type,
    a.cancel_times_flag,
    a.buyer_need_invoice_flag,
    a.buyer_comment,
    a.buyer_memo,
    a.o2o_shop_cd,
    a.shop_pick,
    a.super_order_id,
    a.food_order_flag,
    a.smartba_flag,
    so.all_order_seq,
    so.all_order_placed_seq,
    so.chanel_order_seq,
    so.chanel_order_placed_seq,
    case when is_placed = 0 then 'NULL'
         when member_monthly_seq = 1 then 'NEW'
         else 'RETURN'
    end as monthly_member_purchase_status_cd, 
    case 
         when monthly_card_level = 1 then 'PINK'
         when monthly_card_level in (2,3) then 'WHITE'
         when monthly_card_level = 4 then 'BLACK'
         when monthly_card_level = 5 then 'GOLD'
         else 'NULL'
    end as monthly_member_card_grade,
    a.version,
    a.create_time,
    a.create_date,
    a.update_time,
    a.update_date,
    a.end_time,
    a.end_date,
    current_timestamp as insert_timestamp
from
    order_seq so
left join 
    order_so a
on so.sales_order_number=a.sales_order_number
left join
    user_info
on so.member_card = user_info.card_no
and user_info.rn = 1
end

GO
