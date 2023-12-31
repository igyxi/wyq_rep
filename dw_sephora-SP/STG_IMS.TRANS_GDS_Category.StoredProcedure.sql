/****** Object:  StoredProcedure [STG_IMS].[TRANS_GDS_Category]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_GDS_Category] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-16       wubin          Initial Version
-- 2022-09-28       wubin          update data_create_time/data_update_time
-- 2022-12-15       wangzhichun    change schema
-- ========================================================================================
truncate table STG_IMS.GDS_Category;
insert into STG_IMS.GDS_Category
select 
		id,
		case when trim(code) in ('','null') then null else trim(code) end as code,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(status) in ('','null') then null else trim(status) end as status,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		createtime,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from    ODS_IMS.GDS_Category
where dt = @dt
END
GO
