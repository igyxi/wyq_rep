/****** Object:  StoredProcedure [TEMP].[TRANS_User_Third_Party_Store_bak_20230524]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_User_Third_Party_Store_bak_20230524] AS
BEGIN
truncate table STG_User.User_Third_Party_Store;
insert into STG_User.User_Third_Party_Store
select 
    id,
    user_id,
    case when trim(lower(type)) in ('null','') then null else trim(type) end as type,
    case when trim(lower(union_id)) in ('null','') then null else trim(union_id) end as union_id,
    case when trim(lower(channel)) in ('null','') then null else trim(channel) end as channel,
    case when trim(lower(nick_name)) in ('null','') then null else trim(nick_name) end as nick_name,
    case when trim(lower(photo)) in ('null','') then null else trim(photo) end as photo,
    null as mobile,
    null as email,
    age,
    last_login_time,
    bind_time,
    update_time,
    status,
    create_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over (partition by union_id,type order by dt desc ) as rownum from ODS_User.User_Third_Party_Store 
) t
where rownum = 1
END


GO
