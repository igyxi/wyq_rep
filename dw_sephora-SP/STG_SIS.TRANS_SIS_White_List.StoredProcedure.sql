/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_White_List]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_White_List] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_White_List;
insert into STG_SIS.SIS_White_List
select 
		id,
		case when trim(account) in ('','null') then null else trim(account) end as account,
		case when trim(password) in ('','null') then null else trim(password) end as password,
		company_id,
		case when trim(del_flag) in ('','null') then null else trim(del_flag) end as del_flag,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_White_List
) t
where rownum = 1
END
GO
