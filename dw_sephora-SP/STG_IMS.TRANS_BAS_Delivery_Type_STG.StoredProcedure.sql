/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Delivery_Type_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Delivery_Type_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.BAS_Delivery_Type_STG;
insert into STG_IMS.BAS_Delivery_Type_STG
select 
		case when trim(price_id) in ('','null','None') then null else trim(price_id) end as price_id,
		case when trim(disable_by) in ('','null','None') then null else trim(disable_by) end as disable_by,
		create_date,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		price_dimension_id,
		modify_time,
		modify_date,
		case when trim(use_insure) in ('','null','None') then null else trim(use_insure) end as use_insure,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		disable_date,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		create_channel_id,
		case when trim(pay_after) in ('','null','None') then null else trim(pay_after) end as pay_after,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		enable_date,
		case when trim([rule]) in ('','null','None') then null else trim([rule]) end as [rule],
		id,
		create_time,
		case when trim(enable_by) in ('','null','None') then null else trim(enable_by) end as enable_by,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(type) in ('','null','None') then null else trim(type) end as type,
		logroid,
		case when trim(non_jdorder_warehouse) in ('','null','None') then null else trim(non_jdorder_warehouse) end as non_jdorder_warehouse,
		non_jdorder_warehousepri,
		case when trim(is_jdorder_warehouse) in ('','null','None') then null else trim(is_jdorder_warehouse) end as is_jdorder_warehouse,
		is_jdorder_warehousepri,
		case when trim(precon_signment_express) in ('','null','None') then null else trim(precon_signment_express) end as precon_signment_express,
		precon_signment_expresspri,
		case when trim(app_scene) in ('','null','None') then null else trim(app_scene) end as app_scene,
		priority,
		case when trim(scope) in ('','null','None') then null else trim(scope) end as scope,
		express_type_id,
		buildin,
		case when trim(is_reachable_region) in ('','null','None') then null else trim(is_reachable_region) end as is_reachable_region,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.BAS_Delivery_Type_STG
where dt = @dt
END

GO
