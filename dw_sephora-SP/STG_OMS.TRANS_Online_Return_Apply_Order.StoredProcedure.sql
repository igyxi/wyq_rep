/****** Object:  StoredProcedure [STG_OMS].[TRANS_Online_Return_Apply_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Online_Return_Apply_Order] AS
BEGIN
truncate table STG_OMS.Online_Return_Apply_Order ;
insert into STG_OMS.Online_Return_Apply_Order
select 
    online_return_apply_order_sys_id,
    super_order_id,
    case when trim(lower(return_number)) in ('null','') then null else trim(return_number) end as return_number,
    null account_info,
    actual_delivery_fee,
    actual_product_fee,
    actual_total_fee,
    advice_delivery_fee,
    advice_product_fee,
    advice_total_fee,
    origin_delivery_fee,
    shop_pay_delivery_fee,
    case when trim(lower(basic_status)) in ('null','') then null else trim(basic_status) end as basic_status,
    case when trim(lower(order_status)) in ('null','') then null else trim(order_status) end as order_status,
    case when trim(lower(comment)) in ('null','') then null else trim(comment) end as comment,
    case when trim(lower(create_nick_name)) in ('null','') then null else trim(create_nick_name) end as create_nick_name,
    case when trim(lower(create_user_id)) in ('null','') then null else trim(create_user_id) end as create_user_id,
    create_time,
    case when trim(lower(logistics_number)) in ('null','') then null else trim(logistics_number) end as logistics_number,
    case when trim(lower(logistics_company)) in ('null','') then null else trim(logistics_company) end as logistics_company,
    null as mobile,
    case when trim(lower(card_no)) in ('null','') then null else trim(card_no) end as card_no,
    case when trim(lower(update_nick_name)) in ('null','') then null else trim(update_nick_name) end as update_nick_name,
    update_time,
    case when trim(lower(sales_order_number)) in ('null','') then null else trim(sales_order_number) end as sales_order_number,
    case when trim(lower(return_reason)) in ('null','') then null else trim(return_reason) end as return_reason,
    case when trim(lower(return_type)) in ('null','') then null else trim(return_type) end as return_type,
    case when trim(lower(process_status)) in ('null','') then null else trim(process_status) end as process_status,
    case when trim(lower(process_comment)) in ('null','') then null else trim(process_comment) end as process_comment,
    case when trim(lower(apply_image_paths)) in ('null','') then null else trim(apply_image_paths) end as apply_image_paths,
    case when trim(lower(store_id)) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(lower(channel_id)) in ('null','') then null else trim(channel_id) end as channel_id,
    case when trim(lower(apply_channel_id)) in ('null','') then null else trim(apply_channel_id) end as apply_channel_id,
    shop_pay_delivery_fee_flag,
    case when trim(lower(warehouse_status)) in ('null','') then null else trim(warehouse_status) end as warehouse_status,
    version,
    logistics_post_back_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    virtual_stkin_flag,
    is_return_express_fee,
    case when trim(lower(shop_id)) in ('null','') then null else trim(shop_id) end as shop_id,
    case when trim(lower(purchase_order_number)) in ('null','') then null else trim(purchase_order_number) end as purchase_order_number,
    case when trim(lower(tmall_refund_id)) in ('null','') then null else trim(tmall_refund_id) end as tmall_refund_id,
    case when trim(lower(return_warehouse_id)) in ('null','') then null else trim(return_warehouse_id) end as return_warehouse_id,
    case when trim(lower(third_refund_id)) in ('null','') then null else trim(third_refund_id) end as third_refund_id,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by online_return_apply_order_sys_id order by dt) rownum from ODS_OMS.Online_Return_Apply_Order 
) t
where rownum = 1
END


GO
