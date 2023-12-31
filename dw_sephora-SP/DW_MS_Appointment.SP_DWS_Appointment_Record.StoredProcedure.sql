/****** Object:  StoredProcedure [DW_MS_Appointment].[SP_DWS_Appointment_Record]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_MS_Appointment].[SP_DWS_Appointment_Record] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-19       hsq           Initial Version
-- ========================================================================================
truncate table DW_MS_Appointment.DWS_Appointment_Record;
insert  into DW_MS_Appointment.DWS_Appointment_Record
select ai.card_num as member_card,
       ai.openid,
       coalesce(defined_level.param_txt, N'未知') as card_type,
       activity.name as activity_name,
       coalesce(defined_staff_channel.param_txt, N'用户预约') as appointment_type,
       coalesce(defined_channel.param_txt, N'-') as appointment_channel,
	   coalesce(defined_status.param_txt, N'异常') as appointment_status,
	   concat_ws(' ', ai.book_date, ai.book_time) as book_time,
	   ai.done_time as arrival_time,
	   ai.done_time as complete_time,
	   ai.store_code,
	   store.store_name,
       ai.customer_name,
       ai.mobile,
	   ai.inviter_staff_no,
	   ai.staff_no,
	   ai.staff_remarks,
	   ai.customer_remarks,
	   case  when ai.activity_id = 9 and ai_ext.customer_extra is not null then json_value(ai_ext.customer_extra, '$.service_content[0].field_name')
             else ''
	   end as service_content,
	   ai.created_at as created_time,
	   current_timestamp insert_timestamp
from
	STG_MS_Appointment.POC_Appointment_Info ai
left join
	STG_MS_Appointment.Store_Info store
on store.store_id = ai.store_code
left join
	STG_MS_Appointment.POC_Activity_Info activity
on activity.id = ai.activity_id
left join
	STG_MS_Appointment.POC_Appointment_Extra ai_ext
on ai_ext.appointment_id = ai.id
left join
	STG_MS_Appointment.System_Defined defined_level
on 	defined_level.param_name = 'member.card_level'
and defined_level.param_val = ai.card_level
left join
	STG_MS_Appointment.System_Defined defined_staff_channel
on 	defined_staff_channel.param_name = 'booking.staff_channel'
and  defined_staff_channel.param_val = ai.staff_channel
left join
	STG_MS_Appointment.System_Defined defined_channel
on defined_channel.param_name = 'booking.channel'
and defined_channel.param_val = ai.staff_channel
left join
	STG_MS_Appointment.System_Defined defined_status
on defined_status.param_name = 'booking.record_status'
and defined_status.param_val = ai.status
where ai.activity_id in (2, 9, 10)
END
GO
