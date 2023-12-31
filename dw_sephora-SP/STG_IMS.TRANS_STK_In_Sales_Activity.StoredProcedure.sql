/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_In_Sales_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_In_Sales_Activity] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_In_Sales_Activity;
insert into STG_IMS.STK_In_Sales_Activity
select 
		id,
		case when trim(platform_code) in ('','null','None') then null else trim(platform_code) end as platform_code,
		case when trim(activity_code) in ('','null','None') then null else trim(activity_code) end as activity_code,
		case when trim(activity_name) in ('','null','None') then null else trim(activity_name) end as activity_name,
		case when trim(activity_type) in ('','null','None') then null else trim(activity_type) end as activity_type,
		activity_status,
		is_share_activity,
		case when trim(share_activity_no) in ('','null','None') then null else trim(share_activity_no) end as share_activity_no,
		is_lock,
		activity_is_lock,
		stock_version,
		activity_start_time,
		activity_end_time,
		create_time,
		modify_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_In_Sales_Activity
where dt = @dt
END
GO
