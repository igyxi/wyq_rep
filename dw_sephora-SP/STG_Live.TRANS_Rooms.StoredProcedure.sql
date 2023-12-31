/****** Object:  StoredProcedure [STG_Live].[TRANS_Rooms]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Live].[TRANS_Rooms] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Live.Rooms;
insert into STG_Live.Rooms
select 
		il_id,
		case when trim(room_id) in ('','null') then null else trim(room_id) end as room_id,
		case when trim(subject) in ('','null') then null else trim(subject) end as subject,
		case when trim(welcome) in ('','null') then null else trim(welcome) end as welcome,
		account_id,
		case when trim(inav_id) in ('','null') then null else trim(inav_id) end as inav_id,
		case when trim(channel_id) in ('','null') then null else trim(channel_id) end as channel_id,
		case when trim(nify_channel) in ('','null') then null else trim(nify_channel) end as nify_channel,
		case when trim(record_id) in ('','null') then null else trim(record_id) end as record_id,
		start_time,
		begin_time_stamp,
		case when trim(introduction) in ('','null') then null else trim(introduction) end as introduction,
		category,
		case when trim(cover_image) in ('','null') then null else trim(cover_image) end as cover_image,
		case when trim(share_img) in ('','null') then null else trim(share_img) end as share_img,
		case when trim(topics) in ('','null') then null else trim(topics) end as topics,
		layout,
		status,
		is_delete,
		message_approval,
		created_at,
		updated_at,
		case when trim(app_id) in ('','null') then null else trim(app_id) end as app_id,
		[like],
		deleted_at,
		live_type,
		warm_type,
		case when trim(warm_vod_id) in ('','null') then null else trim(warm_vod_id) end as warm_vod_id,
		case when trim(teacher_name) in ('','null') then null else trim(teacher_name) end as teacher_name,
		begin_live_time,
		end_live_time,
		is_open_document,
		live_mode,
		message_total,
		pv,
		mode,
		limit_type,
		case when trim(extend) in ('','null') then null else trim(extend) end as extend,
		current_timestamp as insert_timestamp
from    
    ODS_Live.Rooms
where 
    dt = @dt
END
GO
