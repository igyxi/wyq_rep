/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_VB_Restrict]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_VB_Restrict] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_VB_Restrict;
insert into STG_IMS.STK_VB_Restrict
select 
		id,
		case when trim(store_code) in ('','null','None') then null else trim(store_code) end as store_code,
		case when trim(vb_code) in ('','null','None') then null else trim(vb_code) end as vb_code,
		restrict_qty,
		case when trim(status) in ('','null','None') then null else trim(status) end as status,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_VB_Restrict
where dt = @dt
END
GO
