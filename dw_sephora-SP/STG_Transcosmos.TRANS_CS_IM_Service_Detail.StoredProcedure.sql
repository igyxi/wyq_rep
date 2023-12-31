/****** Object:  StoredProcedure [STG_Transcosmos].[TRANS_CS_IM_Service_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Transcosmos].[TRANS_CS_IM_Service_Detail] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-28       wangzhichun           Initial Version
-- ========================================================================================
delete from STG_Transcosmos.CS_IM_Service_Detail where dt = @dt;
insert into STG_Transcosmos.CS_IM_Service_Detail
select 
		case when trim(service_id) in ('','null') then null else trim(service_id) end as service_id,
		case when trim(tenant_id) in ('','null') then null else trim(tenant_id) end as tenant_id,
		service_duration,
		queue_duration,
		first_response_duration,
		service_vaild,
		agent_message_count,
		visitor_message_count,
		revocation_count,
		overtime_num,
		take_invite,
		response_duration,
		send_offlineMsg,
		send_firstMsg,
		message_count,
		is_evaluate,
		is_voice,
		chat_turn,
		current_timestamp as insert_timestamp,
        @dt
from    
    ODS_Transcosmos.CS_IM_Service_Detail
where 
    dt = @dt
END
GO
