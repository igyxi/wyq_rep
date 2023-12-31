/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Mail_Send]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Mail_Send] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Mail_Send;
insert into STG_MA.CRM_Mail_Send
select 
		id,
		mkt_id,
		mkt_type,
		case when trim(mailbox) in ('','null') then null else trim(mailbox) end as mailbox,
		case when trim(send_content) in ('','null') then null else trim(send_content) end as send_content,
		case when trim(channel) in ('','null') then null else trim(channel) end as channel,
		case when trim(member_code) in ('','null') then null else trim(member_code) end as member_code,
		case when trim(loop) in ('','null') then null else trim(loop) end as loop,
		send_datetime,
		send_status,
        create_datetime,
		template_id,
		node_id,
		failed_handle_result,
		case when trim(report_result) in ('','null') then null else trim(report_result) end as report_result,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		case when trim(msgid) in ('','null') then null else trim(msgid) end as msgid,
		case when trim(data_type) in ('','null') then null else trim(data_type) end as data_type,
		current_timestamp as insert_timestamp
from    ODS_MA.CRM_Mail_Send
where   dt = @dt
END
GO
