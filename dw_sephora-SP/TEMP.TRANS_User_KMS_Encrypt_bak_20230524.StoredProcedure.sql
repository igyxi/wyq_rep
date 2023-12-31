/****** Object:  StoredProcedure [TEMP].[TRANS_User_KMS_Encrypt_bak_20230524]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_User_KMS_Encrypt_bak_20230524] AS
BEGIN
truncate table STG_User.User_KMS_Encrypt ;
insert into STG_User.User_KMS_Encrypt
select 
	id,
	case when trim(encrypt) in ('null','') then null else trim(encrypt) end as encrypt,
	case when trim(data_key_iv) in ('null','') then null else trim(data_key_iv) end as data_key_iv,
	case when trim(encrypted_data_key) in ('null','') then null else trim(encrypted_data_key) end as encrypted_data_key,
	user_id,
	case when trim([type]) in ('null','') then null else trim([type]) end as [type],
	create_time,
	update_time,	
	case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_del,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_User.User_KMS_Encrypt
) t
where rownum = 1
END


GO
