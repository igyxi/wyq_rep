/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Marking_Relation]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Marking_Relation] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SmartBA.T_Marking_Relation;
insert into STG_SmartBA.T_Marking_Relation
select 
		id,
		case when trim(unionid) in ('','null') then null else trim(unionid) end as unionid,
		case when trim(external_userid) in ('','null') then null else trim(external_userid) end as external_userid,
		case when trim(emp_userid) in ('','null') then null else trim(emp_userid) end as emp_userid,
		bind_time,
		case when trim(tag_name) in ('','null') then null else trim(tag_name) end as tag_name,
		case when trim(wxcp_code) in ('','null') then null else trim(wxcp_code) end as wxcp_code,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id,unionid order by dt desc) rownum from ODS_SmartBA.T_Marking_Relation
) t
where rownum = 1
END
GO
