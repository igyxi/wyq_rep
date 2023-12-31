/****** Object:  StoredProcedure [STG_Live].[TRANS_Room_Attends]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Live].[TRANS_Room_Attends] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Live.Room_Attends;
insert into STG_Live.Room_Attends
select 
		id,
		il_id,
		account_id,
		watch_account_id,
		case when trim(third_user_id) in ('','null') then null else trim(third_user_id) end as third_user_id,
		start_time,
		end_time,
		duration,
		case when trim(terminal) in ('','null') then null else trim(terminal) end as terminal,
		case when trim(browser) in ('','null') then null else trim(browser) end as browser,
		case when trim(country) in ('','null') then null else trim(country) end as country,
		case when trim(province) in ('','null') then null else trim(province) end as province,
		type,
		created_time,
		updated_at,
		created_at,
		deleted_at,
		current_timestamp as insert_timestamp
from    
(
    select *, row_number() over(partition by id order by dt) rownum from ODS_Live.Room_Attends
) t
where t.rownum = 1
END
GO
