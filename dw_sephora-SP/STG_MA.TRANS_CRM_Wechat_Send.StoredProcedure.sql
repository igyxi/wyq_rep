/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Wechat_Send]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Wechat_Send] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Wechat_Send;
insert into STG_MA.CRM_Wechat_Send
select 
		id,
		mkt_id,
		mkt_type,
		case when trim(wechat_id) in ('','null') then null else trim(wechat_id) end as wechat_id,
		case when trim(send_content) in ('','null') then null else trim(send_content) end as send_content,
		case when trim(channel) in ('','null') then null else trim(channel) end as channel,
		case when trim(member_code) in ('','null') then null else trim(member_code) end as member_code,
		case when trim(loop) in ('','null') then null else trim(loop) end as loop,
		send_datetime,
		send_status,
		create_datetime,
		case when trim(template_id) in ('','null') then null else trim(template_id) end as template_id,
		node_id,
		case when trim(jump_url) in ('','null') then null else trim(jump_url) end as jump_url,
		failed_handle_result,
		case when trim(report_result) in ('','null') then null else trim(report_result) end as report_result,
		case when trim(tempalte_redirect_url) in ('','null') then null else trim(tempalte_redirect_url) end as tempalte_redirect_url,
		case when trim(data_type) in ('','null') then null else trim(data_type) end as data_type,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		case when trim(wx_message_id) in ('','null') then null else trim(wx_message_id) end as wx_message_id,
		case when trim(wx_send_status) in ('','null') then null else trim(wx_send_status) end as wx_send_status,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_MA.CRM_Wechat_Send
) t
where rownum = 1;
END
GO
