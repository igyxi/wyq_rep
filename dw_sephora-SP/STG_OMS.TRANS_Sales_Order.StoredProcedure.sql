/****** Object:  StoredProcedure [STG_OMS].[TRANS_Sales_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Sales_Order] AS
BEGIN
truncate table STG_OMS.Sales_Order;
insert into STG_OMS.Sales_Order
select 
    sales_order_sys_id,
    r_oms_order_sys_id,
    case when trim(lower(store_id)) in ('null', '') then null else trim(store_id) end as store_id,
    case 
        when trim(lower(channel_id)) in ('null', '') then null
        when channel_id = 'Mobile' then 'MOBILE' 
        else channel_id
    end as channel_id,
    case when trim(lower(member_id)) in ('null', '') then null else trim(member_id) end as member_id,
    case when trim(lower(member_card)) in ('null', '') then null else trim(member_card) end as member_card,
    case when trim(lower(r_oms_order_no)) in ('null', '') then null else trim(r_oms_order_no) end as r_oms_order_no,
    case when trim(lower(r_source_order_no)) in ('null', '') then null else trim(r_source_order_no) end as r_source_order_no,
    null as order_consumer,
    case when trim(lower(sales_order_number)) in ('null', '') then null else trim(sales_order_number) end as sales_order_number,
    payment_time,
    order_time,
    case when trim(lower(order_internal_status)) in ('null', '') then null else trim(order_internal_status) end as order_internal_status,
    case when trim(lower(r_payment_status)) in ('null', '') then null else trim(r_payment_status) end as r_payment_status,
    payment_status,
    case when trim(lower(r_order_type)) in ('null', '') then null else trim(r_order_type) end as r_order_type,
    case when trim(lower(r_type)) in ('null', '') then null else trim(r_type) end as r_type,
    type,
    product_total,
    shipping_total,
    need_invoice_flag,
    case when trim(lower(buyer_comment)) in ('null', '') then null else trim(buyer_comment) end as buyer_comment,
    case when trim(lower(buyer_memo)) in ('null', '') then null else trim(buyer_memo) end as buyer_memo,
    update_time,
    payed_amount,
    case 
        when trim(lower(basic_status)) in ('null', '') then null 
        when trim(basic_status) in ('DELETE','DELEDTE','TELETED') then 'DELETED'
        else trim(basic_status)
    end as basic_status,
    origin_shipping_fee,
    order_amount,
    case when trim(lower(r_field4)) in ('null', '') then null else trim(r_field4) end as r_field4,
    black_card_user_flag,
    case when trim(lower(platform_flag)) in ('null', '') then null else trim(platform_flag) end as platform_flag,
    case 
        when trim(lower(member_card_grade)) in ('null', '') then null
        when trim(member_card_grade) = 'GOLDEN' then 'GOLD'
        else trim(member_card_grade)
    end as member_card_grade,
    adjustment_total,
    case when trim(lower(r_field3)) in ('null', '') then null else trim(r_field3) end as r_field3,
    packing_box_flag,
    packing_box_price,
    coupon_adjustment_total,
    promotion_adjustment_total,
    seller_delivery_time,
    case when trim(lower(shipping_type)) in ('null', '') then null else trim(shipping_type) end as shipping_type,
    case when trim(lower(shop_pick)) in ('null', '') then null else trim(shop_pick) end as shop_pick,
    end_time,
    create_time,
    case when trim(lower(order_expected_ware_house)) in ('null', '') then null else trim(order_expected_ware_house) end as order_expected_ware_house,
    version,
    case when trim(lower(related_order_number)) in ('null', '') then null else trim(related_order_number) end as related_order_number,
    times_flag,
    cancel_type,
    sys_create_time,
    sys_update_time,
    super_order_id,
    food_order_flag,
    payable_amount,
    coupon_amount,
    srv_fee,
    platform_adjustment_amount,
    case when trim(lower(dist_provider)) in ('null', '') then null else trim(dist_provider) end as dist_provider,
    case when trim(lower(dist_type)) in ('null', '') then null else trim(dist_type) end as dist_type,
    case when trim(lower(pickup_address)) in ('null', '') then null else trim(pickup_address) end as pickup_address,
    hope_arrival_date,
    hope_arrival_time,
    estimate_out_date,
    estimate_out_time,
    case when trim(lower(verify_code)) in ('null', '') then null else trim(verify_code) end as verify_code,
    case when trim(lower(deliver_memo)) in ('null', '') then null else trim(deliver_memo) end as deliver_memo,
    case when trim(lower(package_no)) in ('null', '') then null else trim(package_no) end as package_no,
    case when trim(lower(delivery_policy)) in ('null', '') then null else trim(delivery_policy) end as delivery_policy,
    case when trim(lower(deal_type)) in ('null', '') then null else trim(deal_type) end as deal_type,
    case when trim(lower(create_user)) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    deposit_flag,
    case when trim(lower(shop_id)) in ('null', '') then null else trim(shop_id) end as shop_id,
    case when trim(lower(order_consumer_invalid)) in ('null', '') then null else trim(order_consumer_invalid) end as order_consumer_invalid,
    merge_flag,
    case when trim(lower(ware_house_code)) in ('null', '') then null else trim(ware_house_code) end as ware_house_code,
    case when trim(lower(smartba_flag)) in ('null', '') then null else trim(smartba_flag) end as smartba_flag,
    case when trim(lower(activity_id)) in ('null', '') then null else trim(activity_id) end as activity_id,
    case when trim(lower(joint_order_number)) in ('null', '') then null else trim(joint_order_number) end as joint_order_number,
    case when trim(lower(open_id)) in ('null', '') then null else trim(open_id) end as open_id,
    case when trim(lower(estimate_con_time)) in ('null', '') then null else trim(estimate_con_time) end as estimate_con_time,
    case when trim(lower(parent_order_id)) in ('null', '') then null else trim(parent_order_id) end as parent_order_id,
    case when trim(lower(direct_parent_order_id)) in ('null', '') then null else trim(direct_parent_order_id) end as direct_parent_order_id,
    case when trim(lower(jd_split_type)) in ('null', '') then null else trim(jd_split_type) end as jd_split_type,
    case when trim(lower(activity_type)) in ('null', '') then null else trim(activity_type) end as activity_type,
    case when trim(lower(oaid)) in ('null', '') then null else trim(oaid) end as oaid,
    case when trim(lower(secondary_order_type)) in ('null', '') then null else trim(secondary_order_type) end as secondary_order_type,
    tmall_decrypt,
    birthday_order_flag,
    split_flag,
	case when trim(lower(ouid)) in ('null', '') then null else trim(ouid) end as ouid,
    current_timestamp as insert_timestamp
from 
(
    select *, ROW_NUMBER() over(partition by sales_order_sys_id order by dt desc) as rownum from [ODS_OMS].[Sales_Order]
)t
where t.rownum = 1
END
GO
