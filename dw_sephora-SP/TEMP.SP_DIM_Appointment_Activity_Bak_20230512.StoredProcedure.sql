/****** Object:  StoredProcedure [TEMP].[SP_DIM_Appointment_Activity_Bak_20230512]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Appointment_Activity_Bak_20230512] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-28       houshuangqiang     Initial Version
-- 2023-05-04       wangzhichun        add columns
-- ----------------------------------------------------------------------------------------
truncate table DWD.DIM_Appointment_Activity;
insert 	into DWD.DIM_Appointment_Activity
select  
        activity.id,
        case when activity.display_page = 1 and act_type.classification = 1 then 'In-Store Service' ELSE N'Beauty School 美力颜究会' end as touchpoint_name,
		activity.[name] as activity_name,
        act_type.name as activity_type,
		activity.status as activity_status,
        'Service' as touchpoint_type,
		activity.investment_channels as investment_channels,
		tag.tag_name,
		case when total_count > 0 then total_count else null end as maximum_service_limitation,
        case when CHARINDEX('ASOFT', investment_channels) > 0 then 1 else 0 end as soft_exclusive,
		identity_marker as member_tier,
		min(format(activity.event_start_time, 'yyyy-MM-dd')) over(partition by activity.id) as first_launch_date,
		activity.event_start_time,
		activity.event_end_time,
        book.service_time as estimate_touchpoint_time,
        activity.reservation_start_time,
		activity.reservation_end_time,
        activity.item_id as sku_code,
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
on 		activity.id=tag.activity_id
left join
(
        select 
            activity_id,
            service_time,
            ROW_NUMBER() over (PARTITION BY activity_id order by [created_at] desc) rn
        FROM 
            [ODS_MS_Appointment].[POC_Activity_Book]
) book
on activity.id=book.activity_id
and book.rn=1
end 
GO
