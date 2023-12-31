/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Time_Lock_Library]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Time_Lock_Library] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Time_Lock_Library;
insert into STG_IMS.STK_Time_Lock_Library
select 
		id,
		platform_id,
		sku_id,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		case when trim(sku_name) in ('','null','None') then null else trim(sku_name) end as sku_name,
		shop_id,
		case when trim(shop_code) in ('','null','None') then null else trim(shop_code) end as shop_code,
		brand_id,
		pre_qty_lock,
		qty_lock,
		qty,
		qty_num,
		warehouse_id,
		case when trim(warehouse_code) in ('','null','None') then null else trim(warehouse_code) end as warehouse_code,
		wharetype_id,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		case when trim(business_type) in ('','null','None') then null else trim(business_type) end as business_type,
		effective_time,
		expiry_time,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Time_Lock_Library
where dt = @dt
END
GO
