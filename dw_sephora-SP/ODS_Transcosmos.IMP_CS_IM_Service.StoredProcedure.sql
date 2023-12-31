/****** Object:  StoredProcedure [ODS_Transcosmos].[IMP_CS_IM_Service]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Transcosmos].[IMP_CS_IM_Service] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Transcosmos.CS_IM_Service where dt = @dt;
insert into ODS_Transcosmos.CS_IM_Service
select 
    a.service_id,
    a.tenant_id,
    a.access_id,
    a.group_id,
    a.group_name,
    a.agent_id,
    a.agent_job_num,
    a.agent_name,
    a.visitor_id,
    a.visitor_name,
    a.third_part_node_id,
    a.third_part_visitor_id,
    a.third_part_service_id,
    a.third_part_visitor_name,
    a.ip,
    a.region,
    a.platform_id,
    a.platform_name,
    a.platform_tenant_id,
    a.platform_tenant_name,
    a.platform_type_id,
    a.platform_type_name,
    a.platform_channel_code,
    a.platform_channel_name,
    a.create_type,
    a.service_type,
    a.access_time,
    a.begin_time,
    a.end_time,
    a.status,
    a.end_reason,
    a.transfer_service_id,
    a.satisfaction,
    a.quality_status,
    a.summary_id,
    a.visitor_last_time,
    a.visitor_last_time_message,
    a.agent_last_time,
    a.agent_last_time_message,
    a.message_count,
    @dt
from 
    ODS_Transcosmos.WRK_CS_IM_Service a
left join
(
    select * from ODS_Transcosmos.CS_IM_Service where dt <= cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) b
on a.service_id = b.service_id
where b.service_id is null;
truncate table ODS_Transcosmos.WRK_CS_IM_Service;
END

GO
