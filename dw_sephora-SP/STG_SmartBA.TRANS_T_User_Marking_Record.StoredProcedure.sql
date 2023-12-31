/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_User_Marking_Record]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_User_Marking_Record] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-04       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SmartBA.T_User_Marking_Record;
insert into STG_SmartBA.T_User_Marking_Record
select
		id,
		case when trim(union_id) in ('','null') then null else trim(union_id) end as union_id,
		case when trim(emp_wxcp_userid) in ('','null') then null else trim(emp_wxcp_userid) end as emp_wxcp_userid,
		case when trim(wxcp_userid) in ('','null') then null else trim(wxcp_userid) end as wxcp_userid,
		case when trim(emp_code) in ('','null') then null else trim(emp_code) end as emp_code,
		case when trim(label_code) in ('','null') then null else trim(label_code) end as label_code,
		case when trim(label_name) in ('','null') then null else trim(label_name) end as label_name,
		case when trim(unique_ident) in ('','null') then null else trim(unique_ident) end as unique_ident,
		status,
		type,
		case when trim(wx_message) in ('','null') then null else trim(wx_message) end as wx_message,
		create_time,
		case when trim(create_user) in ('','null') then null else trim(create_user) end as create_user,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id,union_id order by dt desc) rownum from ODS_SmartBA.T_User_Marking_Record
) t
where rownum = 1
END
GO
