/****** Object:  StoredProcedure [DW_TmallHub].[SP_RPT_OMS_Tmall_Hub_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TmallHub].[SP_RPT_OMS_Tmall_Hub_Order] AS
BEGIN
truncate table DW_TmallHub.RPT_OMS_Tmall_Hub_Order;

with member_new_status as
(
    select 
        order_id,
        customer_id,
        is_placed_flag,
        all_order_placed_seq,
        min(case when all_order_placed_seq = 1 then member_card_level_id else null end) over (partition by customer_id,is_placed_flag) as first_member_card_level,
        min(all_order_placed_seq) over (partition by customer_id, is_placed_flag, pay_date) as member_daily_seq,
        min(case when all_order_placed_seq = 1 then member_card_level_id else null end) over (partition by customer_id, is_placed_flag, pay_date) as member_daily_card_level,
        min(all_order_placed_seq) over (partition by customer_id, is_placed_flag, format(pay_time, 'yyyy-MM')) as member_monthly_seq,
        min(case when all_order_placed_seq = 1 then member_card_level_id else null end) over (partition by customer_id, is_placed_flag, format(pay_time, 'yyyy-MM')) as member_monthly_card_levl
    from 
    (
        select distinct 
            order_id,
            pay_time,
            pay_date,
            customer_id,
            case
                when member_card_level = N'PINK'  then 1
                when member_card_level = N'WHITE' then 2
                when member_card_level = N'BLACK' then 3
                when member_card_level = N'GOLDEN' then 4
                when member_card_level is null then null
                else 0
            end as member_card_level_id,
            is_placed_flag,
            all_order_seq,
            all_order_placed_seq
        from 
            [DW_TmallHub].[DWS_TmallHub_Order]
    )t
)

insert into DW_TmallHub.RPT_OMS_Tmall_Hub_Order
select 
    a.order_id,
    a.receiver_province,
    a.receiver_city,
    a.receiver_district,
    a.type_cd,
    a.status_cd,
    a.is_delete,
    a.customer_id,
    a.mobile_bind_channel_cd,
    a.mobile_bind_time,
    a.user_id,
    a.member_card_no,
    a.member_card_level,
    a.created_time,
    a.consign_time,
    a.sign_time,
    a.pay_time,
    a.pay_date,
    a.payment_amount,
    a.item_outer_sku_cd,
    a.item_sku_id,
    a.item_title,
    a.item_qauntity,
    a.item_is_tax_free,
    a.item_price,
    a.item_divide_order_amount,
    a.item_tax_coupon_discount,
    a.item_discount,
    a.item_total_amount,
    a.item_part_mjz_discount,
    c.main_cd as item_main_cd,
    c.category as item_category,
    c.brand_type as item_brand_type,
    c.brand_name as item_brand_name,
    c.brand_name_cn as item_brand_name_cn,
    c.product_id as item_product_id,
    a.is_placed_flag,
    a.all_order_seq,
    a.all_order_placed_seq,
    b.member_new_status,
    b.member_daily_new_status,
    b.member_monthly_new_status,
    current_timestamp as insert_timestamp
from 
    [DW_TmallHub].[DWS_TmallHub_Order] a
left join 
(
    select 
        order_id,
        case when is_placed_flag = 0 then 'NULL'
            when all_order_placed_seq = 1 and first_member_card_level >= 2 then 'CONVERT_NEW'
            when all_order_placed_seq = 1 and (first_member_card_level is null or first_member_card_level <= 1) then 'BRAND_NEW'
            else 'RETURN'
        end as member_new_status,
        
        case when is_placed_flag = 0 then 'NULL'
            when member_daily_seq = 1 and member_daily_card_level >= 2 then 'CONVERT_NEW'
            when member_daily_seq = 1 and (member_daily_card_level is null or member_daily_card_level <= 1) then 'BRAND_NEW'
            else 'RETURN'
        end as member_daily_new_status, 

        case when is_placed_flag = 0 then 'NULL'
            when member_monthly_seq = 1 and member_monthly_card_levl >= 2 then 'CONVERT_NEW'
            when member_monthly_seq = 1 and (member_monthly_card_levl is null or member_monthly_card_levl <= 1) then 'BRAND_NEW'
            else 'RETURN'
        end as member_monthly_new_status   
    from 
        member_new_status 
)b
on a.order_id = b.order_id
left join
    [DW_Product].[DWS_SKU_Profile] c
on a.item_outer_sku_cd = c.sku_cd;
END
GO
