/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Inventory_Allocate_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Inventory_Allocate_Log] AS
BEGIN
truncate table STG_OMS.OMS_Inventory_Allocate_Log ;
insert into STG_OMS.OMS_Inventory_Allocate_Log
select 
    oms_inventory_allocate_log_sys_id,
    case when trim(operator) in ('null','') then null else trim(operator) end as operator,
    case when trim(inventory_type) in ('null','') then null else trim(inventory_type) end as inventory_type,
    quantity,
    case when trim(sku) in ('null','') then null else trim(sku) end as sku,
    original_quantity,
    case when trim(operation_type) in ('null','') then null else trim(operation_type) end as operation_type,
    case when trim(warehouse_id) in ('null','') then null else trim(warehouse_id) end as warehouse_id,
    case when trim(sap_inv_snapshot) in ('null','') then null else trim(sap_inv_snapshot) end as sap_inv_snapshot,
    create_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    update_time,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *,row_number() over(partition by oms_inventory_allocate_log_sys_id order by dt desc) rownum from ODS_OMS.OMS_Inventory_Allocate_Log 
) t
where rownum = 1
END

GO
