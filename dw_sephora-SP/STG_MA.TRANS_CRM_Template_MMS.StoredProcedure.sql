/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Template_MMS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Template_MMS] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       hsq           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Template_MMS;
insert into STG_MA.CRM_Template_MMS
select 
		id,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(theme) in ('','null') then null else trim(theme) end as theme,
		case when trim(send_content) in ('','null') then null else trim(send_content) end as send_content,
		case when trim(send_content_format) in ('','null') then null else trim(send_content_format) end as send_content_format,
		case when trim(in_param) in ('','null') then null else trim(in_param) end as in_param,
		is_delete,
		bu_id,
		owner_id,
		create_user_id,
		case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
		case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
        --cast(concat_ws(' ',cast(create_date as date),concat_ws(':',substring(create_time,1,2),substring(create_time,3,2),substring(create_time,5,2))) as datetime) create_datetime,
		update_user_id,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		--cast(concat_ws(' ',cast(update_date as date),concat_ws(':',substring(update_time,1,2),substring(update_time,3,2),substring(update_time,5,2))) as datetime)as update_datetime,
        version,
		type,
		case when trim(msg_id) in ('','null') then null else trim(msg_id) end as msg_id,
        case when lower(status) = 'true' then 1 when lower(status) = 'false' then 0 else null end status,
		case when trim(content_preview) in ('','null') then null else trim(content_preview) end as content_preview,
		case when trim(template_content) in ('','null') then null else trim(template_content) end as template_content,
		case when trim(content_param) in ('','null') then null else trim(content_param) end as content_param,
		channel_id,
		template_manage_id,
		current_timestamp as insert_timestamp
from    ODS_MA.CRM_Template_MMS
where   dt = @dt
END
GO
