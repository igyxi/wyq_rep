/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Synchro_Salesroom_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Synchro_Salesroom_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-01       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Synchro_Salesroom_STG;
insert into STG_IMS.STK_Synchro_Salesroom_STG
select 
		id,
		shop_id,
		case when trim(shop_code) in ('','null','None') then null else trim(shop_code) end as shop_code,
		case when trim(salesroom_code) in ('','null','None') then null else trim(salesroom_code) end as salesroom_code,
		case when trim(salesroom_name) in ('','null','None') then null else trim(salesroom_name) end as salesroom_name,
		salesroom_warehouse_id,
		stock_warehouse_id,
		stock_warehouse_type,
		synchro_scale,
		warn_num,
		retain_num,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		case when trim(remarks) in ('','null','None') then null else trim(remarks) end as remarks,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		is_head_store,
		case when trim(platform_code) in ('','null','None') then null else trim(platform_code) end as platform_code,
		case when trim(baidu_shop_id) in ('','null','None') then null else trim(baidu_shop_id) end as baidu_shop_id,
		case when trim(salesroom_id) in ('','null','None') then null else trim(salesroom_id) end as salesroom_id,
		case when trim(store_code) in ('','null','None') then null else trim(store_code) end as store_code,
		case when trim(store_name) in ('','null','None') then null else trim(store_name) end as store_name,
		case when trim(business_hours) in ('','null','None') then null else trim(business_hours) end as business_hours,
		case when trim(open_shop_uuid) in ('','null','None') then null else trim(open_shop_uuid) end as open_shop_uuid,
		data_create_time,
		data_update_time,
		wharetype_id,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Synchro_Salesroom_STG
where dt = @dt
END
GO
