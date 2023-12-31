/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Stocksynchrosgpd]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Stocksynchrosgpd] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Stocksynchrosgpd;
insert into STG_IMS.STK_Stocksynchrosgpd
select 
		id,
		shop_id,
		virtual_warehouse_id,
		case when trim(virtual_warehouse_code) in ('','null','None') then null else trim(virtual_warehouse_code) end as virtual_warehouse_code,
		case when trim(virtual_warehouse_name) in ('','null','None') then null else trim(virtual_warehouse_name) end as virtual_warehouse_name,
		single_product_id,
		case when trim([percent]) in ('','null','None') then null else trim([percent]) end as [percent],
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_date,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_date,
		warn_qty,
		retain_qty,
		last_change,
		brand_id,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Stocksynchrosgpd
where dt = @dt
END
GO
