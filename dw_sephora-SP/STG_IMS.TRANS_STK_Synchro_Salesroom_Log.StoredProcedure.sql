/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Synchro_Salesroom_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Synchro_Salesroom_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Synchro_Salesroom_Log;
insert into STG_IMS.STK_Synchro_Salesroom_Log
select 
		id,
		shop_id,
		goods_id,
		sku_id,
		salesroom_warehouse_id,
		salesroom_warehouse_type,
		synchro_num,
		synchro_time,
		case when trim(synchro_message) in ('','null','None') then null else trim(synchro_message) end as synchro_message,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(salesroom_code) in ('','null','None') then null else trim(salesroom_code) end as salesroom_code,
		goods_type,
		case when trim(salesroom_name) in ('','null','None') then null else trim(salesroom_name) end as salesroom_name,
		case when trim(platform_code) in ('','null','None') then null else trim(platform_code) end as platform_code,
		case when trim(details) in ('','null','None') then null else trim(details) end as details,
		syn_status,
		wharetype_id,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Synchro_Salesroom_Log
where dt = @dt
END
GO
