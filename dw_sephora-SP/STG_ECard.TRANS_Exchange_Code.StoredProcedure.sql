/****** Object:  StoredProcedure [STG_ECard].[TRANS_Exchange_Code]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_Exchange_Code] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_Ecard.Exchange_Code;
insert into STG_Ecard.Exchange_Code
select 
		id,
		case when trim(code) in ('', 'null', 'None') then null else trim(code) end as code,
        code_type,
		balance,
		case when trim(code_no) in ('', 'null', 'None') then null else trim(code_no) end as code_no,
		case when trim(code_no_password) in ('', 'null', 'None') then null else trim(code_no_password) end as code_no_password,
		case when trim(name) in ('', 'null', 'None') then null else trim(name) end as name,
        gender,
		case when trim(mobile) in ('', 'null', 'None') then null else trim(mobile) end as mobile,
		case when trim(ba_id) in ('', 'null', 'None') then null else trim(ba_id) end as ba_id,
		case when trim(ba_name) in ('', 'null', 'None') then null else trim(ba_name) end as ba_name,
		ba_department_id,
		case when trim(ba_department_name) in ('', 'null', 'None') then null else trim(ba_department_name) end as ba_department_name,
        status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.Exchange_Code
) t
where rownum = 1
END
GO
