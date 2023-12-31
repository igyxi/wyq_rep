/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Campaign_Report_Daily]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Campaign_Report_Daily] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Campaign_Report_Daily;
insert into STG_MA.CRM_Campaign_Report_Daily
select 
		id,
		campaign_id,
		case when trim(campaign_type) in ('','null') then null else trim(campaign_type) end as campaign_type,
		case when trim(campaign_name) in ('','null') then null else trim(campaign_name) end as campaign_name,
		case when trim(campaign_channel) in ('','null') then null else trim(campaign_channel) end as campaign_channel,
        campaign_start_date,
		campaign_end_date,
		case when trim(trace_type) in ('','null') then null else trim(trace_type) end as trace_type,
		report_date,
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
    ODS_MA.CRM_Campaign_Report_Daily
where   
    dt = @dt
END
GO
