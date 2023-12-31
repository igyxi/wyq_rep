/****** Object:  StoredProcedure [ODS_User].[IMP_User]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_User].[IMP_User] @dt [varchar](10) AS
BEGIN
delete from ODS_User.[User] where dt = @dt;
insert into ODS_User.[User]
select 
    id,
    type,
    status,
    registration,
    last_login_time,
    registration_update,
    challenge_question,
    challenge_answer,
    password_retries,
    login_id,
    password,
    password_expired,
    password_creation,
    password_invalid,
    salt,
    last_order,
    is_soa, 
    convert(varchar(max),HASHBYTES('SHA2_256', email),2) as email,
    convert(varchar(max),HASHBYTES('MD5', mobile),2) as mobile,
    cardNo,
    wcs,
    disable_time,
    is_loginout,
    create_time,
    update_time,
    create_user,
    update_user,
    is_delete,
    @dt as dt 
from 
    ODS_User.WRK_User;
TRUNCATE table ODS_User.WRK_User;
END


GO
