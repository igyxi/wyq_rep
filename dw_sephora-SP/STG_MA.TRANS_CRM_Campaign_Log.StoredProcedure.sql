/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Campaign_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Campaign_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Campaign_Log;
insert into STG_MA.CRM_Campaign_Log
select 
		id,
		campaign_id,
		case when trim(loop) in ('','null') then null else trim(loop) end as loop,
		start_date,
		end_date,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
		test,
		current_timestamp as insert_timestamp
from    
    ODS_MA.CRM_Campaign_Log
where   
    dt = @dt
END
GO
