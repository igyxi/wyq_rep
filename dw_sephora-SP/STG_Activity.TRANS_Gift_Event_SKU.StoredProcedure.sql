/****** Object:  StoredProcedure [STG_Activity].[TRANS_Gift_Event_SKU]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Activity].[TRANS_Gift_Event_SKU] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Activity.Gift_Event_SKU;
insert into STG_Activity.Gift_Event_SKU
select 
    id,
    gift_event_id,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,  
    case when trim(sku_id) in ('null','') then null else trim(sku_id) end as sku_id,
    quantity,   
    inventory,  
    create_time, 
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user, 
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    limit_count,
    offline_event_id,
    case when trim(channel) in ('null','') then null else trim(channel) end as channel,
    store_inventory_id,
    step_no,
    case when trim(sku_name) in ('null','') then null else trim(sku_name) end as sku_name,
    participate_type,
    case when trim(partner_success_text) in ('null','') then null else trim(partner_success_text) end as partner_success_text,
    current_timestamp as insert_timestamp
from 
    ODS_Activity.Gift_Event_SKU 
where dt = @dt;
END

GO
