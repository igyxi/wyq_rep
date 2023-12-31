/****** Object:  StoredProcedure [STG_Marketing].[TRANS_Store_Service]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Marketing].[TRANS_Store_Service] AS
BEGIN
truncate table STG_Marketing.Store_Service;
insert into STG_Marketing.Store_Service
select 
    id,
    case when trim(name) in ('null','') then null else trim(name) end as name,
    case when trim(image) in ('null','') then null else trim(image) end as image,
    case when trim(content) in ('null','') then null else trim(content) end as content,
    start_time,
    end_time,
    status,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    case when trim(is_delete) in ('null','') then null else trim(is_delete) end as is_delete,
    last_update_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Marketing.Store_Service
) t
where rownum = 1
END
GO
