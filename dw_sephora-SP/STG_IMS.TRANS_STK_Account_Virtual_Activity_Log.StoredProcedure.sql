/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Account_Virtual_Activity_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Account_Virtual_Activity_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-03       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Account_Virtual_Activity_Log;
insert into STG_IMS.STK_Account_Virtual_Activity_Log
select 
		case when trim(id) in ('','null','None') then null else trim(id) end as id,
		shop_id,
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		case when trim(activity_type) in ('','null','None') then null else trim(activity_type) end as activity_type,
		case when trim(activity_code) in ('','null','None') then null else trim(activity_code) end as activity_code,
		case when trim(activity_name) in ('','null','None') then null else trim(activity_name) end as activity_name,
		case when trim(platform) in ('','null','None') then null else trim(platform) end as platform,
		goods_id,
		single_product_id,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		case when trim(qty_type) in ('','null','None') then null else trim(qty_type) end as qty_type,
		qty_before,
		qty,
		qty_after,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		operate_time,
		case when trim(operate_by) in ('','null','None') then null else trim(operate_by) end as operate_by,
		case when trim(operate_type) in ('','null','None') then null else trim(operate_type) end as operate_type,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Account_Virtual_Activity_Log
where dt = @dt
END
GO
