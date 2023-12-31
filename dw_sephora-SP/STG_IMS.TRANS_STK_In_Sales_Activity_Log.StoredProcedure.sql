/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_In_Sales_Activity_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_In_Sales_Activity_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_In_Sales_Activity_Log;
insert into STG_IMS.STK_In_Sales_Activity_Log
select 
		id,
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		case when trim(activity_code) in ('','null','None') then null else trim(activity_code) end as activity_code,
		activity_id,
		is_share_activity,
		case when trim(share_activity_no) in ('','null','None') then null else trim(share_activity_no) end as share_activity_no,
		sku_id,
		warehouse_id,
		wharetype_id,
		qty,
		case when trim(change_type) in ('','null','None') then null else trim(change_type) end as change_type,
		create_time,
		modify_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_In_Sales_Activity_Log
where dt = @dt
END
GO
