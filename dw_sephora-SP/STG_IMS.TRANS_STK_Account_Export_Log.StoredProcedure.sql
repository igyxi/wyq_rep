/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Account_Export_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Account_Export_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Account_Export_Log;
insert into STG_IMS.STK_Account_Export_Log
select 
		id,
		case when trim(param) in ('','null','None') then null else trim(param) end as param,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		create_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		modify_time,
		case when trim(type) in ('','null','None') then null else trim(type) end as type,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Account_Export_Log
where dt = @dt
END
GO
