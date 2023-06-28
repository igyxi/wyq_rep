/****** Object:  StoredProcedure [TEMP].[INI_Fact_Message_Send_Bak20230508]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[INI_Fact_Message_Send_Bak20230508] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description      version
-- ----------------------------------------------------------------------------------------
-- 2022-10-25       Tali                            Initial Version
-- ========================================================================================
truncate table DWD.Fact_Message_Send;
insert into DWD.Fact_Message_Send
select 
    a.id, 
    a.mkt_id as campaign_code,
    isnull(b.campaign_name, c.event_name) as campaign_name,
    -- isnull(b.campaign_type, c.event_type) as campaign_type,
    'APP' as channel_name,
    member_code as member_card, 
    mkt_type as send_type,
    case 
        when send_status = 1 then 'delivery' 
        when send_status = 3 then 'failed'
        when send_status = 0 then 'waited'
        when send_status = 2 then 'undisturbed'
        else 'others'
    end  as send_status, 
    send_datetime,
    send_content,
    data_type,
    a.create_datetime,
    concat(convert(date, a.update_date, 112), ' ', stuff(stuff(a.update_time,5,0,':'),3,0,':')) as update_time,
    'MA' as source,
    CURRENT_TIMESTAMP as insert_timestamp 
from 
    STG_MA.CRM_APP_Push a
left join 
    STG_MA.CRM_Campaign b
on a.mkt_id = b.campaign_id
and a.mkt_type = 1
left join 
    STG_MA.CRM_Event c
on a.mkt_id = c.event_id
and a.mkt_type = 2

union all
select
    a.id,
    a.mkt_id as campaign_code,
    isnull(b.campaign_name, c.event_name) as campaign_name,
    -- isnull(b.campaign_type, c.event_type) as campaign_type,
    'SMS' as channel_name,
    member_code as member_card,
    mkt_type as send_type,
    case 
        when send_status = 1 then 'delivery' 
        when send_status = 3 then 'failed'
        when send_status = 0 then 'waited'
        when send_status = 2 then 'undisturbed'
        else 'others'
    end   as send_status, 
    send_datetime,
    send_content, 
    data_type, 
    a.create_datetime,
    concat(convert(date, a.update_date, 112), ' ', stuff(stuff(a.update_time,5,0,':'),3,0,':')) as update_time,
    'MA' as source,
    CURRENT_TIMESTAMP as insert_timestamp 
from 
    STG_MA.CRM_SMS_Send a
left join 
    STG_MA.CRM_Campaign b
on a.mkt_id = b.campaign_id
and a.mkt_type = 1
left join 
    STG_MA.CRM_Event c
on a.mkt_id = c.event_id
and a.mkt_type = 2

union all
select
    a.id,
    a.mkt_id as campaign_code, 
    isnull(b.campaign_name, c.event_name) as campaign_name,
    -- isnull(b.campaign_type, c.event_type) as campaign_type,
    'MMS' as channel_name,
    member_code as member_card,
    mkt_type as send_type,
    case 
        when send_status = 1 then 'delivery' 
        when send_status = 3 then 'failed'
        when send_status = 0 then 'waited'
        when send_status = 2 then 'undisturbed'
        else 'others'
    end as send_status,  
    send_datetime,
    send_content, 
    data_type,
    a.create_datetime,
    concat(convert(date, a.update_date, 112), ' ', stuff(stuff(a.update_time,5,0,':'),3,0,':')) as update_time,
    'MA' as source,
    CURRENT_TIMESTAMP as insert_timestamp 
from 
    STG_MA.CRM_MMS_Send a
left join 
    STG_MA.CRM_Campaign b
on a.mkt_id = b.campaign_id
and a.mkt_type = 1
left join 
    STG_MA.CRM_Event c
on a.mkt_id = c.event_id
and a.mkt_type = 2

union all
select
    a.id,
    a.mkt_id as campaign_code,
    isnull(b.campaign_name, c.event_name) as campaign_name,
    -- isnull(b.campaign_type, c.event_type) as campaign_type,
    'Video_SMS' as channel_name,
    member_code as member_card,
    mkt_type as send_type,
    case 
        when send_status = 1 then 'delivery' 
        when send_status = 3 then 'failed'
        when send_status = 0 then 'waited'
        when send_status = 2 then 'undisturbed'
        else 'others'
    end   as send_status, 
    send_datetime,
    send_content,
    data_type,
    a.create_datetime,
    concat(convert(date, a.update_date, 112), ' ', stuff(stuff(a.update_time,5,0,':'),3,0,':')) as update_time,
    'MA' as source,
    CURRENT_TIMESTAMP as insert_timestamp 
from 
    STG_MA.CRM_Video_SMS_Send a
left join 
    STG_MA.CRM_Campaign b
on a.mkt_id = b.campaign_id
and a.mkt_type = 1
left join 
    STG_MA.CRM_Event c
on a.mkt_id = c.event_id
and a.mkt_type = 2

union all
select
    a.id, 
    a.mkt_id as campaign_code,
    isnull(b.campaign_name, c.event_name) as campaign_name,
    -- isnull(b.campaign_type, c.event_type) as campaign_type,
    'Wechat' as channel_name,
    member_code as member_card,
    mkt_type as send_type,
    case 
        when send_status = 1 then 'delivery' 
        when send_status = 3 then 'failed'
        when send_status = 0 then 'waited'
        when send_status = 2 then 'undisturbed'
        else 'others'
    end   as send_status,
    send_datetime, 
    send_content, 
    data_type,
    
    a.create_datetime,
    concat(convert(date, a.update_date, 112), ' ', stuff(stuff(a.update_time,5,0,':'),3,0,':')) as update_time,
    'MA' as source,
    CURRENT_TIMESTAMP as insert_timestamp 
from 
    STG_MA.CRM_Wechat_Send a
left join 
    STG_MA.CRM_Campaign b
on a.mkt_id = b.campaign_id
and a.mkt_type = 1
left join 
    STG_MA.CRM_Event c
on a.mkt_id = c.event_id
and a.mkt_type = 2

union all
select
    a.id,
    a.mkt_id as campaign_code, 
    isnull(b.campaign_name, c.event_name) as campaign_name,
    -- isnull(b.campaign_type, c.event_type) as campaign_type,
    'Message_Box' as channel_name,
    member_code as member_card,
    mkt_type as send_type,
    case 
        when send_status = 1 then 'delivery' 
        when send_status = 3 then 'failed'
        when send_status = 0 then 'waited'
        when send_status = 2 then 'undisturbed'
        else 'others'
    end   as send_status, 
    send_datetime, 
    data_type,
    null as send_content,
    a.create_datetime,
    concat(convert(date, a.update_date, 112), ' ', stuff(stuff(a.update_time,5,0,':'),3,0,':')) as update_time,
    'MA' as source,
    CURRENT_TIMESTAMP as insert_timestamp 
from 
    STG_MA.CRM_Message_Box_Send a
left join 
    STG_MA.CRM_Campaign b
on a.mkt_id = b.campaign_id
and a.mkt_type = 1
left join 
    STG_MA.CRM_Event c
on a.mkt_id = c.event_id
and a.mkt_type = 2

union all
select
    a.id,
    a.mkt_id as campaign_code,
    isnull(b.campaign_name, c.event_name) as campaign_name,
    -- isnull(b.campaign_type, c.event_type) as campaign_type,
    'Mail' as channel_name, 
    member_code as member_card,
    mkt_type as send_type,
    case 
        when send_status = 1 then 'delivery' 
        when send_status = 3 then 'failed'
        when send_status = 0 then 'waited'
        when send_status = 2 then 'undisturbed'
        else 'others'
    end   as send_status, 
    send_datetime, 
    data_type,
    send_content,
    a.create_datetime,
    concat(convert(date, a.update_date, 112), ' ', stuff(stuff(a.update_time,5,0,':'),3,0,':')) as update_time,
    'MA' as source,
    CURRENT_TIMESTAMP as insert_timestamp 
from 
    STG_MA.CRM_Mail_Send a
left join 
    STG_MA.CRM_Campaign b
on a.mkt_id = b.campaign_id
and a.mkt_type = 1
left join 
    STG_MA.CRM_Event c
on a.mkt_id = c.event_id
and a.mkt_type = 2

union all
select
    communication_track_linked_obj_id as id,
    campaign_code, 
    campaign_name,
    -- c.campaign_type_name,
    b.comm_channel_type_name as channel_name, 
    account_number as member_card,
    null as send_type,
    c.status_name,
    coalesce(communication_targets_sms_export_time, communication_targets_mms_export_date, email_template_export_time, plan_exported_time) as send_date, 
    null as data_type,
    null as send_content,
    null as create_time,
    setting_time as update_time,
    'CMT' as source,
    CURRENT_TIMESTAMP as insert_timestamp 
from 
    ODS_CRM.communication_track_linked_obj a
left JOIN
    ODS_CRM.communication_channel_type b on a.communication_channel_type_id = b.communication_channel_type_id 
left join 
    ODS_CRM.knCommunication_Status c on a.communication_status_id = c.status_id
;
END

GO
