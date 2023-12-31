/****** Object:  StoredProcedure [ODS_User].[IMP_User_Third_Party_Store]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_User].[IMP_User_Third_Party_Store] @dt [varchar](10) AS
BEGIN
delete from ODS_User.[User_Third_Party_Store] where dt = @dt;
insert into ODS_User.[User_Third_Party_Store]
select 
    id,
    user_id,
    type,
    union_id,
    channel,
    nick_name,
    photo,
    mobile,
    convert(varchar(max),HASHBYTES('SHA2_256', trim(email)),2) as email,
    age,
    last_login_time,
    bind_time,
    update_time,
    status,
    create_time,
    create_user,
    update_user,
    @dt as dt 
from 
    ODS_User.WRK_User_Third_Party_Store;
TRUNCATE table ODS_User.WRK_User_Third_Party_Store;
END


GO
