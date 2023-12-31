/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Inventory_Allocate_Data]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Inventory_Allocate_Data] @dt [varchar](10) AS
BEGIN
truncate table STG_OMS.OMS_Inventory_Allocate_Data ;
insert into STG_OMS.OMS_Inventory_Allocate_Data
select 
    oms_inventory_allocate_data_sys_id,
    case when trim(inventory_type) in ('null','') then null else trim(inventory_type) end as inventory_type,
    quantity,
    create_time,
    update_time,
    case when trim(sku) in ('null','') then null else trim(sku) end as sku,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,
    case when trim(field3) in ('null','') then null else trim(field3) end as field3,
    field4,
    field5,
    original_quantity,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(ware_house) in ('null','') then null else trim(ware_house) end as ware_house,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.OMS_Inventory_Allocate_Data 
where 
    dt = @dt
END
GO
