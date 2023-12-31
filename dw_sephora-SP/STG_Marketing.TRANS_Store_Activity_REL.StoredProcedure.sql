/****** Object:  StoredProcedure [STG_Marketing].[TRANS_Store_Activity_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Marketing].[TRANS_Store_Activity_REL] AS
BEGIN
truncate table STG_Marketing.Store_Activity_REL;
insert into STG_Marketing.Store_Activity_REL
select 
    case when trim(store_code) in ('null','') then null else trim(store_code) end as store_code,
    activity_id,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    case when trim(is_delete) in ('null','') then null else trim(is_delete) end as is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by store_code,activity_id order by dt desc) rownum from ODS_Marketing.Store_Activity_REL
) t
where rownum = 1;
END
GO
