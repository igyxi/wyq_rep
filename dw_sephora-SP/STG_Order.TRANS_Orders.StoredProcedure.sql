/****** Object:  StoredProcedure [STG_Order].[TRANS_Orders]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Order].[TRANS_Orders] AS
BEGIN
truncate table STG_Order.Orders;
insert into STG_Order.Orders
select 
    order_id,
    case when trim(lower(wcs_id)) in ('null', '') then null else trim(wcs_id) end as wcs_id,
    total_amount,
    total_adjustment,
    shipping,
    shipping_adjustment,
    total_coupon_adjustment,
    total_promotion_adjustment,
    case when trim(lower(status)) in ('null', '') then null else trim(status) end as status,
    case when trim(lower(oms_member_id)) in ('null', '') then null else trim(oms_member_id) end as oms_member_id,
    user_id,
    case when trim(lower(pay_method)) in ('null', '') then null else trim(pay_method) end as pay_method,
    order_type,
    case when trim(lower(channel)) in ('null', '') then null else trim(channel) end as channel,
    case when trim(lower(warp_part)) in ('null', '') then null else trim(warp_part) end as warp_part,
    wrap_price,
    case when trim(lower(comments)) in ('null', '') then null else trim(comments) end as comments,
    case when trim(lower(wcs_type)) in ('null', '') then null else trim(wcs_type) end as wcs_type,
    case when trim(lower(gift_comments)) in ('null', '') then null else trim(gift_comments) end as gift_comments,
    case when trim(lower(address_id)) in ('null', '') then null else trim(address_id) end as address_id,
    case when trim(lower(invoice_type)) in ('null', '') then null else trim(invoice_type) end as invoice_type,
    case when trim(lower(delivery_info)) in ('null', '') then null else trim(delivery_info) end as delivery_info,
    create_time,
    update_time,
    create_user,
    update_user,
    case when trim(lower(trigger_msg_status)) in ('null', '') then null else trim(trigger_msg_status) end as trigger_msg_status,
    expire_time,
    case 
        when trim(lower(group_name)) in ('null', '') then null 
        when trim(group_name) = 'GOLDEN' then 'GOLD'
        else trim(group_name) 
    end as group_name,
    case when trim(lower(card_no)) in ('null', '') then null else trim(card_no) end as card_no,
    case when trim(lower(cancel_reason)) in ('null', '') then null else trim(cancel_reason) end as cancel_reason,
    case when trim(lower(nick_name)) in ('null', '') then null else trim(nick_name) end as nick_name,
    case when trim(lower(sub_channel)) in ('null', '') then null else trim(sub_channel) end as sub_channel,
    case when trim(lower(store)) in ('null', '') then null else trim(store) end as store,
    is_delete,
    invoice_title_id,
    case when trim(lower(wish_share_id)) in ('null', '') then null else trim(wish_share_id) end as wish_share_id,
    total_integral,
    case when trim(lower(video_type)) in ('null', '') then null else trim(video_type) end as video_type,
    integral_return_type,
    case when trim(lower(mobile)) in ('null', '') then null else trim(mobile) end as mobile,
    case when trim(lower(is_guest_order)) in ('null', '') then null else trim(is_guest_order) end as is_guest_order,		
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by order_id order by dt desc) rownum from ODS_Order.Orders
) t
where rownum = 1
END


GO
