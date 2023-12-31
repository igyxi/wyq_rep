/****** Object:  StoredProcedure [DWD].[SP_Fact_Appointment_Record]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Appointment_Record] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-20       hsq           	Initial Version
-- 2023-04-27 		houshuangqiang 	rename Fact_InStore_Service to Fact_Appointment_Record & add columns
-- 2023-05-04       wangzhichun     change appointment_sub_channel
-- 2023-05-25       joeyshen        union尊美活动预约数据
-- ========================================================================================
truncate table DWD.Fact_Appointment_Record;
insert  into DWD.Fact_Appointment_Record
select
    ai.id,
    ai.card_num as member_card,
    coalesce(defined_level.param_txt, N'未知') as card_type,
    ai.openid as opend_id,
    ai.user_id as eb_user_id,
    ai.activity_id as activity_id,
    activity.name as activity_name,
    null as appointment_source,
    coalesce(defined_channel.param_txt, '-') as appointment_channel,
    channel.name as appointment_sub_channel,
    coalesce(defined_staff_channel.param_txt, N'用户预约') as appointment_type,
    coalesce(defined_status.param_txt, N'异常') as appointment_status,
    ai.store_code,
    store.store_name,
    ai.customer_name as user_name,
    ai.mobile,
    ai.customer_remarks as booking_remark,
    concat_ws(' ', ai.book_date, ai.book_time) as book_time,
    ai.book_date,
    ai.done_time as checkin_time,
    ai.done_time as complete_time,
    ai.inviter_staff_no,
    ai.staff_no,
    ai.staff_remarks,
    case  when ai.activity_id = 9 and ai_ext.customer_extra is not null then json_value(ai_ext.customer_extra, '$.service_content[0].field_name')
        else ''
    end as service_content,
    null as satisfaction_score,
    ai.created_at as create_time,
    ai.updated_at as update_time,
    'MS' as source,
    current_timestamp insert_timestamp
from
    ODS_MS_Appointment.POC_Appointment_Info ai
left join
    ODS_MS_Appointment.Store_Info store
on store.store_id = ai.store_code
left join
    ODS_MS_Appointment.POC_Activity_Channel channel
on  ai.sub_channel=channel.sub_channel
left join
    ODS_MS_Appointment.POC_Activity_Info activity
on activity.id = ai.activity_id
left join
    ODS_MS_Appointment.POC_Appointment_Extra ai_ext
on ai_ext.appointment_id = ai.id
left join
    ODS_MS_Appointment.System_Defined defined_level
on 	defined_level.param_name = 'member.card_level'
and defined_level.param_val = ai.card_level
left join
    ODS_MS_Appointment.System_Defined defined_staff_channel
on 	defined_staff_channel.param_name = 'booking.staff_channel'
and defined_staff_channel.param_val = ai.staff_channel
left join
    ODS_MS_Appointment.System_Defined defined_channel
on defined_channel.param_name = 'booking.channel'
and defined_channel.param_val = ai.channel
left join
    ODS_MS_Appointment.System_Defined defined_status
on defined_status.param_name = 'booking.record_status'
and defined_status.param_val = ai.status
-- 
UNION ALL
SELECT
    a.id,
    c.cardNo as member_card,
    case when cardLevel = 'BLACK' then N'黑卡'
        when cardLevel = 'WHITE' then N'白卡'
        when cardLevel = 'PINK' then N'粉卡'
        when cardLevel = 'GOLD' then N'金卡'
        ELSE N'未知' 
    END as card_type,
    null as open_id,
    a.userId as eb_user_id,
    null as activity_id,
    N'尊美VIC' as activity_name,
    null as appointment_source,
    a.app_channel as appointment_channel,
    null as appointment_sub_channel,
    null as appointment_type,
    Case when active_ts >0  then N'已签到'
        when a.status =0 then N'已取消'
        when survey_json is not null then N'已预约'
        else null 
    end as appointment_status,
    b.shop_code as store_code,
    b.shop_name as store_name,
    null as user_name,
    null as mobile,
    null as booking_remark,
    cast(cast((LEFT(d.date_code,4) + '-' +  RIGHT(LEFT(d.date_code,6),2) + '-' + RIGHT(d.date_code, 2)) as date) as nvarchar) as book_time,
    cast((LEFT(d.date_code,4) + '-' +  RIGHT(LEFT(d.date_code,6),2) + '-' + RIGHT(d.date_code, 2)) as date) as book_date,
    DATEADD(second,cast(left(a.active_ts,10) as int) + 8 * 60 * 60,'1970-01-01 00:00:00') as checkin_time,
    DATEADD(second,cast(left(a.active_ts,10) as int) + 8 * 60 * 60,'1970-01-01 00:00:00')  as complete_time,
    null as inviter_staff_no,
    null as staff_no,
    null as staff_remarks,
    null as service_content,
    null as satisfaction_score,
    DATEADD(second,cast(left(a.create_ts,10) as int) + 8 * 60 * 60,'1970-01-01 00:00:00') as create_time,
    DATEADD(second,cast(left(a.create_ts,10) as int) + 8 * 60 * 60,'1970-01-01 00:00:00') as update_time,
    'ZMC' as source,
    current_timestamp insert_timestamp
FROM 
    [ODS_ZMC].[Appointment] a
LEFT JOIN 
    [ODS_ZMC].[Event] b
ON a.event_id = b.id
LEFT JOIN 
    [ODS_ZMC].[User] c
ON a.userId = c.userId
LEFT JOIN 
    [ODS_ZMC].[Event_Session] d
ON a.event_session_id = d.id
;
END

GO
