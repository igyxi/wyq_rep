/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Account_Channel_Lock_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Account_Channel_Lock_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Account_Channel_Lock_Log;
insert into STG_IMS.STK_Account_Channel_Lock_Log
select 
		id,
		case when trim(bill_type) in ('','null','None') then null else trim(bill_type) end as bill_type,
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		case when trim(platform) in ('','null','None') then null else trim(platform) end as platform,
		goods_id,
		sku_id,
		qty_before,
		qty,
		qty_after,
		operate_time,
		case when trim(operate_by) in ('','null','None') then null else trim(operate_by) end as operate_by,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		shop_id,
		case when trim(workflow_no) in ('','null','None') then null else trim(workflow_no) end as workflow_no,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Account_Channel_Lock_Log
where dt = @dt
END
GO
