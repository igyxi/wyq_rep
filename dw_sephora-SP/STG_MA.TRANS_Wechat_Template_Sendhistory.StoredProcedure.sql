/****** Object:  StoredProcedure [STG_MA].[TRANS_Wechat_Template_Sendhistory]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_Wechat_Template_Sendhistory] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.Wechat_Template_Sendhistory;
insert into STG_MA.Wechat_Template_Sendhistory
select 
		case when trim(id) in ('','null') then null else trim(id) end as id,
		case when trim(template_task_id) in ('','null') then null else trim(template_task_id) end as template_task_id,
		send_time,
		case when trim(touser) in ('','null') then null else trim(touser) end as touser,
		case when trim(template_id) in ('','null') then null else trim(template_id) end as template_id,
		case when trim(url) in ('','null') then null else trim(url) end as url,
		case when trim(miniprogram) in ('','null') then null else trim(miniprogram) end as miniprogram,
		case when trim(data) in ('','null') then null else trim(data) end as data,
		errcode,
		case when trim(errmsg) in ('','null') then null else trim(errmsg) end as errmsg,
		msgid,
		case when trim(send_status) in ('','null') then null else trim(send_status) end as send_status,
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
from    ODS_MA.Wechat_Template_Sendhistory
where   dt = @dt
END
GO
