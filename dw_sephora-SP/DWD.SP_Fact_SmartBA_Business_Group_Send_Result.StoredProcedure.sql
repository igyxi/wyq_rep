/****** Object:  StoredProcedure [DWD].[SP_Fact_SmartBA_Business_Group_Send_Result]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_SmartBA_Business_Group_Send_Result] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-10       leozhai        Initial Version
-- ========================================================================================
delete from DWD.Fact_SmartBA_Business_Group_Send_Result where format(create_time, 'yyyy-MM-dd') = @dt;
insert into DWD.Fact_SmartBA_Business_Group_Send_Result
select
	id,
	task_id,
	emp_name,
	emp_code,
	userid,
	msg_id,
	external_userid,
	customer_unionid,
	chat_id,
	status,
	send_time,
	create_time,
	update_time,
    'SmartBA' as source,
    current_timestamp as insert_timestamp
from
    STG_SmartBA.T_Business_Group_Send_Result
where
	format(create_time, 'yyyy-MM-dd') = @dt
END


GO
