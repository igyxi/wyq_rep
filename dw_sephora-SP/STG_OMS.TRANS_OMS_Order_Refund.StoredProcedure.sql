/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Order_Refund]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Order_Refund] AS
BEGIN
truncate table STG_OMS.OMS_Order_Refund ;
insert into STG_OMS.OMS_Order_Refund
select 
    oms_order_refund_sys_id,
    oms_order_return_sys_id,
    case when trim(lower(r_oms_order_return_sys_id)) in ('null','') then null else trim(r_oms_order_return_sys_id) end as r_oms_order_return_sys_id,
    order_cancellation_sys_id,
    oms_order_sys_id,
    case when trim(lower(r_oms_order_sys_id)) in ('null','') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    case when trim(lower(refund_no)) in ('null','') then null else trim(refund_no) end as refund_no,
    refund_sum,
    case when trim(lower(payment_method)) in ('null','') then null else trim(payment_method) end as payment_method,
    case when trim(lower(payment_transaction_id)) in ('null','') then null else trim(payment_transaction_id) end as payment_transaction_id,
    case when trim(lower(r_field1)) in ('null','') then null else trim(r_field1) end as r_field1,
    case when trim(lower(field1)) in ('null','') then null else trim(field1) end as field1,
    case when trim(lower(field3)) in ('null','') then null else trim(field3) end as field3,
    case when trim(lower(field4)) in ('null','') then null else trim(field4) end as field4,
    field5,
    field6,
    case when trim(lower(r_oms_refund_apply_order_sys_id)) in ('null','') then null else trim(r_oms_refund_apply_order_sys_id) end as r_oms_refund_apply_order_sys_id,
    oms_refund_apply_order_sys_id,
    case when trim(lower(oms_order_code)) in ('null','') then null else trim(oms_order_code) end as oms_order_code,
    case when trim(lower(source_order_code)) in ('null','') then null else trim(source_order_code) end as source_order_code,
    version,
    case when trim(lower(refund_status)) in ('null','') then null else trim(refund_status) end as refund_status,
    case when trim(lower(refund_op)) in ('null','') then null else trim(refund_op) end as refund_op,
    case when trim(lower(refund_type)) in ('null','') then null else trim(refund_type) end as refund_type,
    apply_time,
    refund_time,
    case when trim(lower(create_op)) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(lower(update_op)) in ('null','') then null else trim(update_op) end as update_op,
    create_time,
    update_time,
    case when trim(lower(basic_status)) in ('null','') then null else trim(basic_status) end as basic_status,
    case when trim(lower(serivice_note)) in ('null','') then null else trim(serivice_note) end as serivice_note,
    case when trim(lower(account_number)) in ('null','') then null else trim(account_number) end as account_number,
    case when trim(lower(refund_reason)) in ('null','') then null else trim(refund_reason) end as refund_reason,
    null as refund_mobile,
    case when trim(lower(account_name)) in ('null','') then null else trim(account_name) end as account_name,
    case when trim(lower(pay_method_order_no)) in ('null','') then null else trim(pay_method_order_no) end as pay_method_order_no,
    case when trim(lower(financial_remark)) in ('null','') then null else trim(financial_remark) end as financial_remark,
    customer_post_fee,
    seller_post_fee,
    case when trim(lower(batch_number)) in ('null','') then null else trim(batch_number) end as batch_number,
    case when trim(lower(refund_source)) in ('null','') then null else trim(refund_source) end as refund_source,
    pay_time,
    defult_product_fee,
    defult_post_fee,
    defult_sum,
    product_fee,
    delivery_fee,
    exp_indemnity,
    case when trim(lower(product_in_status)) in ('null','') then null else trim(product_in_status) end as product_in_status,
    case when trim(lower(product_out_status)) in ('null','') then null else trim(product_out_status) end as product_out_status,
    case when trim(lower(alipay_account)) in ('null','') then null else trim(alipay_account) end as alipay_account,
    null as customer_name,
    case when trim(lower(account_bank)) in ('null','') then null else trim(account_bank) end as account_bank,
    case when trim(lower(update_reason)) in ('null','') then null else trim(update_reason) end as update_reason,
    case when trim(lower(store_id)) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(lower(channel_id)) in ('null','') then null else trim(channel_id) end as channel_id,
    case when trim(lower(assign_to)) in ('null','') then null else trim(assign_to) end as assign_to,
    case when trim(lower(comments)) in ('null','') then null else trim(comments) end as comments,
    case when trim(lower(field2)) in ('null','') then null else trim(field2) end as field2,
    case when trim(lower(related_order_code)) in ('null','') then null else trim(related_order_code) end as related_order_code,
    offline_flag,
    online_return_apply_order_sys_id,
    super_order_id,
    case when trim(lower(tmall_refund_id)) in ('null','') then null else trim(tmall_refund_id) end as tmall_refund_id,
    is_delete,
    return_pos_flag,
    silk_pay_flag,
    case when trim(lower(third_refund_id)) in ('null','') then null else trim(third_refund_id) end as third_refund_id,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_order_refund_sys_id order by dt desc) rownum from ODS_OMS.OMS_Order_Refund
) t
where rownum = 1
END


GO
