/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_SAP_Actual_Inventory]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_SAP_Actual_Inventory] AS
BEGIN
truncate table STG_OMS.OMS_SAP_Actual_Inventory ;
insert into STG_OMS.OMS_SAP_Actual_Inventory
select 
    oms_sap_actual_inventory_sys_id,
    case when trim(sku_cod) in ('null','') then null else trim(sku_cod) end as sku_cod,
    actual_inventory,
    reserve_inventory,
    retention_flag_on_off,
    case when trim(warehouse_id) in ('null','') then null else trim(warehouse_id) end as warehouse_id,
    is_execute,
    create_time,
    update_time,
    case when trim(inv_filename) in ('null','') then null else trim(inv_filename) end as inv_filename,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_sap_actual_inventory_sys_id order by dt desc) rownum from ODS_OMS.OMS_SAP_Actual_Inventory
) t
where rownum = 1
END

GO
