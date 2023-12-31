/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Campaign_Target]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Campaign_Target] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Campaign_Target;
insert into STG_MA.CRM_Campaign_Target
select 
		id,
		case when trim(member_code) in ('','null') then null else trim(member_code) end as member_code,
		case when trim(loop) in ('','null') then null else trim(loop) end as loop,
		campaign_id,
        node_id,
		case when trim(data_type) in ('','null') then null else trim(data_type) end as data_type,
		case when trim(wave) in ('','null') then null else trim(wave) end as wave,
		case when trim(feedback) in ('','null') then null else trim(feedback) end as feedback,
		case when trim(abtest_node_ids) in ('','null') then null else trim(abtest_node_ids) end as abtest_node_ids,
		case when trim(flow_id) in ('','null') then null else trim(flow_id) end as flow_id,
		case when trim(member_content) in ('','null') then null else trim(member_content) end as member_content,
		case when trim(static_control) in ('','null') then null else trim(static_control) end as static_control,
		case when trim(extend_control) in ('','null') then null else trim(extend_control) end as extend_control,
		current_timestamp as insert_timestamp
from
(
    select *, row_number() over(partition by id,campaign_id order by dt desc) rownum from ODS_MA.CRM_Campaign_Target
) t
where rownum = 1;
END
GO
