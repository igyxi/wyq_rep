/****** Object:  StoredProcedure [ODS_User].[IMP_User_Profile]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_User].[IMP_User_Profile] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_User.User_Profile where dt = @dt;
insert into ODS_User.User_Profile
select 
    id,
	user_id,
	card_no,
	nick_name,
	photo,
	gender,
	age,
	income,
	maritalstatus,
	children,
	household,
	companyname,
	hobbies,
	dateofbirth,
	birthday_vaild,
	description,
	name,
    convert(varchar(max),HASHBYTES('MD5', mobile),2) as mobile,
	mobile_valid,
	tmall_encrypted_mobile,
    convert(varchar(max),HASHBYTES('SHA2_256', email),2) as email, 
	email_valid,
	qq,
	province,
	city,
	area,
    convert(varchar(max),HASHBYTES('SHA2_256', address),2) as address,
	address_valid,
	zipcode,
	inviter_user_id,
	last_update,
	mobile_valid_times,
	last_shopping_time,
	secret_photo,
	secret_nickname,
	create_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt 
from 
    ODS_User.WRK_User_Profile;
truncate table ODS_User.WRK_User_Profile;
END



GO
