/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Message_Box_Send]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Message_Box_Send] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Message_Box_Send;
insert into STG_MA.CRM_Message_Box_Send
select 
		id,
		mkt_id,
		mkt_type,
		case when trim(user_id) in ('','null') then null else trim(user_id) end as user_id,
		case when trim(member_code) in ('','null') then null else trim(member_code) end as member_code,
		case when trim(loop) in ('','null') then null else trim(loop) end as loop,
        send_datetime,
		send_status,
        create_datetime,
		node_id,
		case when trim(template_id) in ('','null') then null else trim(template_id) end as template_id,
		case when trim(msgid) in ('','null') then null else trim(msgid) end as msgid,
		case when trim(data_type) in ('','null') then null else trim(data_type) end as data_type,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		current_timestamp as insert_timestamp
from    
    ODS_MA.CRM_Message_Box_Send
where   dt = @dt
END
GO
