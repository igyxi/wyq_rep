/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Template_Wechat]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Template_Wechat] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       hsq           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Template_Wechat;
insert into STG_MA.CRM_Template_Wechat
select 
		id,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(theme) in ('','null') then null else trim(theme) end as theme,
		case when trim(send_content) in ('','null') then null else trim(send_content) end as send_content,
		case when trim(send_content_format) in ('','null') then null else trim(send_content_format) end as send_content_format,
		case when trim(in_param) in ('','null') then null else trim(in_param) end as in_param,
		case when trim(tem_id) in ('','null') then null else trim(tem_id) end as tem_id,
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
		type,
		current_timestamp as insert_timestamp
from    ODS_MA.CRM_Template_Wechat
where   dt = @dt
END
GO
