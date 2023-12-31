/****** Object:  StoredProcedure [STG_MA].[TRANS_Wechat_Template_Task]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_Wechat_Template_Task] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       hsq           Initial Version
-- ========================================================================================
truncate table STG_MA.Wechat_Template_Task;
insert into STG_MA.Wechat_Template_Task
select 
		case when trim(id) in ('','null') then null else trim(id) end as id,
		target_user_source,
		send_type,
		case when trim(preview_user_openid) in ('','null') then null else trim(preview_user_openid) end as preview_user_openid,
		wxtag_id,
		case when trim(seg_rulesetting_id) in ('','null') then null else trim(seg_rulesetting_id) end as seg_rulesetting_id,
		case when trim(temp_table_name) in ('','null') then null else trim(temp_table_name) end as temp_table_name,
		case when trim(temp_column_name) in ('','null') then null else trim(temp_column_name) end as temp_column_name,
		case when lower(is_drop_table) = 'true' then 1 when lower(is_drop_table) = 'false' then 0 else null end is_drop_table,
		case when trim(template_customize_id) in ('','null') then null else trim(template_customize_id) end as template_customize_id,
		case when trim(template_id) in ('','null') then null else trim(template_id) end as template_id,
		case when trim(data) in ('','null') then null else trim(data) end as data,
		case when trim(url) in ('','null') then null else trim(url) end as url,
		case when trim(miniprogram) in ('','null') then null else trim(miniprogram) end as miniprogram,
		start_time,
		end_time,
		task_status,
		case when trim(task_remark) in ('','null') then null else trim(task_remark) end as task_remark,
		total_qty,
		success_qty,
		failed_qty,
		case when trim(publicaccountid) in ('','null') then null else trim(publicaccountid) end as publicaccountid,
		case when trim(remark_back) in ('','null') then null else trim(remark_back) end as remark_back,
		case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
		case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
		create_user_id,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		update_user_id,
		version,
		current_timestamp as insert_timestamp
from    ODS_MA.Wechat_Template_Task
where   dt = @dt
END
GO
