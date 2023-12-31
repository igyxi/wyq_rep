/****** Object:  StoredProcedure [TEMP].[TRANS_User_Profile_bak_20230524]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_User_Profile_bak_20230524] AS
BEGIN
truncate table STG_User.User_Profile ;
insert into STG_User.User_Profile
select 
    id,
    user_id,
    case when trim(lower(card_no)) in ('null','') then null else  trim(card_no) end as card_no,
    case when trim(lower(nick_name)) in ('null','') then null else  trim(nick_name) end as nick_name,
    case when trim(lower(photo)) in ('null','') then null else  trim(photo) end as photo,
    case 
        when gender is null then 'N'
        when trim(lower(gender)) in ('null','') then 'N' 
        else upper(gender) 
    end as gender,
    age,
    income,
    case when trim(lower(maritalstatus)) in ('null','') then null else  trim(maritalstatus) end as maritalstatus,
    children,
    household,
    case when trim(lower(companyname)) in ('null','') then null else  trim(companyname) end as companyname,
    case when trim(lower(hobbies)) in ('null','') then null else  trim(hobbies) end as hobbies,
    dateofbirth,
    birthday_vaild,
    case when trim(lower(description)) in ('null','') then null else  trim(description) end as description,
    case when trim(lower(name)) in ('null','') then null else  trim(name) end as name,
    null as mobile,
    mobile_valid,
    null as tmall_encrypted_mobile,
    null as email,
    email_valid,
    case when trim(lower(qq)) in ('null','') then null else  trim(qq) end as qq,
    case when trim(lower(province)) in ('null','') then null else  trim(province) end as province,
    case when trim(lower(city)) in ('null','') then null else  trim(city) end as city,
    case when trim(lower(area)) in ('null','') then null else  trim(area) end as area,
    null as address,
    address_valid,
    case when trim(lower(zipcode)) in ('null','') then null else  trim(zipcode) end as zipcode,
    inviter_user_id,
    last_update,
    mobile_valid_times,
    last_shopping_time,
    case when trim(lower(secret_photo)) in ('null','') then null else  trim(secret_photo) end as secret_photo,
    case when trim(lower(secret_nickname)) in ('null','') then null else  trim(secret_nickname) end as secret_nickname,
    create_time,
    case when trim(lower(create_user)) in ('null','') then null else  trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else  trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over (partition by id order by dt desc ) as rownum from ODS_User.User_Profile 
) t
where rownum = 1;
update statistics STG_User.User_Profile;
END


GO
