/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Stock_Manage]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Stock_Manage] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Stock_Manage;
insert into STG_IMS.STK_Stock_Manage
select 
		id,
		platform_id,
		shop_id,
		sku_id,
		warehouse_id,
		wharetype_id,
		case when trim(shop_code) in ('','null','None') then null else trim(shop_code) end as shop_code,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		case when trim(warehouse_code) in ('','null','None') then null else trim(warehouse_code) end as warehouse_code,
		qty,
		qty_lock,
		qty_num,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Stock_Manage
where dt = @dt
END
GO
