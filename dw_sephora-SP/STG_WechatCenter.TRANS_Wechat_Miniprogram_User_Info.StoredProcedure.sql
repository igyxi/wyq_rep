/****** Object:  StoredProcedure [STG_WechatCenter].[TRANS_Wechat_Miniprogram_User_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_WechatCenter].[TRANS_Wechat_Miniprogram_User_Info] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_WechatCenter.Wechat_Miniprogram_User_Info;
insert into STG_WechatCenter.Wechat_Miniprogram_User_Info
select 
		id,
		case when trim(unionid) in ('','null') then null else trim(unionid) end as unionid,
		case when trim(openid) in ('','null') then null else trim(openid) end as openid,
		case when trim(nickname) in ('','null') then null else trim(nickname) end as nickname,
		gender,
		case when trim(language) in ('','null') then null else trim(language) end as language,
		case when trim(city) in ('','null') then null else trim(city) end as city,
		case when trim(province) in ('','null') then null else trim(province) end as province,
		case when trim(country) in ('','null') then null else trim(country) end as country,
		case when trim(avatarurl) in ('','null') then null else trim(avatarurl) end as avatarurl,
		case when trim(watermark) in ('','null') then null else trim(watermark) end as watermark,
		authorizetime,
		updatetime,
		create_time,
		case when trim(create_user) in ('','null') then null else trim(create_user) end as create_user,
		case when trim(update_user) in ('','null') then null else trim(update_user) end as update_user,
		is_delete,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_WechatCenter.Wechat_Miniprogram_User_Info
) t
where rownum = 1
END
GO
