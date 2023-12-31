/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Account_Virtual_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Account_Virtual_Activity] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Account_Virtual_Activity;
insert into STG_IMS.STK_Account_Virtual_Activity
select 
		case when trim(id) in ('','null','None') then null else trim(id) end as id,
		case when trim(activity_type) in ('','null','None') then null else trim(activity_type) end as activity_type,
		case when trim(activity_code) in ('','null','None') then null else trim(activity_code) end as activity_code,
		case when trim(activity_name) in ('','null','None') then null else trim(activity_name) end as activity_name,
		platform_id,
		case when trim(platform) in ('','null','None') then null else trim(platform) end as platform,
		shop_id,
		goods_id,
		single_product_id,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		qty,
		qty_used,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		cancel_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Account_Virtual_Activity
where dt = @dt
END
GO
