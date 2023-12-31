/****** Object:  StoredProcedure [STG_Activity].[TRANS_Gift_Event_Partner]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Activity].[TRANS_Gift_Event_Partner] AS
BEGIN
truncate table STG_Activity.Gift_Event_Partner ;
insert into STG_Activity.Gift_Event_Partner
select 
    id,
    gift_event_id,
    sharer_user_id,
    partner_user_id,
    case when trim(partner_nick_name) in ('null','') then null else trim(partner_nick_name) end as partner_nick_name,
    case when trim(partner_avatar_url) in ('null','') then null else trim(partner_avatar_url) end as partner_avatar_url,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Activity.Gift_Event_Partner
) t
where rownum = 1
END


GO
