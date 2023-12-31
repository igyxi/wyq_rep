/****** Object:  StoredProcedure [TEMP].[SP_Fact_OBC_Service_bak_20230517]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_OBC_Service_bak_20230517] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-11       weichen           Initial Version
-- ========================================================================================
truncate table DWD.Fact_OBC_Service;
insert into DWD.Fact_OBC_Service
SELECT 
	a.[service_id],
	a.[tenant_id],
	a.[group_id],
	a.[group_name],
	a.[agent_id],
	a.[agent_job_num],
	a.[agent_name],
	a.[platform_channel_code],
	a.[platform_channel_name],
	a.[create_type],
	a.[service_type],
	a.[access_time],
	a.[begin_time],
	a.[end_time],
	a.[status],
	a.[end_reason],
	a.[satisfaction],
	a.[quality_status],
	b.[service_vaild],
	b.[agent_message_count],
	b.[visitor_message_count],
	b.[message_count],
	b.[revocation_count],
	b.[overtime_num],
	b.[take_invite],
	b.[response_duration],
	b.[send_offlineMsg],
	b.[send_firstMsg],
	b.[is_evaluate],
	b.[is_voice],
	b.[chat_turn],
	current_timestamp as insert_timestamp
FROM STG_Transcosmos.CS_IM_Service a 
left join STG_Transcosmos.CS_IM_Service_Detail b on a.[service_id]=b.[service_id] and a.[tenant_id]=b.[tenant_id]
 ;
END
GO
