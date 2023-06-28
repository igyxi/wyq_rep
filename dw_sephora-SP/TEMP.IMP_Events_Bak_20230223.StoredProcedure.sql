/****** Object:  StoredProcedure [TEMP].[IMP_Events_Bak_20230223]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[IMP_Events_Bak_20230223] @dt [VARCHAR](10) AS 
BEGIN
delete from [ODS_Sensor].[Events_Bak_20230223] where left(dt, 7) = left(@dt, 7);
insert into [ODS_Sensor].[Events_Bak_20230223]
select
    event,
    user_id,
    distinct_id,
    date,
    time,
    ss_device_id,
    ss_os_version,
    ss_carrier,
    ss_os,
    ss_is_first_day,
    ss_screen_height,
    ss_screen_width,
    ss_model,
    ss_network_type,
    ss_lib,
    ss_app_version,
    ss_manufacturer,
    ss_wifi,
    ss_lib_version,
    ss_is_first_time,
    ss_resume_from_background,
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
    ss_event_duration,
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
    ss_viewport_position,
    ss_viewport_height,
    ss_viewport_width,
    login_channel,
    if_success,
    failure_reason,
    sign_up_method,
    is_member_from_store,
    previous_page_type,
    loginchannel,
    vip_card,
    vip_card_type,
    if_choose_existing_vip_card,
    ss_element_name,
    ss_latest_utm_source,
    ss_latest_utm_medium,
    ss_latest_utm_campaign,
    ss_latest_utm_content,
    ss_bot_name,
    ss_latest_utm_term,
    vip_is_new_pinkcard,
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
    has_result,
    commodity_sku,
    op_code,
    color,
    platform_type,
    system_type,
    orderid,
    userid,
    ss_kafka_offset,
    detail_id,
    ss_latest_scene,
    ss_scene,
    ss_share_depth,
    undefined,
    ss_url_query,
    ss_share_distinct_id,
    ss_share_url_path,
    activityid,
    if_share,
    is_first_login,
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
    enviorment_type,
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
    if_a,
    button_name,
    page_type_detail,
    _id,
    page_type,
    channelid,
    ss_receive_time,
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
    use_client_time,
    position,
    ss_browser_language,
    placeholder,
    timestring,
    sensortime,
    [key],
    activity_status,
    url_detail,
    compaign_code,
    activityclick,
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
    Live_id,
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
    ss_timezone_offset,
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
    ss_latest_share_depth,
    ss_latest_share_url_path,
    ss_latest_share_method,
    ss_app_name,
    utm_acid_detail,
    url_path,
    url_query,
    ext_product_name,
    ext_brand_type,
    ext_product_tag,
    ext_product_price,
    ext_product_type,
    ext_order_channel,
    ext_order_platform,
    ext_order_status,
    ext_order_valid,
    ext_order_type,
    ext_delivery_addr_country,
    ext_delivery_addr_province,
    ext_delivery_addr_city,
    ext_payment_mode,
    ext_gift_card_used,
    ext_mem_card_used,
    ext_mem_card_num,
    ext_mem_card_type,
    ext_coupon_name,
    ext_coupon_type,
    ext_coupon_num,
    ext_coupon_code,
    ext_order_amount,
    ext_paid_amount,
    ext_product_brand_name,
    ext_sku_name,
    ext_sku_tag,
    ext_sku_price,
    ext_order_time,
    ext_payment_time,
    new_key_word_type_detail,
    new_key_word_type,
    versionid,
    toprankinglist_name,
    segment_id,
    dt,
    adhocExperiments,
    page_id,
    action_id,
    adhoc_experiments,
    adhocExperimentsNew,
    baaccount,
    storecode,
    totalamount,
    virtual_key_word,
    virtual_key_word_type,
    virtual_key_word_type_detail,
    virtual_order_price,
    virtual_totalamount
from 
    [ODS_Sensor].[Events]
where left(dt, 7) = left(@dt, 7)
END

GO
