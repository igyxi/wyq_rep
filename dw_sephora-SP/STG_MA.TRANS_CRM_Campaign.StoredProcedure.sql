/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Campaign]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Campaign] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-15       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Campaign;
insert into STG_MA.CRM_Campaign
select 
		campaign_id,
		case when trim(campaign_name) in ('','null') then null else trim(campaign_name) end as campaign_name,
		case when trim(campaign_type) in ('','null') then null else trim(campaign_type) end as campaign_type,
		status,
		start_date,
		end_date,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		case when trim(is_blacklist) in ('','null') then null else trim(is_blacklist) end as is_blacklist,
		bu_id,
		owner_id,
		create_user_id,
		case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
		case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
		update_user_id,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		version,
		test_status,
		activity_process_selection,
		template_campaign_id,
		is_open_silent,
		case when trim(silent_begin_time) in ('','null') then null else trim(silent_begin_time) end as silent_begin_time,
		case when trim(silent_end_time) in ('','null') then null else trim(silent_end_time) end as silent_end_time,
		campaign_type_id,
		case when trim(campaign_project) in ('','null') then null else trim(campaign_project) end as campaign_project,
		case when trim(campaign_channel) in ('','null') then null else trim(campaign_channel) end as campaign_channel,
		trace_start_date,
		trace_end_date,
		case when trim(segment_type) in ('','null') then null else trim(segment_type) end as segment_type,
		case when trim(campaign_target) in ('','null') then null else trim(campaign_target) end as campaign_target,
		case when trim(campaign_mechanism) in ('','null') then null else trim(campaign_mechanism) end as campaign_mechanism,
		case when trim(campaign_class) in ('','null') then null else trim(campaign_class) end as campaign_class,
		edition,
		test_times,
		case when trim(deployment_id) in ('','null') then null else trim(deployment_id) end as deployment_id,
		case when trim(process_instance_id) in ('','null') then null else trim(process_instance_id) end as process_instance_id,
		case when trim(campaign_budget) in ('','null') then null else trim(campaign_budget) end as campaign_budget,
		case when trim(sales_target) in ('','null') then null else trim(sales_target) end as sales_target,
		case when trim(campaign_category) in ('','null') then null else trim(campaign_category) end as campaign_category,
		special_days,
		case when trim(campaign_report_notice_type) in ('','null') then null else trim(campaign_report_notice_type) end as campaign_report_notice_type,
		case when trim(campaign_report_notice_email) in ('','null') then null else trim(campaign_report_notice_email) end as campaign_report_notice_email,
		case when trim(promotion_sku) in ('','null') then null else trim(promotion_sku) end as promotion_sku,
		case when trim(clickhouse_types) in ('','null') then null else trim(clickhouse_types) end as clickhouse_types,
		case when trim(business_campaign_name) in ('','null') then null else trim(business_campaign_name) end as business_campaign_name,
		case when trim(business_campaign_wave) in ('','null') then null else trim(business_campaign_wave) end as business_campaign_wave,
		case when trim(trace_type) in ('','null') then null else trim(trace_type) end as trace_type,
		current_timestamp as insert_timestamp
from    ODS_MA.CRM_Campaign
where   dt = @dt
END
GO
