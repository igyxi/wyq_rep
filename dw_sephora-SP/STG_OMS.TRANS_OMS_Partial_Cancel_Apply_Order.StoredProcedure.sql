/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Partial_Cancel_Apply_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Partial_Cancel_Apply_Order] AS
BEGIN
truncate table STG_OMS.OMS_Partial_Cancel_Apply_Order;
insert into STG_OMS.OMS_Partial_Cancel_Apply_Order
select 
    oms_partial_cancel_apply_order_sys_id,
    sales_order_sys_id,
    case when trim(sales_order_number) in ('null','') then null else trim(sales_order_number) end as sales_order_number,
    case when trim(purchase_order_number) in ('null','') then null else trim(purchase_order_number) end as purchase_order_number,
    case when trim(related_order_number) in ('null','') then null else trim(related_order_number) end as related_order_number,
    purchase_order_sys_id,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    type,
    cancel_amount,
    case when trim(cancel_reason) in ('null','') then null else trim(cancel_reason) end as cancel_reason,
    case when trim(cancel_comments) in ('null','') then null else trim(cancel_comments) end as cancel_comments,
    case when trim(cancel_status) in ('null','') then null else trim(cancel_status) end as cancel_status,
    cancel_time,
    times_flag,
    cancel_type,
    create_time,
    update_time,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,
    is_delete,
    general_process_flag,
    case when trim(origin_order_internal_status) in ('null','') then null else trim(origin_order_internal_status) end as origin_order_internal_status,
    case when trim(tmall_refund_id) in ('null','') then null else trim(tmall_refund_id) end as tmall_refund_id,
    case when trim(aftersale_id) in ('null','') then null else trim(aftersale_id) end as aftersale_id,
    case when trim(third_refund_id) in ('null','') then null else trim(third_refund_id) end as third_refund_id,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_partial_cancel_apply_order_sys_id order by dt desc) rownum from ODS_OMS.OMS_Partial_Cancel_Apply_Order 
) t
where rownum = 1
END


GO
