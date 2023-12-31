/****** Object:  StoredProcedure [STG_Activity].[TRANS_Gift_Event]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Activity].[TRANS_Gift_Event] @dt [varchar](10) AS
BEGIN
truncate table STG_Activity.Gift_Event ;
insert into STG_Activity.Gift_Event
select 
    id,
    case when trim(name) in ('null','') then null else  trim(name) end as name,
    case when trim(event_type) in ('null','') then null else  trim(event_type) end as event_type,
    case when trim(apply_group) in ('null','') then null else  trim(apply_group) end as apply_group,
    case when trim(partner_group) in ('null','') then null else  trim(partner_group) end as partner_group,
    case when trim(channel) in ('null','') then null else  trim(channel) end as channel,
    start_time,
    end_time,
    case when trim(status) in ('null','') then null else  trim(status) end as status,
    apply_count,
    per_num,
    case when trim(backgroud_url) in ('null','') then null else  trim(backgroud_url) end as backgroud_url,
    case when trim(ad_txt) in ('null','') then null else  trim(ad_txt) end as ad_txt,
    show_partner_num,
    need_partner_num,
    leaderboard_num,
    case when trim(guide_image) in ('null','') then null else  trim(guide_image) end as guide_image,
    case when trim(share_method) in ('null','') then null else  trim(share_method) end as share_method,
    case when trim(share_image) in ('null','') then null else  trim(share_image) end as share_image,
    case when trim(share_background_image) in ('null','') then null else  trim(share_background_image) end as share_background_image,
    case when trim(share_image_main_title) in ('null','') then null else  trim(share_image_main_title) end as share_image_main_title,
    case when trim(share_image_sub_title) in ('null','') then null else  trim(share_image_sub_title) end as share_image_sub_title,
    case when trim(apply_model) in ('null','') then null else  trim(apply_model) end as apply_model,
    case when trim(apply_background_image) in ('null','') then null else  trim(apply_background_image) end as apply_background_image,
    case when trim(apply_title) in ('null','') then null else  trim(apply_title) end as apply_title,
    offline_event_id,
    case when trim(share_card_image) in ('null','') then null else  trim(share_card_image) end as share_card_image,
    case when trim(share_card_title) in ('null','') then null else  trim(share_card_title) end as share_card_title,
    case when trim(can_not_apply_button_txt) in ('null','') then null else  trim(can_not_apply_button_txt) end as can_not_apply_button_txt,
    case when trim(can_apply_button_txt) in ('null','') then null else  trim(can_apply_button_txt) end as can_apply_button_txt,
    case when trim(assistance_button_txt) in ('null','') then null else  trim(assistance_button_txt) end as assistance_button_txt,
    case when trim(assistance_rank_button_txt) in ('null','') then null else  trim(assistance_rank_button_txt) end as assistance_rank_button_txt,
    subscription_switch,
    case when trim(create_user) in ('null','') then null else  trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else  trim(update_user) end as update_user,
    create_time,
    update_time,
    case when trim(message_config) in ('null','') then null else  trim(message_config) end as message_config,
    case when trim(proccess) in ('null','') then null else  trim(proccess) end as proccess,
    white,
    times_of_one_period,
    case when trim(wx_follow_guide_images) in ('null','') then null else  trim(wx_follow_guide_images) end as wx_follow_guide_images,
    partner_times,
    shelf_status,
    case when trim(brand_image) in ('null','') then null else  trim(brand_image) end as brand_image,
    case when trim(description_text) in ('null','') then null else  trim(description_text) end as description_text,
    case when trim(forward_url) in ('null','') then null else  trim(forward_url) end as forward_url,
    is_delete,
    gift_finish_status,
    case when trim(app_forward_url) in ('null','') then null else  trim(app_forward_url) end as app_forward_url,
    case when trim(use_report) in ('null','') then null else  trim(use_report) end as use_report,
    case when trim(stock_id) in ('null','') then null else  trim(stock_id) end as stock_id,
    stop_send_limit,
    case when trim(partner_tags) in ('null','') then null else  trim(partner_tags) end as partner_tags,
    case when trim(partner_fail_text) in ('null','') then null else  trim(partner_fail_text) end as partner_fail_text,
    rank_prize_top_num,
    current_timestamp as insert_timestamp
from 
    ODS_Activity.Gift_Event
where dt = @dt
END

GO
