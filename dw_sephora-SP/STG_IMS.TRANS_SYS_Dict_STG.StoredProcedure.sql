/****** Object:  StoredProcedure [STG_IMS].[TRANS_SYS_Dict_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_SYS_Dict_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.SYS_Dict_STG;
insert into STG_IMS.SYS_Dict_STG
select 
		id,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		status,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		type,
		api_result_type,
		case when trim(api) in ('','null','None') then null else trim(api) end as api,
		case when trim(module_type) in ('','null','None') then null else trim(module_type) end as module_type,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.SYS_Dict_STG
where dt = @dt
END

GO
