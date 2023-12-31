/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Refund_Apply_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Refund_Apply_Order] AS
BEGIN
truncate table STG_OMS.OMS_Refund_Apply_Order ;
insert into STG_OMS.OMS_Refund_Apply_Order
select 
    oms_refund_apply_order_sys_id,
    case when trim(r_oms_refund_apply_order_sys_id) in ('null','') then null else trim(r_oms_refund_apply_order_sys_id) end as r_oms_refund_apply_order_sys_id,
    actual_delivery_fee,
    actual_product_fee,
    actual_total_fee,
    advice_delivery_fee,
    advice_product_fee,
    advice_total_fee,
    origin_delivery_fee,
    customer_pay_delivery_fee,
    shop_pay_delivery_fee,
    final_total_fee,
    advice_shop_stkin_delivery_fee,
    case when trim(basic_status) in ('null','') then null else trim(basic_status) end as basic_status,
    case when trim(order_status) in ('null','') then null else trim(order_status) end as order_status,
    case when trim(comment) in ('null','') then null else trim(comment) end as comment,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    create_time,
    case when trim(customer_id) in ('null','') then null else trim(customer_id) end as customer_id,
    case when trim(last_update_op) in ('null','') then null else trim(last_update_op) end as last_update_op,
    last_update_time,
    case when trim(oms_order_code) in ('null','') then null else trim(oms_order_code) end as oms_order_code,
    case when trim(source_order_code) in ('null','') then null else trim(source_order_code) end as source_order_code,
    case when trim(refund_code) in ('null','') then null else trim(refund_code) end as refund_code,
    case when trim(refund_reason) in ('null','') then null else trim(refund_reason) end as refund_reason,
    case when trim(refund_type) in ('null','') then null else trim(refund_type) end as refund_type,
    case when trim(process_status) in ('null','') then null else trim(process_status) end as process_status,
    case when trim(account_name) in ('null','') then null else trim(account_name) end as account_name,
    case when trim(bank_name) in ('null','') then null else trim(bank_name) end as bank_name,
    case when trim(bank_account) in ('null','') then null else trim(bank_account) end as bank_account,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(channel_id) in ('null','') then null else trim(channel_id) end as channel_id,
    case when trim(process_comment) in ('null','') then null else trim(process_comment) end as process_comment,
    case when trim(r_is_shop_pay_delivery_fee) in ('null','') then null else trim(r_is_shop_pay_delivery_fee) end as r_is_shop_pay_delivery_fee,
    shop_pay_delivery_fee_flag,
    version,
    case when trim(return_wh) in ('null','') then null else trim(return_wh) end as return_wh,
    case when trim(from_type) in ('null','') then null else trim(from_type) end as from_type,
    mms_flag,
    case when trim(tmall_refund_id) in ('null','') then null else trim(tmall_refund_id) end as tmall_refund_id,
    is_delete,
    times_flag,
    purchase_order_sys_id,
    case when trim(third_refund_id) in ('null','') then null else trim(third_refund_id) end as third_refund_id,
    batch_flag,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_refund_apply_order_sys_id order by dt) rownum from ODS_OMS.OMS_Refund_Apply_Order 
) t
where t.rownum = 1
END


GO
