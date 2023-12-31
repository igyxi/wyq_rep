/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_In_Sales_Activity_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_In_Sales_Activity_Detail] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_In_Sales_Activity_Detail;
insert into STG_IMS.STK_In_Sales_Activity_Detail
select 
		id,
		in_sales_activity_id,
		case when trim(activity_code) in ('','null','None') then null else trim(activity_code) end as activity_code,
		sku_id,
		warehouse_id,
		wharetype_id,
		qty_lock_start,
		qty_lock,
		qty_activity_start,
		qty_activity,
		create_time,
		modify_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_In_Sales_Activity_Detail
where dt = @dt
END
GO
