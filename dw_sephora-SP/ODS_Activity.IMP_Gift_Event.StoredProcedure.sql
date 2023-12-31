/****** Object:  StoredProcedure [ODS_Activity].[IMP_Gift_Event]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Activity].[IMP_Gift_Event] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Activity.Gift_Event where dt = @dt;
insert into ODS_Activity.Gift_Event
select 
    a.id,
	name,
	event_type,
	apply_group,
	partner_group,
	channel,
	start_time,
	end_time,
	status,
	apply_count,
	per_num,
	backgroud_url,
	ad_txt,
	show_partner_num,
	need_partner_num,
	leaderboard_num,
	guide_image,
	share_method,
	share_image,
	share_background_image,
	share_image_main_title,
	share_image_sub_title,
	apply_model,
	apply_background_image,
	apply_title,
	offline_event_id,
	share_card_image,
	share_card_title,
	can_not_apply_button_txt,
	can_apply_button_txt,
	assistance_button_txt,
	assistance_rank_button_txt,
	subscription_switch,
	create_user,
	update_user,
	create_time,
	update_time,
	message_config,
	proccess,
	white,
	times_of_one_period,
	wx_follow_guide_images,
	partner_times,
	shelf_status,
	brand_image,
	description_text,
	forward_url,
	is_delete,
	gift_finish_status,
	app_forward_url,
	use_report,
	stock_id,
	stop_send_limit,
    @dt as dt
from 
(
    select * from ODS_Activity.Gift_Event where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_Activity.WRK_Gift_Event
) b
on a.id = b.id
where b.id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_Activity.WRK_Gift_Event;
delete from ODS_Activity.Gift_Event where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
