/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Moment_Send_Result]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Moment_Send_Result] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-17      litao           Initial Version
-- 2022-11-30      wangzhichun     update data sources
-- ========================================================================================

truncate table STG_SmartBA.T_Moment_Send_Result;
insert into STG_SmartBA.T_Moment_Send_Result
select 
		id,
		task_id,
		task_record_id, 
		case when trim(moment_id) in ('','null') then null else trim(moment_id) end as moment_id,
		case when trim(userid) in ('','null') then null else trim(userid) end as userid,
		case when trim(external_userid) in ('','null') then null else trim(external_userid) end as external_userid,
		case when trim(customer_unionid) in ('','null') then null else trim(customer_unionid) end as customer_unionid,
		create_time,
		current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by moment_id,external_userid,userid order by dt desc) rownum from [ODS_SmartBA].[T_Moment_Send_Result]
) t
where rownum =  1
END
 
GO
