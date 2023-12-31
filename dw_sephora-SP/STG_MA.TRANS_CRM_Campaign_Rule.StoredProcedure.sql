/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Campaign_Rule]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Campaign_Rule] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Campaign_Rule;
insert into STG_MA.CRM_Campaign_Rule
select 
		id,
		campaign_id,
		case when trim(draw_json) in ('','null') then null else trim(draw_json) end as draw_json,
		case when trim(bpm_xml) in ('','null') then null else trim(bpm_xml) end as bpm_xml,
		bu_id,
		owner_id,
		create_user_id,
		case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
		case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
		update_user_id,
		case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
		case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
		version,
		current_timestamp as insert_timestamp
from    ODS_MA.CRM_Campaign_Rule
where   dt = @dt
END
GO
