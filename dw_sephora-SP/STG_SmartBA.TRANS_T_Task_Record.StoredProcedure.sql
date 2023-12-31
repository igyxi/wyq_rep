/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Task_Record]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Task_Record] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-13       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SmartBA.T_Task_Record;
insert into STG_SmartBA.T_Task_Record
select 
		id,
		task_id,
		rule_id,
		user_id,
		case when trim(wx_unionid) in ('','null') then null else trim(wx_unionid) end as wx_unionid,
		case when trim(head_img) in ('','null') then null else trim(head_img) end as head_img,
		case when trim(nickname) in ('','null') then null else trim(nickname) end as nickname,
		status,
		store_id,
		case when trim(store_code) in ('','null') then null else trim(store_code) end as store_code,
		company_id,
		tenant_id,
		create_time,
		update_time,
		case when trim(msg_id) in ('','null') then null else trim(msg_id) end as msg_id,
		case when trim(store_name) in ('','null') then null else trim(store_name) end as store_name,
		target,
		undone,
		complete,
		fail,
		end_time,
		case when trim(emp_wxcp_userid) in ('','null') then null else trim(emp_wxcp_userid) end as emp_wxcp_userid,
		case when trim(emp_number) in ('','null') then null else trim(emp_number) end as emp_number,
		current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by id order by dt desc) rownum from [ODS_SmartBA].[T_Task_Record]
) t
where rownum =  1
END
GO
