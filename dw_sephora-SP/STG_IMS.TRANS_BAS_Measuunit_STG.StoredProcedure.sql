/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Measuunit_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Measuunit_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.BAS_Measuunit_STG;
insert into STG_IMS.BAS_Measuunit_STG
select 
		case when trim(conversion_type) in ('','null','None') then null else trim(conversion_type) end as conversion_type,
		case when trim(elementary_unit) in ('','null','None') then null else trim(elementary_unit) end as elementary_unit,
		case when trim(type_name) in ('','null','None') then null else trim(type_name) end as type_name,
		case when trim(disable_by) in ('','null','None') then null else trim(disable_by) end as disable_by,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		case when trim(builtin) in ('','null','None') then null else trim(builtin) end as builtin,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		case when trim(round_type) in ('','null','None') then null else trim(round_type) end as round_type,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		disable_date,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		create_channel_id,
		base_unit_rate,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		unit_precision,
		current_unit_rate,
		enable_date,
		case when trim(type_code) in ('','null','None') then null else trim(type_code) end as type_code,
		id,
		create_time,
		case when trim(enable_by) in ('','null','None') then null else trim(enable_by) end as enable_by,
		conversion_rate,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.BAS_Measuunit_STG
where dt = @dt
END

GO
