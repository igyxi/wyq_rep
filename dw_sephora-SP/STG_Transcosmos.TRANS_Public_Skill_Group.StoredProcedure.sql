/****** Object:  StoredProcedure [STG_Transcosmos].[TRANS_Public_Skill_Group]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Transcosmos].[TRANS_Public_Skill_Group] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-07       wangzhichun        Initial Version
-- ========================================================================================
truncate table [STG_TRANSCOSMOS].[Public_Skill_Group];
insert into [STG_TRANSCOSMOS].[Public_Skill_Group]
select 
	id,
	case when trim(lower(name)) in ('','null') then null else trim(name) end as name,
	group_id,
	case when trim(lower(description)) in ('','null') then null else trim(description) end as description,
	case when trim(lower(knowledge_set_id)) in ('','null') then null else trim(knowledge_set_id) end as knowledge_set_id,
	case when trim(lower(third_id)) in ('','null') then null else trim(third_id) end as third_id,
	case when trim(lower(third_type)) in ('','null') then null else trim(third_type) end as third_type,
	case when trim(lower(keyword)) in ('','null') then null else trim(keyword) end as keyword,
	create_user_id,
	create_time,
	del,
	web_id,
	director_id,
	customer_service_id,
	case when trim(lower(bridge_id)) in ('','null') then null else trim(bridge_id) end as bridge_id,
    current_timestamp as insert_timestamp
from 
    ODS_Transcosmos.Public_Skill_Group
where 
    dt = @dt;
END
GO
