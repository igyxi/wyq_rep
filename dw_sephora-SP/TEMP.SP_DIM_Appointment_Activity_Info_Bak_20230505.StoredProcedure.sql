/****** Object:  StoredProcedure [TEMP].[SP_DIM_Appointment_Activity_Info_Bak_20230505]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Appointment_Activity_Info_Bak_20230505] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-28       houshuangqiang     Initial Version
-- ----------------------------------------------------------------------------------------
truncate table DWD.DIM_Appointment_Activity_Info;
insert 	into DWD.DIM_Appointment_Activity_Info
select 	activity.id,
		activity.[name] as activity_name,
        act_type.name as activity_type,
		activity.status as activity_status,
		tag.tag_name,
        'Service' as touchpoint_type,
		case when total_count > 0 then total_count else null end as maximum_service_limitation,
		identity_marker as member_tier,
		min(format(activity.event_start_time, 'yyyy-MM-dd')) over(partition by activity.id) as first_launch_date,
		activity.event_start_time,
		activity.event_end_time,
		datediff(day,activity.event_start_time,activity.event_end_time) as estimate_touchpoint_days,
        activity.reservation_start_time,
		activity.reservation_end_time,
        activity.item_id as item_id,
        activity.can_appointment as is_appointment,
		CURRENT_TIMESTAMP as insert_timestamp
from 	ODS_MS_Appointment.Poc_Activity_Info activity
left 	join ODS_MS_Appointment.Poc_Activity_Type act_type 
on 		activity.type = act_type.id
left 	join 
(
	select 	activity_id,
			string_agg(tag_name, '|') as tag_name
	from 	ODS_MS_Appointment.Poc_Activity_Tag_Relation relation
	left 	join ODS_MS_Appointment.Poc_Activity_Tag tag
	on 		relation.tag_id=tag.id
	group 	by activity_id
) tag
on 		activity.id=tag.activity_id;
end 
GO
