/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Order_Return]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Order_Return] AS
BEGIN
truncate table STG_OMS.OMS_Order_Return ;
insert into STG_OMS.OMS_Order_Return
select 
    oms_order_return_sys_id,
    case when trim(r_oms_order_return_sys_id) in ('null','') then null else trim(r_oms_order_return_sys_id) end as r_oms_order_return_sys_id,
    case when trim(oms_member_id) in ('null','') then null else trim(oms_member_id) end as oms_member_id,
    sales_order_sys_id,
    case when trim(r_oms_order_sys_id) in ('null','') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    case when trim(r_oms_order_stkout_hd_sys_id) in ('null','') then null else trim(r_oms_order_stkout_hd_sys_id) end as r_oms_order_stkout_hd_sys_id,
    case when trim(r_oms_refund_apply_order_sys_id) in ('null','') then null else trim(r_oms_refund_apply_order_sys_id) end as r_oms_refund_apply_order_sys_id,
    case when trim(r_oms_exchange_apply_order_sys_id) in ('null','') then null else trim(r_oms_exchange_apply_order_sys_id) end as r_oms_exchange_apply_order_sys_id,
    purchase_order_sys_id,
    oms_refund_apply_order_sys_id,
    oms_exchange_apply_order_sys_id,
    case when trim(oms_order_code) in ('null','') then null else trim(oms_order_code) end as oms_order_code,
    case when trim(source_order_code) in ('null','') then null else trim(source_order_code) end as source_order_code,
    case when trim(exchange_new_order_code) in ('null','') then null else trim(exchange_new_order_code) end as exchange_new_order_code,
    case when trim(return_bill_no) in ('null','') then null else trim(return_bill_no) end as return_bill_no,
    case when trim(process_status) in ('null','') then null else trim(process_status) end as process_status,
    case when trim(return_type) in ('null','') then null else trim(return_type) end as return_type,
    case when trim(return_reason) in ('null','') then null else trim(return_reason) end as return_reason,
    case when trim(return_comments) in ('null','') then null else trim(return_comments) end as return_comments,
    case when trim(receive_comments) in ('null','') then null else trim(receive_comments) end as receive_comments,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,	
    case when trim(r_field2) in ('null','') then null else trim(r_field2) end as r_field2,	
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,	
    field3,	
    version,
    need_refund,
    confirm_time,
    receive_time,	
    create_time,
    update_time,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    case when trim(basic_status) in ('null','') then null else trim(basic_status) end as basic_status,
    refund_status,
    exchange_status,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,		
    case when trim(channel_id) in ('null','') then null else trim(channel_id) end as channel_id,		
    sync_status,	
    refund_invoice_flag,		
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_order_return_sys_id order by dt desc) rownum from ODS_OMS.OMS_Order_Return
) t
where rownum = 1
END


GO
