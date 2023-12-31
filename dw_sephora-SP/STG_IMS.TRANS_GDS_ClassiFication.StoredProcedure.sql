/****** Object:  StoredProcedure [STG_IMS].[TRANS_GDS_ClassiFication]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_GDS_ClassiFication] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-16       wangzhichun           Initial Version
-- 2022-12-15       wangzhichun           change schema
-- ========================================================================================
truncate table STG_IMS.GDS_ClassiFication;
insert into STG_IMS.GDS_ClassiFication
select 
		id,
		case when trim(code) in ('','null') then null else trim(code) end as code,
		case when trim(name) in ('','null') then null else trim(name) end as name,
		case when trim(goodstablename) in ('','null') then null else trim(goodstablename) end as goodstablename,
		case when trim(sptablename) in ('','null') then null else trim(sptablename) end as sptablename,
		case when trim(status) in ('','null') then null else trim(status) end as status,
		createtime,
		modifytime,
		case when trim(specification_type) in ('','null') then null else trim(specification_type) end as specification_type,
		current_timestamp as insert_timestamp
from    ODS_IMS.GDS_ClassiFication
where dt = @dt
END
GO
