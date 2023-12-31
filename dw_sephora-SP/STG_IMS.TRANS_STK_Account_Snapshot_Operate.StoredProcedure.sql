/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Account_Snapshot_Operate]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Account_Snapshot_Operate] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Account_Snapshot_Operate;
insert into STG_IMS.STK_Account_Snapshot_Operate
select 
		id,
		snapshot_id,
		case when trim(operate_type) in ('','null','None') then null else trim(operate_type) end as operate_type,
		case when trim(operate_log) in ('','null','None') then null else trim(operate_log) end as operate_log,
		operate_time,
		case when trim(operate_by) in ('','null','None') then null else trim(operate_by) end as operate_by,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Account_Snapshot_Operate
where dt = @dt
END
GO
