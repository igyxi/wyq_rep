/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Business_Group_Send_Result]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Business_Group_Send_Result] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SmartBA.T_Business_Group_Send_Result;
insert into STG_SmartBA.T_Business_Group_Send_Result
select 
		id,
		task_id,
		case when trim(emp_name) in ('','null') then null else trim(emp_name) end as emp_name,
		case when trim(emp_code) in ('','null') then null else trim(emp_code) end as emp_code,
		case when trim(userid) in ('','null') then null else trim(userid) end as userid,
		case when trim(msg_id) in ('','null') then null else trim(msg_id) end as msg_id,
		case when trim(external_userid) in ('','null') then null else trim(external_userid) end as external_userid,
		case when trim(customer_unionid) in ('','null') then null else trim(customer_unionid) end as customer_unionid,
		case when trim(chat_id) in ('','null') then null else trim(chat_id) end as chat_id,
		status,
		send_time,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by task_id,userid,external_userid,msg_id order by dt desc) rownum from ODS_SmartBA.T_Business_Group_Send_Result
) t
where rownum = 1
END
GO
