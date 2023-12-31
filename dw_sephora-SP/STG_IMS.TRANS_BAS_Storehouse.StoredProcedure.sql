/****** Object:  StoredProcedure [STG_IMS].[TRANS_BAS_Storehouse]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_BAS_Storehouse] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.BAS_Storehouse;
insert into STG_IMS.BAS_Storehouse
select 
		id,
		warehouse_id,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		case when trim(type) in ('','null','None') then null else trim(type) end as type,
		case when trim(sort) in ('','null','None') then null else trim(sort) end as sort,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		version,
		lastchanged,
		current_timestamp as insert_timestamp
from  ODS_IMS.BAS_Storehouse
where dt = @dt
END
GO
