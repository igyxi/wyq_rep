/****** Object:  StoredProcedure [STG_OMS].[TRANS_Purchase_Order_Hourly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Purchase_Order_Hourly] @dt [varchar](10) AS
BEGIN
truncate table STG_OMS.Purchase_Order_Hourly;
insert into STG_OMS.Purchase_Order_Hourly
select 
    purchase_order_sys_id,
    case when trim(lower(r_oms_stkout_hd_sys_id)) in ('null', '') then null else trim(r_oms_stkout_hd_sys_id) end as r_oms_stkout_hd_sys_id,
    case when trim(lower(store_id)) in ('null', '') then null else trim(store_id) end as store_id,
    case 
        when trim(lower(channel_id)) in ('null', '') then null
        when channel_id = 'Mobile' then 'MOBILE' 
        else channel_id
    end as channel_id,    
    case when trim(lower(member_id)) in ('null', '') then null else trim(member_id) end as member_id,
    case when trim(lower(member_card)) in ('null', '') then null else trim(member_card) end as member_card,
    case when trim(lower(order_consumer)) in ('null', '') then null else trim(order_consumer) end as order_consumer,
    case when trim(lower(purchase_order_number)) in ('null', '') then null else trim(purchase_order_number) end as purchase_order_number,
    case when trim(lower(sales_order_number)) in ('null', '') then null else trim(sales_order_number) end as sales_order_number,
    case when trim(lower(related_order_number)) in ('null', '') then null else trim(related_order_number) end as related_order_number,
    order_time,
    case 
        when trim(lower(order_internal_status)) in ('null', '') then null 
        when trim(order_internal_status) = 'CANCLED' then 'CANCELLED'
        when trim(order_internal_status) = 'CANNOT_CONTACT' then 'CANT_CONTACTED'
        when trim(order_internal_status) = 'REFUSE' then 'REJECTED'
        when trim(order_internal_status) = '\\\SIGNED' then 'SIGNED'
        else trim(order_internal_status)
    end as order_internal_status,
    type,
    case when trim(lower(order_delivery_type)) in ('null', '') then null else trim(order_delivery_type) end as order_delivery_type,
    shipping_total,
    case when trim(lower(logistics_shipping_company)) in ('null', '') then null else trim(logistics_shipping_company) end as logistics_shipping_company,
    case when trim(lower(logistics_number)) in ('null', '') then null else trim(logistics_number) end as logistics_number,
    sign_time,
    shipping_time,
    missing_flag,
    null as mobile,
    order_shipping_time,
    create_time,
    update_time,
    case when trim(lower(order_shipping_comment)) in ('null', '') then null else trim(order_shipping_comment) end as order_shipping_comment,
    case when trim(lower(seller_order_comment)) in ('null', '') then null else trim(seller_order_comment) end as seller_order_comment,
    payed_amount,
    case 
        when trim(lower(basic_status)) in ('null', '') then null 
        when trim(basic_status) = 'FINISHED' then 'FINISH'
        else trim(basic_status) 
    end as basic_status,
    case when trim(lower(order_def_ware_house)) in ('null', '') then null else trim(order_def_ware_house) end as order_def_ware_house,
    cancel_time,
    case when trim(lower(cancel_reason)) in ('null', '') then null else trim(cancel_reason) end as cancel_reason,
    case when trim(lower(cancel_comment)) in ('null', '') then null else trim(cancel_comment) end as cancel_comment,
    case when trim(lower(purchase_parent_order_number)) in ('null', '') then null else trim(purchase_parent_order_number) end as purchase_parent_order_number,
    case when trim(lower(order_actual_ware_house)) in ('null', '') then null else trim(order_actual_ware_house) end as order_actual_ware_house,
    version,
    case when trim(lower(split_type)) in ('null', '') then null else trim(split_type) end as split_type,
    case when trim(lower(r_oms_order_sys_id)) in ('null', '') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    sales_order_sys_id,
    case when trim(lower(parcel_number)) in ('null', '') then null else trim(parcel_number) end as parcel_number,
    case when trim(lower(r_field3)) in ('null', '') then null else trim(r_field3) end as r_field3,
    food_order_flag,
    logistics_shipping_time,
    sys_create_time,
    sys_update_time,
    super_order_id,
    fczp_order_flag,
    case when trim(lower(create_user)) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(lower(deal_type)) in ('null', '') then null else trim(deal_type) end as deal_type,
    case when trim(lower(shop_id)) in ('null', '') then null else trim(shop_id) end as shop_id,
    ors_coupon_flag,
    merge_flag,
    case when trim(lower(presales_sku)) in ('null', '') then null else trim(presales_sku) end as presales_sku,
    presales_date,
    case when trim(lower(smartba_flag)) in ('null', '') then null else trim(smartba_flag) end as smartba_flag,
    case when trim(lower(activity_id)) in ('null', '') then null else trim(activity_id) end as activity_id,
    case when trim(lower(joint_order_number)) in ('null', '') then null else trim(joint_order_number) end as joint_order_number,
    case when trim(lower(ware_house_code)) in ('null', '') then null else trim(ware_house_code) end as ware_house_code,
    current_timestamp as insert_timestamp
from 
(
    select *, ROW_NUMBER() over(partition by purchase_order_sys_id order by dt desc) as rownum from [ODS_OMS].[Purchase_Order_Hourly] where dt = @dt
) t
where rownum = 1;

END
GO
