/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Synchro_Salesroom_Goods_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Synchro_Salesroom_Goods_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-01       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Synchro_Salesroom_Goods_STG;
insert into STG_IMS.STK_Synchro_Salesroom_Goods_STG
select 
		id,
		shop_id,
		case when trim(shop_code) in ('','null','None') then null else trim(shop_code) end as shop_code,
		case when trim(salesroom_code) in ('','null','None') then null else trim(salesroom_code) end as salesroom_code,
		case when trim(salesroom_name) in ('','null','None') then null else trim(salesroom_name) end as salesroom_name,
		goods_id,
		sku_id,
		salesroom_warehouse_id,
		stock_warehouse_id,
		stock_warehouse_type,
		synchro_scale,
		warn_num,
		retain_num,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		goods_type,
		is_head_store,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		case when trim(platform_code) in ('','null','None') then null else trim(platform_code) end as platform_code,
		case when trim(sync_sign_weimeng) in ('','null','None') then null else trim(sync_sign_weimeng) end as sync_sign_weimeng,
		case when trim(upc) in ('','null','None') then null else trim(upc) end as upc,
		store_stock,
		is_online,
		case when trim(platformgoodsskuid) in ('','null','None') then null else trim(platformgoodsskuid) end as platformgoodsskuid,
		case when trim(platformgoodsid) in ('','null','None') then null else trim(platformgoodsid) end as platformgoodsid,
		data_create_time,
		data_update_time,
		wharetype_id,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Synchro_Salesroom_Goods_STG
where dt = @dt
END
GO
