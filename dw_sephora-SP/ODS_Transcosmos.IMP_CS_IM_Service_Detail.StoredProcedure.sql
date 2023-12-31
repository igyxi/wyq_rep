/****** Object:  StoredProcedure [ODS_Transcosmos].[IMP_CS_IM_Service_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Transcosmos].[IMP_CS_IM_Service_Detail] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-28       wangzhichun           Initial Version
-- ========================================================================================
delete from ODS_Transcosmos.CS_IM_Service_Detail where dt = @dt;
insert into ODS_Transcosmos.CS_IM_Service_Detail
select 
    a.service_id,
    a.tenant_id,
    a.service_duration,
    a.queue_duration,
    a.first_response_duration,
    a.service_vaild,
    a.agent_message_count,
    a.visitor_message_count,
    a.revocation_count,
    a.overtime_num,
    a.take_invite,
    a.response_duration,
    a.send_offlineMsg,
    a.send_firstMsg,
    a.message_count,
    a.is_evaluate,
    a.is_voice,
    a.chat_turn,
    @dt
from 
    ODS_Transcosmos.WRK_CS_IM_Service_Detail a
left join
(
    select * from ODS_Transcosmos.CS_IM_Service_Detail where dt <= cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) b
on a.service_id = b.service_id
where b.service_id is null;
truncate table ODS_Transcosmos.WRK_CS_IM_Service_Detail;
END

GO
