/****** Object:  StoredProcedure [TEMP].[TRANS_User_bak_20230524]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_User_bak_20230524] AS
BEGIN
truncate table STG_User.[User] ;
insert into STG_User.[User]
select 
    id,
    case when trim(lower(type)) in ('null','') then null else trim(type) end as type,
    status,
    registration,
    last_login_time,
    registration_update,
    case when trim(lower(challenge_question)) in ('null','') then null else trim(challenge_question) end as challenge_question,
    case when trim(lower(challenge_answer)) in ('null','') then null else trim(challenge_answer) end as challenge_answer,
    password_retries,
    case when trim(lower(login_id)) in ('null','') then null else trim(login_id) end as login_id,
    case when trim(lower(password)) in ('null','') then null else  trim(password) end as password,
    password_expired,
    password_creation,
    password_invalid,
    case when trim(lower(salt)) in ('null','') then null else  trim(salt) end as salt,
    last_order,
    is_soa,
    null as email,
    null as mobile,
    case when trim(lower(cardno)) in ('null','') then null else trim(cardno) end as cardno,
    case when trim(lower(wcs)) in ('null','') then null else trim(wcs) end as wcs,
    disable_time,
    is_loginout,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_User.[User]
) t
where rownum = 1
END

GO
