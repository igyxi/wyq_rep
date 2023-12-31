/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Stocksynchroplatformgoods]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Stocksynchroplatformgoods] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Stocksynchroplatformgoods;
insert into STG_IMS.STK_Stocksynchroplatformgoods
select 
		id,
		shop_id,
		virtual_warehouse_id,
		case when trim(virtual_warehouse_code) in ('','null','None') then null else trim(virtual_warehouse_code) end as virtual_warehouse_code,
		case when trim(virtual_warehouse_name) in ('','null','None') then null else trim(virtual_warehouse_name) end as virtual_warehouse_name,
		case when trim(platformgoods_skuid) in ('','null','None') then null else trim(platformgoods_skuid) end as platformgoods_skuid,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_date,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_date,
		warn_qty,
		retain_qty,
		case when trim([percent]) in ('','null','None') then null else trim([percent]) end as [percent],
		last_change,
		brand_id,
		case when trim(single_product_code) in ('','null','None') then null else trim(single_product_code) end as single_product_code,
		single_product_id,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Stocksynchroplatformgoods
where dt = @dt
END
GO
