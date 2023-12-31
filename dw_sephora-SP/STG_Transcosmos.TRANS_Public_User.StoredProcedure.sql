/****** Object:  StoredProcedure [STG_Transcosmos].[TRANS_Public_User]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Transcosmos].[TRANS_Public_User] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-07       wangzhichun        Initial Version
-- ========================================================================================
truncate table [STG_TRANSCOSMOS].[Public_User];
insert into [STG_TRANSCOSMOS].[Public_User]
select 
	id,
	case when trim(lower(name)) in ('','null') then null else trim(name) end as name,
	case when trim(lower(password)) in ('','null') then null else trim(password) end as password,
	case when trim(lower(mobile_phone)) in ('','null') then null else trim(mobile_phone) end as mobile_phone,
	case when trim(lower(email)) in ('','null') then null else trim(email) end as email,
	case when trim(lower(nickname)) in ('','null') then null else trim(nickname) end as nickname,
	case when trim(lower(qq)) in ('','null') then null else trim(qq) end as qq,
	enabled,
	case when trim(lower(avatar)) in ('','null') then null else trim(avatar) end as avatar,
	affiliation,
	type,
	remind,
	create_time,
	update_time,
	web_id,
	del,
	create_user_id,
	readonly,
	pwd_update_time,
	case when trim(lower(ip)) in ('','null') then null else trim(ip) end as ip,
    current_timestamp as insert_timestamp
from 
    ODS_Transcosmos.Public_User
where 
    dt = @dt;
END
GO
