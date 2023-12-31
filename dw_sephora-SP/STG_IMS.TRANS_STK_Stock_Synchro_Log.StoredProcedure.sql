/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Stock_Synchro_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Stock_Synchro_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Stock_Synchro_Log;
insert into STG_IMS.STK_Stock_Synchro_Log
select 
		id,
		shop_id,
		case when trim(platform_goods_id) in ('','null','None') then null else trim(platform_goods_id) end as platform_goods_id,
		case when trim(platform_goods_sku_id) in ('','null','None') then null else trim(platform_goods_sku_id) end as platform_goods_sku_id,
		case when trim(adaptor_status) in ('','null','None') then null else trim(adaptor_status) end as adaptor_status,
		case when trim(platform_status) in ('','null','None') then null else trim(platform_status) end as platform_status,
		qty,
		case when trim(message) in ('','null','None') then null else trim(message) end as message,
		case when trim(operator) in ('','null','None') then null else trim(operator) end as operator,
		operate_time,
		case when trim(shop_name) in ('','null','None') then null else trim(shop_name) end as shop_name,
		case when trim(goods_code) in ('','null','None') then null else trim(goods_code) end as goods_code,
		case when trim(platform_goods_code) in ('','null','None') then null else trim(platform_goods_code) end as platform_goods_code,
		case when trim(sku) in ('','null','None') then null else trim(sku) end as sku,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Stock_Synchro_Log
where dt = @dt
END
GO
