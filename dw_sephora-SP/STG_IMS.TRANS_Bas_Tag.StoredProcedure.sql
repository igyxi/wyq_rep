/****** Object:  StoredProcedure [STG_IMS].[TRANS_Bas_Tag]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_Bas_Tag] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- --------------------------------IMS--------------------------------------------------------
-- 2022-09-16       wubin          Initial Version
-- 2022-09-28       wubin          update data_create_time/data_update_time
-- 2022-12-15       wangzhichun    change schema
-- ========================================================================================
truncate table STG_IMS.Bas_Tag;
insert into STG_IMS.Bas_Tag
select 
		id,
		case when trim(code) in ('','null') then null else trim(code) end as code,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(app_name) in ('','null') then null else trim(app_name) end as app_name,
		case when trim(message_id) in ('','null') then null else trim(message_id) end as message_id,
		case when trim(tag_type) in ('','null') then null else trim(tag_type) end as tag_type,
		case when trim(operat_type) in ('','null') then null else trim(operat_type) end as operat_type,
		count,
		proportion,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		case when trim(create_by) in ('','null') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null') then null else trim(modify_by) end as modify_by,
		modify_time,
		case when trim(status) in ('','null') then null else trim(status) end as status,
		case when trim(is_internally) in ('','null') then null else trim(is_internally) end as is_internally,
		case when trim(text_color) in ('','null') then null else trim(text_color) end as text_color,
		case when trim(background_color) in ('','null') then null else trim(background_color) end as background_color,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from    ODS_IMS.Bas_Tag
where dt = @dt
END
GO
