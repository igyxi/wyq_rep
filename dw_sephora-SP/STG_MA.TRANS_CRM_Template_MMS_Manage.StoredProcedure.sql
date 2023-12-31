/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Template_MMS_Manage]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Template_MMS_Manage] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       hsq           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Template_MMS_Manage;
insert into STG_MA.CRM_Template_MMS_Manage
select 
		id,
		case when trim(theme) in ('','null') then null else trim(theme) end as theme,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(template_content) in ('','null') then null else trim(template_content) end as template_content,
		channel_id,
		bu_id,
		case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
		case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
        -- cast(concat_ws(' ',cast(create_date as date),concat_ws(':',substring(create_time,1,2),substring(create_time,3,2),substring(create_time,5,2))) as datetime) create_datetime,
		create_user_id,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
        -- cast(concat_ws(' ',cast(update_date as date),concat_ws(':',substring(update_time,1,2),substring(update_time,3,2),substring(update_time,5,2))) as datetime)as update_datetime,
		update_user_id,
		case when trim(status) in ('','null') then null else trim(status) end as status,
		version,
		case when trim(template_id) in ('','null') then null else trim(template_id) end as template_id,
		case when trim(yp_statusjson) in ('','null') then null else trim(yp_statusjson) end as yp_statusjson,
		current_timestamp as insert_timestamp
from    ODS_MA.CRM_Template_MMS_Manage
where   dt = @dt
END
GO
