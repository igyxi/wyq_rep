/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Account_Seckill_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Account_Seckill_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Account_Seckill_Log;
insert into STG_IMS.STK_Account_Seckill_Log
select 
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		activity_id,
		case when trim(activity_code) in ('','null','None') then null else trim(activity_code) end as activity_code,
		case when trim(activity_name) in ('','null','None') then null else trim(activity_name) end as activity_name,
		warehouse_id,
		wharetype_id,
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
		id,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Account_Seckill_Log
where dt = @dt
END
GO
