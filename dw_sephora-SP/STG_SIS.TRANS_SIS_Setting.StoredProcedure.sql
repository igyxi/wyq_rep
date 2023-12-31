/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Setting]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Setting] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Setting;
insert into STG_SIS.SIS_Setting
select 
		id,
		case when trim(setting_type) in ('','null') then null else trim(setting_type) end as setting_type,
		case when trim(setting_value) in ('','null') then null else trim(setting_value) end as setting_value,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
    ODS_SIS.SIS_Setting
WHERE
    dt=@dt
END
GO
