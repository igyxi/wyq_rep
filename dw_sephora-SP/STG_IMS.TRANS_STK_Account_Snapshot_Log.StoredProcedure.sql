/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Account_Snapshot_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Account_Snapshot_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Account_Snapshot_Log;
insert into STG_IMS.STK_Account_Snapshot_Log
select 
		case when trim(source_bill_no) in ('','null','None') then null else trim(source_bill_no) end as source_bill_no,
		warehouse_id,
		wharetype_id,
		goods_id,
		sku_id,
		qty_before,
		qty,
		qty_after,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		operate_time,
		case when trim(operate_by) in ('','null','None') then null else trim(operate_by) end as operate_by,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		cancel_time,
		id,
		case when trim(source_bill_type) in ('','null','None') then null else trim(source_bill_type) end as source_bill_type,
		platform_id,
		case when trim(change_type) in ('','null','None') then null else trim(change_type) end as change_type,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Account_Snapshot_Log
where dt = @dt
END
GO
