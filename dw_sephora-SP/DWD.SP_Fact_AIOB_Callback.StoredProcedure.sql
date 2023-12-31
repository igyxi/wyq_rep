/****** Object:  StoredProcedure [DWD].[SP_Fact_AIOB_Callback]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_AIOB_Callback] @dt [nvarchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-24      	wangziming    Initial Version
-- ========================================================================================
delete from DWD.Fact_AIOB_Callback where format(insert_timestamp,'yyyy-MM-dd')= @dt;

insert into DWD.Fact_AIOB_Callback
select  
	[venderName] as [vender_name],
	[jobName] as [job_name],
	[maJobId] as [ma_job_id],
	[customerTelephone] as [customer_telephone],
	[callStartTime] as [call_start_time],
	[startTime] as [start_time],
	[endTime] as [end_time],
	[callStatus] as [call_status],
	[ifAnswer] as [is_answer],
	[callDuration] as [call_duration],
	[chatRound] as [chat_round],
	[ifHangupFw] as [is_hangup_fw],
	[hangUp] as [hangup],
	[hangNodeName] as [hang_node_name],
	[redialTimes] as [redial_times],
	[intentLabels] as [intent_labels],
	[insert_timestamp] as [insert_timestamp]
from [REALTIME_MessageCenter].[AIOB_Entity]
where format(insert_timestamp,'yyyy-MM-dd')= @dt
;
END
GO
