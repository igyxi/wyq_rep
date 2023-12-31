/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_News_Send]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_News_Send] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_News_Send;
insert into STG_MA.CRM_News_Send
select 
		id,
		mkt_id,
		mkt_type,
		case when trim(wechat_id) in ('','null') then null else trim(wechat_id) end as wechat_id,
		case when trim(channel) in ('','null') then null else trim(channel) end as channel,
		case when trim(member_code) in ('','null') then null else trim(member_code) end as member_code,
		case when trim(loop) in ('','null') then null else trim(loop) end as loop,
		send_datetime,
		send_status,
		create_datetime,
		case when trim(media_id) in ('','null') then null else trim(media_id) end as media_id,
		node_id,
		failed_handle_result,
		case when trim(report_result) in ('','null') then null else trim(report_result) end as report_result,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		current_timestamp as insert_timestamp
from    
    ODS_MA.CRM_News_Send
where   dt = @dt
END
GO
