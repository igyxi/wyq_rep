/****** Object:  StoredProcedure [STG_MA].[TRANS_CRM_Channel]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MA].[TRANS_CRM_Channel] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-25       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_MA.CRM_Channel;
insert into STG_MA.CRM_Channel
select 
        id,
        club_id,
        case when trim(name) in ('','null') then null else trim(name) end as name,
        case when trim(description) in ('','null') then null else trim(description) end as description,
        create_user_id,
        case when trim(create_date) in ('','null') then null else trim(create_date) end as create_date,
        case when trim(create_time) in ('','null') then null else trim(create_time) end as create_time,
        update_user_id,
        case when trim(update_date) in ('','null') then null else trim(update_date) end as update_date,
        case when trim(update_time) in ('','null') then null else trim(update_time) end as update_time,
        case when trim(channel_code) in ('','null') then null else trim(channel_code) end as channel_code,
        case when trim(parent_code) in ('','null') then null else trim(parent_code) end as parent_code,
		current_timestamp as insert_timestamp
from    
    ODS_MA.CRM_Channel
where
    dt = @dt
END
GO
