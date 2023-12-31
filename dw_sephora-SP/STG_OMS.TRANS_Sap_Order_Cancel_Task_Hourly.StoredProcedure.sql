/****** Object:  StoredProcedure [STG_OMS].[TRANS_Sap_Order_Cancel_Task_Hourly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Sap_Order_Cancel_Task_Hourly] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_OMS.Sap_Order_Cancel_Task_Hourly;
insert into STG_OMS.Sap_Order_Cancel_Task_Hourly
select 
    sap_order_cancel_task_sys_id,
    case when trim(r_oms_order_sys_id) in ('null','') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    oms_order_sys_id,
    case when trim(r_oms_refund_apply_sys_id) in ('null','') then null else trim(r_oms_refund_apply_sys_id) end as r_oms_refund_apply_sys_id,
    oms_refund_apply_sys_id,
    case when trim(source_order_no) in ('null','') then null else trim(source_order_no) end as source_order_no,
    case when trim(oms_order_no) in ('null','') then null else trim(oms_order_no) end as oms_order_no,
    case when trim(basic_status) in ('null','') then null else trim(basic_status) end as basic_status,
    case when trim(task_status) in ('null','') then null else trim(task_status) end as task_status,
    case when trim(operater_id) in ('null','') then null else trim(operater_id) end as operater_id,
    case when trim(csr_operater_id) in ('null','') then null else trim(csr_operater_id) end as csr_operater_id,
    case when trim(cancel_reason) in ('null','') then null else trim(cancel_reason) end as cancel_reason,
    case when trim(remark) in ('null','') then null else trim(remark) end as remark,
    create_time,
    update_time,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(delivery_store_id) in ('null','') then null else trim(delivery_store_id) end as delivery_store_id,
    case when trim(apply_type) in ('null','') then null else trim(apply_type) end as apply_type,
    case when trim(task_no) in ('null','') then null else trim(task_no) end as task_no,
    case when trim(osu_status) in ('null','') then null else trim(osu_status) end as osu_status,
    cancel_flag,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(unique_id) in ('null','') then null else trim(unique_id) end as unique_id,
    cancel_time,
    case when trim(refund_status) in ('null','') then null else trim(refund_status) end as refund_status,
    current_timestamp as insert_timestamp
from 
(
     select *, row_number() over(partition by sap_order_cancel_task_sys_id order by hour desc) rownum from ODS_OMS.Sap_Order_Cancel_Task_Hourly where dt = @dt 
)t
where rownum = 1

END
GO
