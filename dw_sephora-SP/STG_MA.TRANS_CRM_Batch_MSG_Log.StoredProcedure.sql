/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Batch_MSG_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Batch_MSG_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Batch_MSG_Log;
insert into STG_MA.CRM_Batch_MSG_Log
select 
		id,
		batch_msg_id,
		message_type,
		case when trim(template_id) in ('','null') then null else trim(template_id) end as template_id,
		record_num,
		status,
		create_user_id,
		case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
		case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
		cast(concat_ws(' ',cast(create_date as date),concat_ws(':',substring(create_time,1,2),substring(create_time,3,2),substring(create_time,5,2))) as datetime)as create_datetime,
		update_user_id,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		cast(concat_ws(' ',cast(update_date as date),concat_ws(':',substring(update_time,1,2),substring(update_time,3,2),substring(update_time,5,2))) as datetime)as update_datetime,
		version,
		is_test,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		case when trim(loop) in ('','null') then null else trim(loop) end as loop,
		current_timestamp as insert_timestamp
from    
    ODS_MA.CRM_Batch_MSG_Log
where   
    dt = @dt
END
GO
