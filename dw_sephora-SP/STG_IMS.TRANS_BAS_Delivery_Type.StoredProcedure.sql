/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Delivery_Type]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Delivery_Type] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-16       wubin          Initial Version
-- 2022-09-28       wubin          update data_create_time/data_update_time
-- 2022-12-15       wangzhichun           change schema
-- ========================================================================================
truncate table STG_IMS.BAS_Delivery_Type;
insert into STG_IMS.BAS_Delivery_Type
select 
		id,
		case when trim(price_id) in ('','null') then null else trim(price_id) end as price_id,
		case when trim(disable_by) in ('','null') then null else trim(disable_by) end as disable_by,
		create_date,
		case when trim(modify_by) in ('','null') then null else trim(modify_by) end as modify_by,
		price_dimension_id,
		modify_time,
		modify_date,
		case when trim(use_insure) in ('','null') then null else trim(use_insure) end as use_insure,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(code) in ('','null') then null else trim(code) end as code,
		disable_date,
		case when trim(status) in ('','null') then null else trim(status) end as status,
		create_channel_id,
		case when trim(pay_after) in ('','null') then null else trim(pay_after) end as pay_after,
		case when trim(create_by) in ('','null') then null else trim(create_by) end as create_by,
		enable_date,
		case when trim([rule]) in ('','null') then null else trim([rule]) end as [rule],
		create_time,
		case when trim(enable_by) in ('','null') then null else trim(enable_by) end as enable_by,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		case when trim(type) in ('','null') then null else trim(type) end as type,
		logroid,
		case when trim(non_jdorder_warehouse) in ('','null') then null else trim(non_jdorder_warehouse) end as non_jdorder_warehouse,
		non_jdorder_warehousepri,
		case when trim(is_jdorder_warehouse) in ('','null') then null else trim(is_jdorder_warehouse) end as is_jdorder_warehouse,
		is_jdorder_warehousepri,
		case when trim(precon_signment_express) in ('','null') then null else trim(precon_signment_express) end as precon_signment_express,
		precon_signment_expresspri,
		case when trim(app_scene) in ('','null') then null else trim(app_scene) end as app_scene,
		priority,
		case when trim(scope) in ('','null') then null else trim(scope) end as scope,
		express_type_id,
		buildIn,
		case when trim(is_reachable_region) in ('','null') then null else trim(is_reachable_region) end as is_reachable_region,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from    ODS_IMS.BAS_Delivery_Type
where dt = @dt
END
GO
