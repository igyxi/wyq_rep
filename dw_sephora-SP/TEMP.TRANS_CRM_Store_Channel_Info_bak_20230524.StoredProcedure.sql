/****** Object:  StoredProcedure [TEMP].[TRANS_CRM_Store_Channel_Info_bak_20230524]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_CRM_Store_Channel_Info_bak_20230524] AS
BEGIN
truncate table STG_User.CRM_Store_Channel_Info;
insert into STG_User.CRM_Store_Channel_Info
select 
    id,
    case when trim(lower(union_id)) in ('null','') then null else trim(union_id) end as union_id,
    case when trim(lower(store_name)) in ('null','') then null else trim(store_name) end as store_name,
    case when trim(lower(channel)) in ('null','') then null else trim(channel) end as channel,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_deleted,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over (partition by id order by dt desc ) as rownum from ODS_User.CRM_Store_Channel_Info 
) t
where rownum = 1;
END
GO
