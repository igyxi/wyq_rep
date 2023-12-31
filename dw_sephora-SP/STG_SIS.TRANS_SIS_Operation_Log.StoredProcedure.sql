/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Operation_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Operation_Log] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-26       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Operation_Log;
insert into STG_SIS.SIS_Operation_Log
select 
		id,
		activity_id,
		company_id,
		case when trim(open_id) in ('','null') then null else trim(open_id) end as open_id,
		case when trim(card_no) in ('','null') then null else trim(card_no) end as card_no,
		case when trim(operation_type) in ('','null') then null else trim(operation_type) end as operation_type,
		case when trim(operation_description) in ('','null') then null else trim(operation_description) end as operation_description,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from
(
    select *,row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Operation_Log
) t
where rownum = 1
END
GO
