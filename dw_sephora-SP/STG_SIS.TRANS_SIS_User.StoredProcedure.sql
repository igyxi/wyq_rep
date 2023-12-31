/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_User]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_User] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_User;
insert into STG_SIS.SIS_User
select 
		id,
		case when trim(open_id) in ('','null') then null else trim(open_id) end as open_id,
		case when trim(card_no) in ('','null') then null else trim(card_no) end as card_no,
		case when trim(card_level) in ('','null') then null else trim(card_level) end as card_level,
		case when trim(del_flag) in ('','null') then null else trim(del_flag) end as del_flag,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_User
) t
where rownum = 1
END
GO
