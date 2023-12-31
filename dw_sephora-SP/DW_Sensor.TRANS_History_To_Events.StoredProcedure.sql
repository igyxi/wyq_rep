/****** Object:  StoredProcedure [DW_Sensor].[TRANS_History_To_Events]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[TRANS_History_To_Events] @dt [VARCHAR](10) AS
BEGIN
delete from [STG_Sensor].[Events] where dt = @dt;
insert into [STG_Sensor].[Events]
select 
    event,
    case when isnumeric(user_id)=1 and CHARINDEX('.',user_id)=0 then cast(user_id as bigint) 
         when isnumeric(user_id)=1 and CHARINDEX('.',user_id)>0 then cast(substring(user_id,1,CHARINDEX('.',user_id)-1) as bigint)
    else null end as user_id,
    distinct_id,
    cast(substring(date,1,10) as date) as date,
    cast(substring(time,1,23) as datetime) as time,
    ss_device_id,
    ss_os_version,
    ss_carrier,
    ss_os,
    case when isnumeric(ss_is_first_day)=1 and CHARINDEX('.',ss_is_first_day)=0 then cast(ss_is_first_day as bigint) 
         when isnumeric(ss_is_first_day)=1 and CHARINDEX('.',ss_is_first_day)>0 then cast(substring(ss_is_first_day,1,CHARINDEX('.',ss_is_first_day)-1) as bigint)
    else null end as ss_is_first_day,
    case when isnumeric(ss_screen_height)=1 and CHARINDEX('.',ss_screen_height)=0 then cast(ss_screen_height as bigint) 
         when isnumeric(ss_screen_height)=1 and CHARINDEX('.',ss_screen_height)>0 then cast(substring(ss_screen_height,1,CHARINDEX('.',ss_screen_height)-1) as bigint)
    else null end as ss_screen_height,
    case when isnumeric(ss_screen_width)=1 and CHARINDEX('.',ss_screen_width)=0 then cast(ss_screen_width as bigint) 
         when isnumeric(ss_screen_width)=1 and CHARINDEX('.',ss_screen_width)>0 then cast(substring(ss_screen_width,1,CHARINDEX('.',ss_screen_width)-1) as bigint)
    else null end as ss_screen_width,
    ss_model,
    ss_network_type,
    ss_lib,
    ss_app_version,
    ss_manufacturer,
    case when isnumeric(ss_wifi)=1 and CHARINDEX('.',ss_wifi)=0 then cast(ss_wifi as bigint) 
         when isnumeric(ss_wifi)=1 and CHARINDEX('.',ss_wifi)>0 then cast(substring(ss_wifi,1,CHARINDEX('.',ss_wifi)-1) as bigint)
    else null end as ss_wifi,
    ss_lib_version,
    case when isnumeric(ss_is_first_time)=1 and CHARINDEX('.',ss_is_first_time)=0 then cast(ss_is_first_time as bigint) 
         when isnumeric(ss_is_first_time)=1 and CHARINDEX('.',ss_is_first_time)>0 then cast(substring(ss_is_first_time,1,CHARINDEX('.',ss_is_first_time)-1) as bigint)
    else null end as ss_is_first_time,
    case when isnumeric(ss_resume_from_background)=1 and CHARINDEX('.',ss_resume_from_background)=0 then cast(ss_resume_from_background as bigint) 
         when isnumeric(ss_resume_from_background)=1 and CHARINDEX('.',ss_resume_from_background)>0 then cast(substring(ss_resume_from_background,1,CHARINDEX('.',ss_resume_from_background)-1) as bigint)
    else null end as ss_resume_from_background,
    ss_ip,
    ss_city,
    ss_province,
    ss_country,
    ss_user_agent,
    ss_browser,
    ss_screen_name,
    ss_title,
    ss_element_content,
    ss_element_type,
    case when isnumeric(ss_event_duration)=1 and CHARINDEX('.',ss_event_duration)=0 then cast(ss_event_duration as bigint) 
         when isnumeric(ss_event_duration)=1 and CHARINDEX('.',ss_event_duration)>0 then cast(substring(ss_event_duration,1,CHARINDEX('.',ss_event_duration)-1) as bigint)
    else null end as ss_event_duration,
    ss_track_signup_original_id,
    ss_element_id,
    ss_element_position,
    ss_utm_source,
    ss_utm_campaign,
    ss_latest_traffic_source_type,
    ss_latest_referrer,
    ss_latest_referrer_host,
    ss_latest_search_keyword,
    ss_referrer,
    ss_referrer_host,
    ss_url,
    ss_url_path,
    ss_browser_version,
    ss_element_class_name,
    ss_element_target_url,
    ss_element_selector,
    current_url,
    case when isnumeric(ss_viewport_position)=1 and CHARINDEX('.',ss_viewport_position)=0 then cast(ss_viewport_position as bigint) 
         when isnumeric(ss_viewport_position)=1 and CHARINDEX('.',ss_viewport_position)>0 then cast(substring(ss_viewport_position,1,CHARINDEX('.',ss_viewport_position)-1) as bigint)
    else null end as ss_viewport_position,    
    case when isnumeric(ss_viewport_height)=1 and CHARINDEX('.',ss_viewport_height)=0 then cast(ss_viewport_height as bigint) 
         when isnumeric(ss_viewport_height)=1 and CHARINDEX('.',ss_viewport_height)>0 then cast(substring(ss_viewport_height,1,CHARINDEX('.',ss_viewport_height)-1) as bigint)
    else null end as ss_viewport_height,    
    case when isnumeric(ss_viewport_width)=1 and CHARINDEX('.',ss_viewport_width)=0 then cast(ss_viewport_width as bigint) 
         when isnumeric(ss_viewport_width)=1 and CHARINDEX('.',ss_viewport_width)>0 then cast(substring(ss_viewport_width,1,CHARINDEX('.',ss_viewport_width)-1) as bigint)
    else null end as ss_viewport_width,
    login_channel,
    case when isnumeric(if_success)=1 and CHARINDEX('.',if_success)=0 then cast(if_success as bigint) 
         when isnumeric(if_success)=1 and CHARINDEX('.',if_success)>0 then cast(substring(if_success,1,CHARINDEX('.',if_success)-1) as bigint)
    else null end as if_success,
    failure_reason,
    sign_up_method,
    case when isnumeric(is_member_from_store)=1 and CHARINDEX('.',is_member_from_store)=0 then cast(is_member_from_store as bigint) 
         when isnumeric(is_member_from_store)=1 and CHARINDEX('.',is_member_from_store)>0 then cast(substring(is_member_from_store,1,CHARINDEX('.',is_member_from_store)-1) as bigint)
    else null end as is_member_from_store,
    case when isnumeric(previous_page_type)=1 and CHARINDEX('.',previous_page_type)=0 then cast(previous_page_type as bigint) 
         when isnumeric(previous_page_type)=1 and CHARINDEX('.',previous_page_type)>0 then cast(substring(previous_page_type,1,CHARINDEX('.',previous_page_type)-1) as bigint)
    else null end as previous_page_type,
    loginchannel,
    vip_card,
    vip_card_type,
    case when isnumeric(if_choose_existing_vip_card)=1 and CHARINDEX('.',if_choose_existing_vip_card)=0 then cast(if_choose_existing_vip_card as bigint) 
         when isnumeric(if_choose_existing_vip_card)=1 and CHARINDEX('.',if_choose_existing_vip_card)>0 then cast(substring(if_choose_existing_vip_card,1,CHARINDEX('.',if_choose_existing_vip_card)-1) as bigint)
    else null end as if_choose_existing_vip_card,
    ss_element_name,
    ss_latest_utm_source,
    ss_latest_utm_medium,
    ss_latest_utm_campaign,
    ss_latest_utm_content,
    ss_bot_name,
    ss_latest_utm_term,
    case when isnumeric(vip_is_new_pinkcard)=1 and CHARINDEX('.',vip_is_new_pinkcard)=0 then cast(vip_is_new_pinkcard as bigint) 
         when isnumeric(vip_is_new_pinkcard)=1 and CHARINDEX('.',vip_is_new_pinkcard)>0 then cast(substring(vip_is_new_pinkcard,1,CHARINDEX('.',vip_is_new_pinkcard)-1) as bigint)
    else null end as vip_is_new_pinkcard,
    ss_utm_medium,
    previous_page_type_new,
    banner_type,
    banner_content,
    banner_current_url,
    banner_current_page_type,
    banner_belong_area,
    banner_to_url,
    banner_to_page_type,
    banner_ranking,
    campaign_code,
    ss_utm_content,
    ss_utm_term,
    referrer,
    a,
    key_word_tpye,
    key_word_tpye_details,
    case when isnumeric(has_result)=1 and CHARINDEX('.',has_result)=0 then cast(has_result as bigint) 
         when isnumeric(has_result)=1 and CHARINDEX('.',has_result)>0 then cast(substring(has_result,1,CHARINDEX('.',has_result)-1) as bigint)
    else null end as has_result,
    commodity_sku,
    op_code,
    color,
    platform_type,
    system_type,
    orderid,
    userid,
    case when isnumeric(ss_kafka_offset)=1 and CHARINDEX('.',ss_kafka_offset)=0 then cast(ss_kafka_offset as bigint) 
         when isnumeric(ss_kafka_offset)=1 and CHARINDEX('.',ss_kafka_offset)>0 then cast(substring(ss_kafka_offset,1,CHARINDEX('.',ss_kafka_offset)-1) as bigint)
    else null end as ss_kafka_offset,
    case when isnumeric(detail_id)=1 and CHARINDEX('.',detail_id)=0 then cast(detail_id as bigint) 
         when isnumeric(detail_id)=1 and CHARINDEX('.',detail_id)>0 then cast(substring(detail_id,1,CHARINDEX('.',detail_id)-1) as bigint)
    else null end as detail_id,
    ss_latest_scene,
    ss_scene,
    case when isnumeric(ss_share_depth)=1 and CHARINDEX('.',ss_share_depth)=0 then cast(ss_share_depth as bigint) 
         when isnumeric(ss_share_depth)=1 and CHARINDEX('.',ss_share_depth)>0 then cast(substring(ss_share_depth,1,CHARINDEX('.',ss_share_depth)-1) as bigint)
    else null end as ss_share_depth,
    undefined,
    ss_url_query,
    ss_share_distinct_id,
    ss_share_url_path,
    activityid,
    case when isnumeric(if_share)=1 and CHARINDEX('.',if_share)=0 then cast(if_share as bigint) 
         when isnumeric(if_share)=1 and CHARINDEX('.',if_share)>0 then cast(substring(if_share,1,CHARINDEX('.',if_share)-1) as bigint)
    else null end as if_share,
    case when isnumeric(is_first_login)=1 and CHARINDEX('.',is_first_login)=0 then cast(is_first_login as bigint) 
         when isnumeric(is_first_login)=1 and CHARINDEX('.',is_first_login)>0 then cast(substring(is_first_login,1,CHARINDEX('.',is_first_login)-1) as bigint)
    else null end as is_first_login,
    environment_type,
    app_crashed_reason,
    key_word_type,
    key_word_type_details,
    _latest_cmpid,
    beauty_article_current_page,
    beauty_article_tag,
    beauty_author_name,
    beauty_author_id,
    beauty_article_id,
    productid,
    case when isnumeric(enviorment_type)=1 and CHARINDEX('.',enviorment_type)=0 then cast(enviorment_type as bigint) 
         when isnumeric(enviorment_type)=1 and CHARINDEX('.',enviorment_type)>0 then cast(substring(enviorment_type,1,CHARINDEX('.',enviorment_type)-1) as bigint)
    else null end as enviorment_type,
    userno,
    beauty_article_product_id,
    beauty_function_current_position,
    beauty_function_operation_type,
    share_method,
    beauty_article_product_name,
    beauty_clicked_product_name,
    beauty_clicked_product_sku,
    beauty_article_title,
    ss_app_state,
    utm_content,
    ss_short_url_key,
    ss_short_url_target,
    ss_utm_matching_type,
    case when isnumeric(if_a)=1 and CHARINDEX('.',if_a)=0 then cast(if_a as bigint) 
         when isnumeric(if_a)=1 and CHARINDEX('.',if_a)>0 then cast(substring(if_a,1,CHARINDEX('.',if_a)-1) as bigint)
    else null end as if_a,
    button_name,
    page_type_detail,
    _id,
    page_type,
    channelid,
    case when isnumeric(ss_receive_time)=1 and CHARINDEX('.',ss_receive_time)=0 then cast(ss_receive_time as bigint) 
         when isnumeric(ss_receive_time)=1 and CHARINDEX('.',ss_receive_time)>0 then cast(substring(ss_receive_time,1,CHARINDEX('.',ss_receive_time)-1) as bigint)
    else null end as ss_receive_time,
    ss_matched_key,
    log_time_millis,
    key_words,
    brand_id,
    categoryid,
    branden,
    brandstoryen,
    campaign_to_pagetype,
    productcn,
    page_detail,
    brand_cn,
    level,
    message,
    case when isnumeric(use_client_time)=1 and CHARINDEX('.',use_client_time)=0 then cast(use_client_time as bigint) 
         when isnumeric(use_client_time)=1 and CHARINDEX('.',use_client_time)>0 then cast(substring(use_client_time,1,CHARINDEX('.',use_client_time)-1) as bigint)
    else null end as use_client_time,
    position,
    ss_browser_language,
    placeholder,
    timestring,
    case when isnumeric(sensortime)=1 and CHARINDEX('.',sensortime)=0 then cast(sensortime as bigint) 
         when isnumeric(sensortime)=1 and CHARINDEX('.',sensortime)>0 then cast(substring(sensortime,1,CHARINDEX('.',sensortime)-1) as bigint)
    else null end as sensortime,
    [key],
    case when isnumeric(activity_status)=1 and CHARINDEX('.',activity_status)=0 then cast(activity_status as bigint) 
         when isnumeric(activity_status)=1 and CHARINDEX('.',activity_status)>0 then cast(substring(activity_status,1,CHARINDEX('.',activity_status)-1) as bigint)
    else null end as activity_status,
    url_detail,
    compaign_code,
    case when isnumeric(activityclick)=1 and CHARINDEX('.',activityclick)=0 then cast(activityclick as bigint) 
         when isnumeric(activityclick)=1 and CHARINDEX('.',activityclick)>0 then cast(substring(activityclick,1,CHARINDEX('.',activityclick)-1) as bigint)
    else null end as activityclick,
    utm_source_detail,
    utm_medium_detail,
    utm_campaign_detail,
    utm_content_detail,
    utm_term_detail,
    ref_page_type,
    ref_page_type_detail,
    utm_cource_detail,
    topic_name,
    topic_click_position,
    campaign_type,
    msg_status,
    msg_type,
    live_id as Live_id,
    utm_id_detail,
    beauty_signin_entrance,
    sku_code,
    source_op_code,
    sharechannel,
    utm_seb_detail,
    sep_utm_campaign,
    sep_utm_source,
    sep_utm_medium,
    sep_utm_content,
    sep_utm_term,
    namevaluepairs,
    case when isnumeric(ss_timezone_offset)=1 and CHARINDEX('.',ss_timezone_offset)=0 then cast(ss_timezone_offset as bigint) 
         when isnumeric(ss_timezone_offset)=1 and CHARINDEX('.',ss_timezone_offset)>0 then cast(substring(ss_timezone_offset,1,CHARINDEX('.',ss_timezone_offset)-1) as bigint)
    else null end as ss_timezone_offset,
    couponid,
    ss_url_host,
    ss_app_id,
    ss_element_path,
    ss_deeplink_url,
    test_version,
    roomid,
    click_openid,
    success_status,
    room_id,
    share_openid,
    ss_hdfs_import_batch_name,
    ss_share_method,
    ss_latest_share_distinct_id,
    case when isnumeric(ss_latest_share_depth)=1 and CHARINDEX('.',ss_latest_share_depth)=0 then cast(ss_latest_share_depth as bigint) 
         when isnumeric(ss_latest_share_depth)=1 and CHARINDEX('.',ss_latest_share_depth)>0 then cast(substring(ss_latest_share_depth,1,CHARINDEX('.',ss_latest_share_depth)-1) as bigint)
    else null end as ss_latest_share_depth,
    ss_latest_share_url_path,
    ss_latest_share_method,
    ss_app_name,
    utm_acid_detail,
    url_path,
    url_query,
    ext_product_name,
    ext_brand_type,
    ext_product_tag,
    case when isnumeric(ext_product_price)=1 and CHARINDEX('.',ext_product_price)=0 then cast(ext_product_price as bigint) 
         when isnumeric(ext_product_price)=1 and CHARINDEX('.',ext_product_price)>0 then cast(substring(ext_product_price,1,CHARINDEX('.',ext_product_price)-1) as bigint)
    else null end as ext_product_price,
    ext_product_type,
    ext_order_channel,
    ext_order_platform,
    ext_order_status,
    case when isnumeric(ext_order_valid)=1 and CHARINDEX('.',ext_order_valid)=0 then cast(ext_order_valid as bigint) 
         when isnumeric(ext_order_valid)=1 and CHARINDEX('.',ext_order_valid)>0 then cast(substring(ext_order_valid,1,CHARINDEX('.',ext_order_valid)-1) as bigint)
    else null end as ext_order_valid,
    ext_order_type,
    ext_delivery_addr_country,
    ext_delivery_addr_province,
    ext_delivery_addr_city,
    ext_payment_mode,
    case when isnumeric(ext_gift_card_used)=1 and CHARINDEX('.',ext_gift_card_used)=0 then cast(ext_gift_card_used as bigint) 
         when isnumeric(ext_gift_card_used)=1 and CHARINDEX('.',ext_gift_card_used)>0 then cast(substring(ext_gift_card_used,1,CHARINDEX('.',ext_gift_card_used)-1) as bigint)
    else null end as ext_gift_card_used,
    case when isnumeric(ext_mem_card_used)=1 and CHARINDEX('.',ext_mem_card_used)=0 then cast(ext_mem_card_used as bigint) 
         when isnumeric(ext_mem_card_used)=1 and CHARINDEX('.',ext_mem_card_used)>0 then cast(substring(ext_mem_card_used,1,CHARINDEX('.',ext_mem_card_used)-1) as bigint)
    else null end as ext_mem_card_used,
    ext_mem_card_num,
    ext_mem_card_type,
    ext_coupon_name,
    ext_coupon_type,
    case when isnumeric(ext_coupon_num)=1 and CHARINDEX('.',ext_coupon_num)=0 then cast(ext_coupon_num as bigint) 
         when isnumeric(ext_coupon_num)=1 and CHARINDEX('.',ext_coupon_num)>0 then cast(substring(ext_coupon_num,1,CHARINDEX('.',ext_coupon_num)-1) as bigint)
    else null end as ext_coupon_num,
    ext_coupon_code,
    case when isnumeric(ext_order_amount)=1 and CHARINDEX('.',ext_order_amount)=0 then cast(ext_order_amount as bigint) 
         when isnumeric(ext_order_amount)=1 and CHARINDEX('.',ext_order_amount)>0 then cast(substring(ext_order_amount,1,CHARINDEX('.',ext_order_amount)-1) as bigint)
    else null end as ext_order_amount,
    case when isnumeric(ext_paid_amount)=1 and CHARINDEX('.',ext_paid_amount)=0 then cast(ext_paid_amount as bigint) 
         when isnumeric(ext_paid_amount)=1 and CHARINDEX('.',ext_paid_amount)>0 then cast(substring(ext_paid_amount,1,CHARINDEX('.',ext_paid_amount)-1) as bigint)
    else null end as ext_paid_amount,
    ext_product_brand_name,
    ext_sku_name,
    ext_sku_tag,
    case when isnumeric(ext_sku_price)=1 and CHARINDEX('.',ext_sku_price)=0 then cast(ext_sku_price as bigint) 
         when isnumeric(ext_sku_price)=1 and CHARINDEX('.',ext_sku_price)>0 then cast(substring(ext_sku_price,1,CHARINDEX('.',ext_sku_price)-1) as bigint)
    else null end as ext_sku_price,
    case when isnumeric(ext_order_time)=1 and CHARINDEX('.',ext_order_time)=0 then cast(ext_order_time as bigint) 
         when isnumeric(ext_order_time)=1 and CHARINDEX('.',ext_order_time)>0 then cast(substring(ext_order_time,1,CHARINDEX('.',ext_order_time)-1) as bigint)
    else null end as ext_order_time,
    case when isnumeric(ext_payment_time)=1 and CHARINDEX('.',ext_payment_time)=0 then cast(ext_payment_time as bigint) 
         when isnumeric(ext_payment_time)=1 and CHARINDEX('.',ext_payment_time)>0 then cast(substring(ext_payment_time,1,CHARINDEX('.',ext_payment_time)-1) as bigint)
    else null end as ext_payment_time,
    new_key_word_type_detail,
    new_key_word_type,
    versionid,
    toprankinglist_name,
    segment_id,
    insert_timestamp,
    dt as dt
from 
    [STG_Sensor].[Events_History]
where 
    dt = @dt;
END

GO
