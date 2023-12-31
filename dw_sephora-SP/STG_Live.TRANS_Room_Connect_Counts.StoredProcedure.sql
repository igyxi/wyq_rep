/****** Object:  StoredProcedure [STG_Live].[TRANS_Room_Connect_Counts]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Live].[TRANS_Room_Connect_Counts] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Live.Room_Connect_Counts;
insert into STG_Live.Room_Connect_Counts
select 
		id,
		il_id,
		case when trim(channel) in ('','null') then null else trim(channel) end as channel,
		count,
		created_at,
		updated_at,
		deleted_at,
		account_id,
		create_time,
		current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by id order by dt) rownum from ODS_Live.Room_Connect_Counts
) t
where t.rownum = 1
END
GO
