/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Channel_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Channel_Info] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-03      wangzhichun        Initial Version
-- ========================================================================================
truncate table STG_OMS.OMS_Channel_Info;
insert into STG_OMS.OMS_Channel_Info
select 
	oms_channel_info_sys_id,
	case when trim(channel_name) in ('null','') then null else trim(channel_name) end as channel_name, 
	case when trim(channel_id) in ('null','') then null else trim(channel_id) end as channel_id,
	inv_sync_flag,
	show_flag,
	create_time,
	update_time,
	case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
	case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
	is_delete,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.OMS_Channel_Info
where 
    dt = @dt

END


GO
