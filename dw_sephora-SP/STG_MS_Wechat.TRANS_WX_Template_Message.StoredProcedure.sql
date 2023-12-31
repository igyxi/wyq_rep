/****** Object:  StoredProcedure [STG_MS_Wechat].[TRANS_WX_Template_Message]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MS_Wechat].[TRANS_WX_Template_Message] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-25       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MS_Wechat.WX_Template_Message;
insert into STG_MS_Wechat.WX_Template_Message
select 
		id,
		message,
		status,
		case when trim(fail_reason) in ('','null') then null else trim(fail_reason) end as fail_reason,
		send_status,
		case when trim(send_fail_reason) in ('','null') then null else trim(send_fail_reason) end as send_fail_reason,
		case when trim(openid) in ('','null') then null else trim(openid) end as openid,
		case when trim(msg_id) in ('','null') then null else trim(msg_id) end as msg_id,
		template_type,
		case when trim(template_name) in ('','null') then null else trim(template_name) end as template_name,
		case when trim(template_id) in ('','null') then null else trim(template_id) end as template_id,
		case when trim(notify) in ('','null') then null else trim(notify) end as notify,
		case when trim(appid) in ('','null') then null else trim(appid) end as appid,
		case when trim(appkey) in ('','null') then null else trim(appkey) end as appkey,
		created_at,
		updated_at,
        is_new,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from [ODS_MS_Wechat].[WX_Template_Message]
) t
where rownum = 1
END
GO
