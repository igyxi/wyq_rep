/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Brand_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Brand_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.BAS_Brand_STG;
insert into STG_IMS.BAS_Brand_STG
select 
		id,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		case when trim(isdefault) in ('','null','None') then null else trim(isdefault) end as isdefault,
		case when trim(controller) in ('','null','None') then null else trim(controller) end as controller,
		case when trim(checkstatus) in ('','null','None') then null else trim(checkstatus) end as checkstatus,
		case when trim(createby) in ('','null','None') then null else trim(createby) end as createby,
		createtime,
		case when trim(disableby) in ('','null','None') then null else trim(disableby) end as disableby,
		disabledate,
		case when trim(modifyby) in ('','null','None') then null else trim(modifyby) end as modifyby,
		modifytime,
		createchannelid,
		case when trim(enableby) in ('','null','None') then null else trim(enableby) end as enableby,
		enabledate,
		parent_id,
		case when trim(is_dedicated_online) in ('','null','None') then null else trim(is_dedicated_online) end as is_dedicated_online,
		case when trim(logo_img) in ('','null','None') then null else trim(logo_img) end as logo_img,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(background_img) in ('','null','None') then null else trim(background_img) end as background_img,
		case when trim(picture_img) in ('','null','None') then null else trim(picture_img) end as picture_img,
		case when trim(video) in ('','null','None') then null else trim(video) end as video,
		case when trim(video_name) in ('','null','None') then null else trim(video_name) end as video_name,
		case when trim(is_interests) in ('','null','None') then null else trim(is_interests) end as is_interests,
		data_create_time,
		data_update_time,
		case when trim(name_en) in ('','null','None') then null else trim(name_en) end as name_en,
		current_timestamp as insert_timestamp
from  ODS_IMS.BAS_Brand_STG
where dt = @dt
END

GO
