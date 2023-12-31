/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_Sales_Order_Basic_Level_New2]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_Sales_Order_Basic_Level_New2] AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-08-01       houshuangqiang     update smartba_flag logic		1.1
-- 2022-08-11       houshuangqiang     update smartba_flag logic		1.2
-- 2023-01-10       wangzhichun        add split_flag
-- 2023-06-19       Leozhai        change order source to ODS
-- ========================================================================================
truncate table [DW_OMS].[RPT_Sales_Order_Basic_Level_New2];
with order_seq as
(
    select
        *,
        rank() over (partition by super_id order by order_time) as all_order_seq,
        rank() over (partition by super_id, is_valid_flag order by place_time) as all_order_valid_seq,
        rank() over (partition by super_id, is_placed_flag order by place_time) as all_order_placed_seq,
        rank() over (partition by super_id, channel_cd  order by order_time) as chanel_order_seq,
        rank() over (partition by super_id, is_valid_flag, channel_cd order by place_time) as chanel_order_valid_seq,
        rank() over (partition by super_id, is_placed_flag, channel_cd order by place_time) as chanel_order_placed_seq,
        rank() over (partition by super_id, is_placed_flag order by place_date) as member_daily_seq,
        rank() over (partition by super_id, is_placed_flag order by year(place_time), month(place_time)) as member_monthly_seq,
        rank() over (partition by super_id, is_placed_flag order by year(place_time)) as member_yearly_seq,
        FIRST_VALUE(case when is_placed_flag = 1 then member_card_level else null end) over (partition by super_id, is_placed_flag order by place_time asc, member_card_level desc ROWS UNBOUNDED PRECEDING) as first_member_card_level,
        FIRST_VALUE(case when is_placed_flag = 1 then member_card_level else null end) over (partition by super_id, is_placed_flag, place_date order by place_time asc, member_card_level desc ROWS UNBOUNDED PRECEDING) as member_daily_card_level,
        FIRST_VALUE(case when is_placed_flag = 1 then member_card_level else null end) over (partition by super_id, is_placed_flag, year(place_time), month(place_time) order by place_time asc ,member_card_level desc ROWS UNBOUNDED PRECEDING) as member_monthly_card_level,
        FIRST_VALUE(case when is_placed_flag = 1 then member_card_level else null end) over (partition by super_id, is_placed_flag, year(place_time) order by place_time asc ,member_card_level desc ROWS UNBOUNDED PRECEDING) as member_yearly_card_level,
        max(member_card_level) over (partition by super_id, year(place_time), month(place_time)) as monthly_card_level
    from
    (
        select distinct 
            so.sales_order_sys_id,
            so.sales_order_number,
            so.related_order_number,
            so.store_cd,
            so.channel_cd,
            so.platform_flag,
            so.province,
            so.city,
            so.district,
            so.type_cd,
            so.basic_status,
            so.internal_status,
            so.member_id,
            so.open_id,
            so.member_card,
            so.member_card_grade,
            so.black_card_user_flag,
            so.order_consumer,
            so.member_mobile,
            so.order_time,
            so.order_date,
            so.order_amount,
            so.product_amount,
            so.adjustment_amount,
            so.coupon_adjustment_amount,
            so.promotion_adjustment_amount,
            so.payment_status,
            so.payed_amount,
            so.payment_time,
            so.payment_date,
            so.shipping_type,
            so.shipping_amount,
            so.order_expected_ware_house as shipping_expected_warehouse,
            so.seller_delivery_time,
            so.seller_delivery_date,
            so.packing_box_flag,
            so.packing_box_price,
            so.cancel_type,
            so.cancel_times_flag,
            so.need_invoice_flag as buyer_need_invoice_flag,
            so.buyer_comment,
            so.buyer_memo,
            so.shop_pick,
            so.super_order_id,
            so.food_order_flag,
            so.split_flag,
			case when so.smartba_flag is not null then so.smartba_flag  						-- 如果smartba_flag 不为null,先取so 表中的smartba_flag值，
			     when os.order_id is not null then 1 			                                -- 否则，去关联的os 中取值，关联上赋值1 没有关联上，赋值null
			     else null 
		    end  smartba_flag,
            so.version,
            so.super_id,
            so.place_time,
            so.place_date,
            so.is_valid_flag,
            so.is_placed_flag,
            so.member_card_level,
            so.o2o_shop_cd,
            so.create_time,
            so.create_date,
            so.update_time,
            so.update_date,
            so.end_time,
            so.end_date
        from 
           DW_OMS.DWS_Sales_Order so 
		left join    
		(
			select order_id
			from 
				TEST.Order_Source
			where 
				utm_campaign = 'BA' 
			and 
				utm_medium ='seco'	
			group by order_id
		) os 
		on 	so.sales_order_number = os.order_id
    ) t
),
po_total as (
    select
        sales_order_sys_id,
        sum(item_quantity) as item_quantity,
        sum(case when item_type in ('NORMAL','VALUE_SET','BUNDLE') and item_apportion_amount>0 then item_quantity else 0 end) as item_valid_quantity 
    from 
       DW_OMS.DWS_Purchase_Order
    group by 
        sales_order_sys_id
),
so_total as (
    select 
        sales_order_sys_id,
        member_mobile,
        sum(item_quantity) as item_quantity,
        sum(case when item_type in ('NORMAL','VALUE_SET','BUNDLE') and item_apportion_amount>0 then item_quantity else 0 end) as item_valid_quantity
    from  
        DW_OMS.DWS_Sales_Order
    group by
        sales_order_sys_id,
        member_mobile
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
)

insert into [DW_OMS].[RPT_Sales_Order_Basic_Level_New2]
select
    so.sales_order_sys_id,
    so.sales_order_number,
    so.related_order_number,
    so.store_cd,
    so.channel_cd,
    so.platform_flag,
    so.province,
    so.city,
    so.district,
    so.type_cd,
    so.basic_status,
    so.internal_status,
    so.is_valid_flag,
    so.is_placed_flag,
    so.place_time,
    so.place_date,
    so.super_id,
    case when store_cd='S001' then coalesce(try_cast(so.member_id as bigint),user_info.user_id)
    else user_info.user_id end as sephora_user_id,
    so.member_id,
    so.open_id,
    so.member_card,
    so.member_card_grade,
    so.member_card_level,
    so.black_card_user_flag,
    so.order_consumer,
    so.member_mobile,
    user_info.gender as member_gender,
    user_info.dateofbirth as member_birth_date,
    year(place_date)-year(user_info.dateofbirth) as member_age,
    case when is_placed_flag = 0 then 'NULL'
         when all_order_placed_seq = 1 and first_member_card_level >= 3 then 'CONVERT_NEW'
         when all_order_placed_seq = 1 and first_member_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_new_status,

    case when is_placed_flag = 0 then 'NULL'
         when member_daily_seq = 1 and member_daily_card_level >= 3 then 'CONVERT_NEW'
         when member_daily_seq = 1 and member_daily_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_daily_new_status, 

    case when is_placed_flag = 0 then 'NULL'
         when member_monthly_seq = 1 and member_monthly_card_level >= 3 then 'CONVERT_NEW'
         when member_monthly_seq = 1 and member_monthly_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_monthly_new_status, 

    case when is_placed_flag = 0 then 'NULL'
         when member_yearly_seq = 1 and member_yearly_card_level >= 3 then 'CONVERT_NEW'
         when member_yearly_seq = 1 and member_yearly_card_level <= 2 then 'BRAND_NEW'
         else 'RETURN'
    end as member_yearly_new_status, 

    so.order_time,
    so.order_time,
    so.order_amount,
    so.product_amount,
    so.adjustment_amount,
    so.coupon_adjustment_amount,
    so.promotion_adjustment_amount,
    so.payment_status,
    so.payed_amount,
    so.payment_time,
    so.payment_time,
    so.shipping_type,
    so.shipping_amount,
    so.shipping_expected_warehouse,
    so.seller_delivery_time,
    so.seller_delivery_time,
    so.packing_box_flag,
    so.packing_box_price,
    so.cancel_type,
    so.cancel_times_flag,
    so.buyer_need_invoice_flag,
    so.buyer_comment,
    so.buyer_memo,
    so.o2o_shop_cd,
    so.shop_pick,
    so.super_order_id,
    so.food_order_flag,
    so.split_flag,
    so.smartba_flag,
    so.all_order_seq,
    so.all_order_valid_seq,
    so.all_order_placed_seq,
    so.chanel_order_seq,
    so.chanel_order_valid_seq,
    so.chanel_order_placed_seq,
    case when is_placed_flag = 0 then 'NULL'
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
    so_total.item_quantity as item_vb_quantity,
    so_total.item_valid_quantity as item_vb_valid_quantity,
    po_total.item_quantity as item_sku_quantity,
    po_total.item_valid_quantity as item_sku_valid_quantity,
    so.version,
    so.create_time,
    so.create_date,
    so.update_time,
    so.update_date,
    so.end_time,
    so.end_date,
    current_timestamp as insert_timestamp
from
    order_seq so
left join
    so_total
on so.sales_order_sys_id = so_total.sales_order_sys_id
left join 
    po_total
on so.sales_order_sys_id = po_total.sales_order_sys_id
left join
    user_info
on so.member_card = user_info.card_no
and user_info.rn = 1
;
UPDATE STATISTICS DW_OMS.RPT_Sales_Order_Basic_Level;
end
GO
