/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Company]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Company] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-26       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Company;
insert into STG_SIS.SIS_Company
select 
		id,
		case when trim(company_name) in ('','null') then null else trim(company_name) end as company_name,
		activity_id,
		case when trim(white_flag) in ('','null') then null else trim(white_flag) end as white_flag,
		case when trim(del_flag) in ('','null') then null else trim(del_flag) end as del_flag,
		secret_flag,
		case when trim(secret_key) in ('','null') then null else trim(secret_key) end as secret_key,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from
(
    select *,row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Company
) t
where rownum = 1
END
GO
