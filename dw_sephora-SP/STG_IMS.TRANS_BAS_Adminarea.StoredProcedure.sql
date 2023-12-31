/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Adminarea]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Adminarea] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By            Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-15       wangzhichun           Initial Version
-- 2022-09-28       wubin                 update data_create_time/data_update_time
-- 2022-11-25       wangzhichun           update increment
-- 2022-12-15       wangzhichun           change schema
-- ========================================================================================
truncate table STG_IMS.BAS_Adminarea;
insert into STG_IMS.BAS_Adminarea
select 
		id,
		case when trim(code) in ('','null') then null else trim(code) end as code,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(status) in ('','null') then null else trim(status) end as status,
		case when trim(type) in ('','null') then null else trim(type) end as type,
		parent_id,
		create_channel_id,
		case when trim(built_default) in ('','null') then null else trim(built_default) end as built_default,
		case when trim(built_in) in ('','null') then null else trim(built_in) end as built_in,
		latitude,
		longitude,
		case when trim(create_by) in ('','null') then null else trim(create_by) end as create_by,
		case when trim(enable_by) in ('','null') then null else trim(enable_by) end as enable_by,
		case when trim(disable_by) in ('','null') then null else trim(disable_by) end as disable_by,
		case when trim(modify_by) in ('','null') then null else trim(modify_by) end as modify_by,
		enable_date,
		disable_date,
		create_time,
		modify_time,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_IMS.BAS_Adminarea
) t
where rownum = 1
END
GO
