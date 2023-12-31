/****** Object:  StoredProcedure [STG_Live].[TRANS_Room_Share_Events]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Live].[TRANS_Room_Share_Events] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Live.Room_Share_Events;
insert into STG_Live.Room_Share_Events
select 
		id,
		il_id,
		account_id,
		channel,
		created_at,
		updated_at,
		deleted_at,
		current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by id order by dt) rownum from ODS_Live.Room_Share_Events
) t
where t.rownum = 1
END
GO
