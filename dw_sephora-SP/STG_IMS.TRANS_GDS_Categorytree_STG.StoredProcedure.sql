/****** Object:  StoredProcedure [STG_IMS].[TRANS_GDS_Categorytree_STG]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_GDS_Categorytree_STG] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.GDS_Categorytree_STG;
insert into STG_IMS.GDS_Categorytree_STG
select 
		id,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		parentid,
		classificationid,
		catalogid,
		case when trim(content) in ('','null','None') then null else trim(content) end as content,
		createtime,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		checked,
		case when trim(isbilling) in ('','null','None') then null else trim(isbilling) end as isbilling,
		data_create_time,
		data_update_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.GDS_Categorytree_STG
where dt = @dt
END

GO
