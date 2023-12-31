/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Store]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Store] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-28       wangzhichun        Initial Version
-- ========================================================================================
truncate table STG_OMS.OMS_Store;
insert into STG_OMS.OMS_Store
select 
    oms_store_sys_id,
    case when trim(oms_store_id) in ('null','') then null else trim(oms_store_id) end as store_name,
    case when trim(oms_store_name) in ('null','') then null else trim(oms_store_name) end as store_name,
	case when trim(oms_channel_id) in ('null','') then null else trim(oms_channel_id) end as oms_channel_id,
	case when trim(oms_channel_name) in ('null','') then null else trim(oms_channel_name) end as oms_channel_name,
	case when trim(oms_brand_id) in ('null','') then null else trim(oms_brand_id) end as oms_brand_id,
	case when trim(oms_brand_name) in ('null','') then null else trim(oms_brand_name) end as oms_brand_name,
	case when trim(oms_store_url) in ('null','') then null else trim(oms_store_url) end as oms_store_url,
	case when trim(oms_store_admin) in ('null','') then null else trim(oms_store_admin) end as oms_store_admin,
	case when trim(oms_store_phone) in ('null','') then null else trim(oms_store_phone) end as oms_store_phone,
	case when trim(oms_store_description) in ('null','') then null else trim(oms_store_description) end as oms_store_description,
	case when trim(store_push_inventory_function) in ('null','') then null else trim(store_push_inventory_function) end as store_push_inventory_function,
	version,
	oms_store_status,
	create_time,
	update_time,
	case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
	case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
	oms_is_part_cancelorders,
	oms_is_part_cancelreturns,
	oms_is_merge_orders,
	is_delete,
    current_timestamp as insert_timestamp
from 
ODS_OMS.OMS_Store

END
GO
