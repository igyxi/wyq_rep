/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Exchange_Apply_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Exchange_Apply_Order] AS
BEGIN
truncate table STG_OMS.OMS_Exchange_Apply_Order;
insert into STG_OMS.OMS_Exchange_Apply_Order
select 
    oms_exchange_apply_order_sys_id,
    r_oms_exchange_apply_order_sys_id,
    case when trim(basic_status) in ('null','') then null else trim(basic_status) end as basic_status,
    case when trim(process_comment) in ('null','') then null else trim(process_comment) end as process_comment,
    case when trim(comment) in ('null','') then null else trim(comment) end as comment,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    create_time,
    case when trim(customer_id) in ('null','') then null else trim(customer_id) end as customer_id,
    case when trim(exchange_no) in ('null','') then null else trim(exchange_no) end as exchange_no,
    case when trim(exchange_reason) in ('null','') then null else trim(exchange_reason) end as exchange_reason,
    case when trim(oms_order_code) in ('null','') then null else trim(oms_order_code) end as oms_order_code,
    case when trim(order_status) in ('null','') then null else trim(order_status) end as order_status,
    case when trim(process_status) in ('null','') then null else trim(process_status) end as process_status,
    case when trim(source_order_code) in ('null','') then null else trim(source_order_code) end as source_order_code,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    update_time,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(channel_id) in ('null','') then null else trim(channel_id) end as channel_id,
    version,
    case when trim(oms_warehouse_id) in ('null','') then null else trim(oms_warehouse_id) end as oms_warehouse_id,
    is_delete,
    case when trim(sap_exchange_number) in ('null','') then null else trim(sap_exchange_number) end as sap_exchange_number,		
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_exchange_apply_order_sys_id order by dt desc) rownum from ODS_OMS.OMS_Exchange_Apply_Order
) t
where rownum = 1
END


GO
