/****** Object:  StoredProcedure [TEMP].[SP_RPT_Campaign_Card_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Campaign_Card_Bak_20230518] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-19       Eric               Change tablename
-- 2023-02-28       houshuangqiang     Change source_table
-- ========================================================================================
truncate table DW_Activity.RPT_Campaign_Card;
insert into DW_Activity.RPT_Campaign_Card
select
    gift_event_id,
    u.card_no,
    is_apply_member,
    is_get_member,
    current_timestamp as insert_timestamp
from 
(
    select   
        case when a.gift_event_id is not null then a.gift_event_id else g.gift_event_id end as gift_event_id,
        case when a.sharer_user_id is not null then a.sharer_user_id else g.partner_user_id end as user_id,
        case when is_apply_member is not null then is_apply_member else 0 end as is_apply_member,
        case when is_get_member is not null then is_get_member else 0 end is_get_member
    from 
    (
        select distinct gift_event_id, sharer_user_id, 1 as is_apply_member from [ODS_Activity].[Gift_Event_Partner]
    ) a
    full join 
    (
        select distinct gift_event_id, partner_user_id, 1 as is_get_member from [ODS_Activity].[Gift_Event_Partner]
    ) g
    on a.gift_event_id = g.gift_event_id
    and a.sharer_user_id = g.partner_user_id
) t
left join
    (select user_id, card_no, row_number() over(partition by card_no order by user_id) rn from [STG_User].[User_Profile] where card_no is not null) u
on t.user_id = u.user_id
and u.rn = 1
where u.card_no is not null;

END 
GO
