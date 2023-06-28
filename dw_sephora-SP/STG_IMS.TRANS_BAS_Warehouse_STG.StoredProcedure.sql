/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Warehouse_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Warehouse_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.BAS_Warehouse_STG;
insert into STG_IMS.BAS_Warehouse_STG
select 
		id,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		channel_id,
		area_id,
		sort,
		case when trim(control_type) in ('','null','None') then null else trim(control_type) end as control_type,
		case when trim(type) in ('','null','None') then null else trim(type) end as type,
		case when trim(property) in ('','null','None') then null else trim(property) end as property,
		is_fictitious,
		is_negative,
		case when trim(level) in ('','null','None') then null else trim(level) end as level,
		daily_orders_quantity,
		parent_channel_id,
		case when trim(external_warehouse_code) in ('','null','None') then null else trim(external_warehouse_code) end as external_warehouse_code,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(province) in ('','null','None') then null else trim(province) end as province,
		case when trim(city) in ('','null','None') then null else trim(city) end as city,
		case when trim(area) in ('','null','None') then null else trim(area) end as area,
		case when trim(address) in ('','null','None') then null else trim(address) end as address,
		case when trim(linkman) in ('','null','None') then null else trim(linkman) end as linkman,
		case when trim(longitude) in ('','null','None') then null else trim(longitude) end as longitude,
		case when trim(latitude) in ('','null','None') then null else trim(latitude) end as latitude,
		case when trim(telephone_number) in ('','null','None') then null else trim(telephone_number) end as telephone_number,
		case when trim(mobile_number) in ('','null','None') then null else trim(mobile_number) end as mobile_number,
		case when trim(zip_code) in ('','null','None') then null else trim(zip_code) end as zip_code,
		case when trim(email) in ('','null','None') then null else trim(email) end as email,
		case when trim(facsimile) in ('','null','None') then null else trim(facsimile) end as facsimile,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		version,
		lastchanged,
		case when trim(country) in ('','null','None') then null else trim(country) end as country,
		owner_id,
		case when trim(sim_name) in ('','null','None') then null else trim(sim_name) end as sim_name,
		case when trim(en_name) in ('','null','None') then null else trim(en_name) end as en_name,
		case when trim(en_sim_name) in ('','null','None') then null else trim(en_sim_name) end as en_sim_name,
		case when trim(contrast_code) in ('','null','None') then null else trim(contrast_code) end as contrast_code,
		site_id,
		delivery_type_id,
		safety_stock,
		cooperative_state,
		case when trim(sap_warehouse_code) in ('','null','None') then null else trim(sap_warehouse_code) end as sap_warehouse_code,
		case when trim(available_channel) in ('','null','None') then null else trim(available_channel) end as available_channel,
		case when trim(return_linkman) in ('','null','None') then null else trim(return_linkman) end as return_linkman,
		case when trim(return_cellphone) in ('','null','None') then null else trim(return_cellphone) end as return_cellphone,
		case when trim(return_address) in ('','null','None') then null else trim(return_address) end as return_address,
		case when trim(return_remark) in ('','null','None') then null else trim(return_remark) end as return_remark,
		data_create_time,
		data_update_time,
		is_join_routing,
		case when trim(available_store) in ('','null','None') then null else trim(available_store) end as available_store,
		is_allowed_partial_ship,
		is_allowed_prepackage,
		current_timestamp as insert_timestamp
from  ODS_IMS.BAS_Warehouse_STG
where dt = @dt
END
GO
