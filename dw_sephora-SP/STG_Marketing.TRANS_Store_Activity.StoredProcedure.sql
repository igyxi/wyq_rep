/****** Object:  StoredProcedure [STG_Marketing].[TRANS_Store_Activity]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Marketing].[TRANS_Store_Activity] AS
BEGIN
truncate table STG_Marketing.Store_Activity;
insert into STG_Marketing.Store_Activity
select 
    activity_id,
    sequence,
    case when trim(notification) in ('null','') then null else trim(notification) end as notification,
    case when trim(event_name) in ('null','') then null else trim(event_name) end as event_name,
    case when trim(event_type) in ('null','') then null else trim(event_type) end as event_type,
    show_start_time,
    show_end_time,
    appo_start_time,
    appo_end_time,
    case when trim(appo_count) in ('null','') then null else trim(appo_count) end as appo_count,
    case when trim(appo_count_type) in ('null','') then null else trim(appo_count_type) end as appo_count_type,
    allow_cancel_day,
    case when trim(channel) in ('null','') then null else trim(channel) end as channel,
    case when trim(can_current_day) in ('null','') then null else trim(can_current_day) end as can_current_day,
    case when trim(user_group_switch) in ('null','') then null else trim(user_group_switch) end as user_group_switch,
    case when trim(user_group) in ('null','') then null else trim(user_group) end as user_group,
    case when trim(content) in ('null','') then null else trim(content) end as content,
    case when trim(status) in ('null','') then null else trim(status) end as status,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,        
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    case when trim(is_delete) in ('null','') then null else trim(is_delete) end as is_delete,
    last_update_time ,
    total_count_limit,    
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by activity_id order by dt desc) rownum from ODS_Marketing.Store_Activity
) t
where rownum = 1;
END
GO
