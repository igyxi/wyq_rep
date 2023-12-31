/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_GWP_Stock]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_GWP_Stock] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_GWP_Stock;
insert into STG_IMS.STK_GWP_Stock
select 
		id,
		case when trim(shop_code) in ('','null','None') then null else trim(shop_code) end as shop_code,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		case when trim(gwp_type) in ('','null','None') then null else trim(gwp_type) end as gwp_type,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		qty,
		operate_time,
		case when trim(operate_by) in ('','null','None') then null else trim(operate_by) end as operate_by,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_GWP_Stock
where dt = @dt
END
GO
