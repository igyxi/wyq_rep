/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Event]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Event] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Event;
insert into STG_MA.CRM_Event
select 
		event_id,
		case when trim(event_name) in ('','null') then null else trim(event_name) end as event_name,
		event_type,
		status,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		is_delete,
		bu_id,
		owner_id,
		create_user_id,
		case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
		case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
		update_user_id,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		version,
		activity_process_selection,
		template_event_id,
		flow,
		current_timestamp as insert_timestamp
from    ODS_MA.CRM_Event
where   dt = @dt
END
GO
