/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Template_Video_SMS]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Template_Video_SMS] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       hsq           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Template_Video_SMS;
insert into STG_MA.CRM_Template_Video_SMS
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
		-- cast(concat_ws(' ',cast(create_date as date),concat_ws(':',substring(create_time,1,2),substring(create_time,3,2),substring(create_time,5,2))) as datetime) create_datetime,
		update_user_id,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		-- cast(concat_ws(' ',cast(update_date as date),concat_ws(':',substring(update_time,1,2),substring(update_time,3,2),substring(update_time,5,2))) as datetime)as update_datetime,
		version,
		[type],
		status,
		case when trim(platform_template_id) in ('','null') then null else trim(platform_template_id) end as platform_template_id,
		current_timestamp as insert_timestamp
from    ODS_MA.CRM_Template_Video_SMS
where   dt = @dt
END
GO
