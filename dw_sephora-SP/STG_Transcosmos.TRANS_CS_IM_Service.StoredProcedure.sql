/****** Object:  StoredProcedure [STG_Transcosmos].[TRANS_CS_IM_Service]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Transcosmos].[TRANS_CS_IM_Service] @dt [VARCHAR](10) AS
BEGIN
delete from STG_Transcosmos.CS_IM_Service where dt = @dt ;
insert into STG_Transcosmos.CS_IM_Service
select 
    case when trim(lower([service_id])) in ('null','') then null else  trim([service_id]) end as [service_id],
	case when trim(lower([tenant_id])) in ('null','') then null else  trim([tenant_id]) end as [tenant_id],
	case when trim(lower([access_id])) in ('null','') then null else  trim([access_id]) end as [access_id],
	case when trim(lower([group_id])) in ('null','') then null else  trim([group_id]) end as [group_id],
	case when trim(lower([group_name])) in ('null','') then null else  trim([group_name]) end as [group_name],
	case when trim(lower([agent_id])) in ('null','') then null else  trim([agent_id]) end as [agent_id],
	case when trim(lower([agent_job_num])) in ('null','') then null else  trim([agent_job_num]) end as [agent_job_num],
	case when trim(lower([agent_name])) in ('null','') then null else  trim([agent_name]) end as [agent_name],
	case when trim(lower([visitor_id])) in ('null','') then null else  trim([visitor_id]) end as [visitor_id],
	case when trim(lower([visitor_name])) in ('null','') then null else  trim([visitor_name]) end as [visitor_name],
	case when trim(lower([third_part_node_id])) in ('null','') then null else  trim([third_part_node_id]) end as [third_part_node_id],
	case when trim(lower([third_part_visitor_id])) in ('null','') then null else  trim([third_part_visitor_id]) end as [third_part_visitor_id],
	case when trim(lower([third_part_service_id])) in ('null','') then null else  trim([third_part_service_id]) end as [third_part_service_id],
	case when trim(lower([third_part_visitor_name])) in ('null','') then null else  trim([third_part_visitor_name]) end as [third_part_visitor_name],
	case when trim(lower([ip])) in ('null','') then null else  trim([ip]) end as [ip],
	case when trim(lower([region])) in ('null','') then null else  trim([region]) end as [region],
	case when trim(lower([platform_id])) in ('null','') then null else  trim([platform_id]) end as [platform_id],
	case when trim(lower([platform_name])) in ('null','') then null else  trim([platform_name]) end as [platform_name],
	case when trim(lower([platform_tenant_id])) in ('null','') then null else  trim([platform_tenant_id]) end as [platform_tenant_id],
	case when trim(lower([platform_tenant_name])) in ('null','') then null else  trim([platform_tenant_name]) end as [platform_tenant_name],
	case when trim(lower([platform_type_id])) in ('null','') then null else  trim([platform_type_id]) end as [platform_type_id],
	case when trim(lower([platform_type_name])) in ('null','') then null else  trim([platform_type_name]) end as [platform_type_name],
	case when trim(lower([platform_channel_code])) in ('null','') then null else  trim([platform_channel_code]) end as [platform_channel_code],
	case when trim(lower([platform_channel_name])) in ('null','') then null else  trim([platform_channel_name]) end as [platform_channel_name],
	case when trim(lower([create_type])) in ('null','') then null else  trim([create_type]) end as [create_type],
	case when trim(lower([service_type])) in ('null','') then null else  trim([service_type]) end as [service_type],
	[access_time],
	[begin_time],
	[end_time],
	[status],
	case when trim(lower([end_reason])) in ('null','') then null else  trim([end_reason]) end as [end_reason],
	case when trim(lower([transfer_service_id])) in ('null','') then null else  trim([transfer_service_id]) end as [transfer_service_id],
	case when trim(lower([satisfaction])) in ('null','') then null else  trim([satisfaction]) end as [satisfaction],
	[quality_status],
	case when trim(lower([summary_id])) in ('null','') then null else  trim([summary_id]) end as [summary_id],
	[visitor_last_time],
	case when trim(lower([visitor_last_time_message])) in ('null','') then null else  trim([visitor_last_time_message]) end as [visitor_last_time_message],
	[agent_last_time],
	case when trim(lower([agent_last_time_message])) in ('null','') then null else  trim([agent_last_time_message]) end as [agent_last_time_message],
    [message_count],
    current_timestamp as insert_timestamp,
	@dt
from 
    ODS_Transcosmos.CS_IM_Service
where dt = @dt
END



GO
