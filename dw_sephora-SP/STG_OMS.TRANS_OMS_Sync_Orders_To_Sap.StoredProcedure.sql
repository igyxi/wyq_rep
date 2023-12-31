/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Sync_Orders_To_Sap]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Sync_Orders_To_Sap] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_OMS.OMS_Sync_Orders_To_Sap ;
insert into STG_OMS.OMS_Sync_Orders_To_Sap
select 
    oms_sync_orders_to_sap_sys_id,
    oms_order_sys_id,
    case when trim(purchase_order_number) in ('null','') then null else trim(purchase_order_number) end as purchase_order_number,
    case when trim(sync_type) in ('null','') then null else trim(sync_type) end as sync_type,
    case when trim(sync_status) in ('null','') then null else trim(sync_status) end as sync_status,
    create_time,
    update_time,
    sync_time,
    case when trim(file_name) in ('null','') then null else trim(file_name) end as file_name,
    case when trim(invoice_id) in ('null','') then null else trim(invoice_id) end as invoice_id,
    case when trim(pos_model) in ('null','') then null else trim(pos_model) end as pos_model,
    case when trim(return_id) in ('null','') then null else trim(return_id) end as return_id,
    oms_order_refund_sys_id,
    oms_exchange_apply_order_sys_id,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.OMS_Sync_Orders_To_Sap
where dt = @dt
END
GO
