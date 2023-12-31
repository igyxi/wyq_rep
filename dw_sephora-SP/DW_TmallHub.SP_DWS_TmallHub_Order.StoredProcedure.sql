/****** Object:  StoredProcedure [DW_TmallHub].[SP_DWS_TmallHub_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TmallHub].[SP_DWS_TmallHub_Order] AS
BEGIN
truncate table DW_TmallHub.DWS_TmallHub_Order;
insert into DW_TmallHub.DWS_TmallHub_Order
select 
    a.order_id,
    a.receiver_state as receiver_province,
    a.receiver_city,
    a.receiver_district,
    a.type as type_cd,
    a.status as status_cd,
    a.is_delete,
    a.buyer_nick as customer_id,
    b.channel as mobile_bind_channel_cd,
    b.bind_time as mobile_bind_time,
    b.user_id,
    a.member_card_no,
    a.member_card_level,
    a.created as created_time,
    a.consign_time,
    a.sign_time,
    a.pay_time,
    convert(date,a.pay_time) as pay_date,
    a.payment payment_amount,
    c.outer_sku_id as item_outer_sku_cd,
    c.sku_id as item_sku_id,
    c.title as item_title,
    c.num as item_qauntity,
    c.tax_free as item_tax_flag,
    c.price as item_price,
    c.divide_order_fee as item_divide_order_amount,
    c.tax_coupon_discount as item_tax_coupon_discount,
    c.discount_fee as item_discount,
    c.total_fee as item_total_amount,
    c.part_mjz_discount as item_part_mjz_discount,
    is_placed_flag,
    all_order_seq,
    case when is_placed_flag = 0 then null else all_order_placed_seq end as all_order_placed_seq, 
    current_timestamp as insert_timestamp
from
( 
    select 
        *,
        rank() over(partition by buyer_nick order by pay_time) as all_order_seq,
        rank() over(partition by buyer_nick, is_placed_flag order by pay_time) as all_order_placed_seq
    from 
    (
        select 
            *,
            case when is_delete = 0 and pay_time is not null and payment > 1 then 1 else 0 end as is_placed_flag
        from 
            STG_TMALLHub.TMALL_Order 
    ) t
    
) a
left join
(
    select 
        *,
        row_number()over(partition by customer_id order by update_time desc) as rn 
    from 
        STG_TMALLHub.TMALL_Bind_Mobile_Info 
) b
on a.buyer_nick = b.customer_id
and b.rn = 1
left join
    STG_TMALLHub.TMALL_Order_Item c
on a.order_id = c.order_id

END 


GO
