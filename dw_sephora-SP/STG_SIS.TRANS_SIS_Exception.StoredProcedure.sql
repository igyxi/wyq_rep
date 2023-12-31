/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Exception]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Exception] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-27       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Exception;
insert into STG_SIS.SIS_Exception
select 
		id,
		business_id,
		type,
		status,
		create_time,
		update_time,
		case when trim(business_content) in ('','null') then null else trim(business_content) end as business_content,
		current_timestamp as insert_timestamp
from 
    ODS_SIS.SIS_Exception
WHERE
    dt=@dt
END
GO
