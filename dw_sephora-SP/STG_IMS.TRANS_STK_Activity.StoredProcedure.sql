/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Activity] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Activity;
insert into STG_IMS.STK_Activity
select 
		id,
		case when trim(platform) in ('','null','None') then null else trim(platform) end as platform,
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		case when trim(activity_type) in ('','null','None') then null else trim(activity_type) end as activity_type,
		case when trim(activity_code) in ('','null','None') then null else trim(activity_code) end as activity_code,
		case when trim(activity_name) in ('','null','None') then null else trim(activity_name) end as activity_name,
		shop_id,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		activity_start,
		activity_end,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		pretest_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Activity
where dt = @dt
END
GO
