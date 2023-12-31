/****** Object:  StoredProcedure [STG_Marketing].[TRANS_Activity_Store_Book_User]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Marketing].[TRANS_Activity_Store_Book_User] AS
BEGIN
truncate table STG_Marketing.Activity_Store_Book_User;
insert into STG_Marketing.Activity_Store_Book_User
select 
    id,
    user_id,
    case when trim(open_id) in ('null','') then null else trim(open_id) end as open_id,
    case when trim(channel) in ('null','') then null else trim(channel) end as channel,
    case when trim(store_code) in ('null','') then null else trim(store_code) end as store_code,
    activity_id,
    start_time,
    end_time,
    case when trim(user_name) in ('null','') then null else trim(user_name) end as user_name,
    case when trim(mobile_number) in ('null','') then null else trim(mobile_number) end as mobile_number,
    case when trim(sign_code) in ('null','') then null else trim(sign_code) end as sign_code,
    case when trim(remark) in ('null','') then null else trim(remark) end as remark,
    is_send_mail,
    is_canceled,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_deleted,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Marketing.Activity_Store_Book_User
) t
where rownum = 1
END
GO
