/****** Object:  StoredProcedure [STG_IMS].[TRANS_MKT_Progoodsscopede]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_MKT_Progoodsscopede] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-21       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.MKT_Progoodsscopede;
insert into STG_IMS.MKT_Progoodsscopede
select 
		id,
		promotion_id,
		scope_type,
		case when trim(scope_desc) in ('','null','None') then null else trim(scope_desc) end as scope_desc,
		is_exception,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.MKT_Progoodsscopede
where dt = @dt
END

GO
