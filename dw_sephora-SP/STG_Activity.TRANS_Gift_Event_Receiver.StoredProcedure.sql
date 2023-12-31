/****** Object:  StoredProcedure [STG_Activity].[TRANS_Gift_Event_Receiver]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Activity].[TRANS_Gift_Event_Receiver] AS
BEGIN
truncate table STG_Activity.Gift_Event_Receiver ;
insert into STG_Activity.Gift_Event_Receiver
select 
    id,
    user_id,
    gift_event_id,
    create_time,
    update_time,
    case when trim(channel) in ('null','') then null else trim(channel) end as channel,
    status,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    gift_event_sku_id,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    offline_event_id,
    case when trim(channel_type) in ('null','') then null else trim(channel_type) end as channel_type,
    case when trim(promotion_id) in ('null','') then null else trim(promotion_id) end as promotion_id,
    case when trim(order_id) in ('null','') then null else trim(order_id) end as order_id,
    order_create_time,
    order_update_time,
    case when trim(store_code) in ('null','') then null else trim(store_code) end as store_code,
    gift_type,
    participate_type,
    current_timestamp as insert_timestamp
from 
(
    select *,row_number() over(partition by id order by dt desc) rownum from ODS_Activity.Gift_Event_Receiver
) t
where rownum = 1
END


GO
