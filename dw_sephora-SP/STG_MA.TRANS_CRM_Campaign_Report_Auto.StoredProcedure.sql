/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Campaign_Report_Auto]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Campaign_Report_Auto] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Campaign_Report_Auto;
insert into STG_MA.CRM_Campaign_Report_Auto
select 
		id,
		campaign_id,
		case when trim(campaign_type) in ('','null') then null else trim(campaign_type) end as campaign_type,
		case when trim(campaign_name) in ('','null') then null else trim(campaign_name) end as campaign_name,
		case when trim(campaign_channel) in ('','null') then null else trim(campaign_channel) end as campaign_channel,
		case when trim(campaign_start_date) in ('','null') then null else trim(campaign_start_date) end as campaign_start_date,
		case when trim(campaign_end_date) in ('','null') then null else trim(campaign_end_date) end as campaign_end_date,
		case when trim(trace_type) in ('','null') then null else trim(trace_type) end as trace_type,
		case when trim(report_start_date) in ('','null') then null else trim(report_start_date) end as report_start_date,
		case when trim(report_end_date) in ('','null') then null else trim(report_end_date) end as report_end_date,
		campaign_num,
		coupon_num,
		sms_num,
		mms_num,
		video_num,
		wechat_num,
		mail_num,
		app_num,
		internal_num,
		current_timestamp as insert_timestamp
from
    ODS_MA.CRM_Campaign_Report_Auto
where   
    dt = @dt
END
GO
