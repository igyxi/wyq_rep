/****** Object:  StoredProcedure [TEMP].[create_ODS_Events_20220211]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[create_ODS_Events_20220211] AS
begin

CREATE TABLE ODS_Sensor.Events_20220211 
WITH
(
 DISTRIBUTION = hash(event),
 CLUSTERED INDEX
 (
  [date] ASC
 ),
 PARTITION
 (
  [dt] RANGE FOR VALUES ()
 )
)
AS
select 
cast (event as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as event
,user_id
,cast (distinct_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as distinct_id
,date
,time
,cast (ss_device_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_device_id
,cast (ss_os_version as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_os_version
,cast (ss_carrier as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_carrier
,cast (ss_os as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_os
,ss_is_first_day
,ss_screen_height
,ss_screen_width
,cast (ss_model as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_model
,cast (ss_network_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_network_type
,cast (ss_lib as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_lib
,cast (ss_app_version as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_app_version
,cast (ss_manufacturer as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_manufacturer
,ss_wifi
,cast (ss_lib_version as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_lib_version
,ss_is_first_time
,ss_resume_from_background
,cast (ss_ip as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_ip
,cast (ss_city as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_city
,cast (ss_province as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_province
,cast (ss_country as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_country
,cast (ss_user_agent as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_user_agent
,cast (ss_browser as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_browser
,cast (ss_screen_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_screen_name
,cast (ss_title as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_title
,cast (ss_element_content as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_content
,cast (ss_element_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_type
,ss_event_duration
,cast (ss_track_signup_original_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_track_signup_original_id
,cast (ss_element_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_id
,cast (ss_element_position as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_position
,cast (ss_utm_source as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_utm_source
,cast (ss_utm_campaign as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_utm_campaign
,cast (ss_latest_traffic_source_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_traffic_source_type
,cast (ss_latest_referrer as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_referrer
,cast (ss_latest_referrer_host as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_referrer_host
,cast (ss_latest_search_keyword as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_search_keyword
,cast (ss_referrer as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_referrer
,cast (ss_referrer_host as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_referrer_host
,cast (ss_url as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_url
,cast (ss_url_path as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_url_path
,cast (ss_browser_version as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_browser_version
,cast (ss_element_class_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_class_name
,cast (ss_element_target_url as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_target_url
,cast (ss_element_selector as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_selector
,cast (current_url as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as current_url
,ss_viewport_position
,ss_viewport_height
,ss_viewport_width
,cast (login_channel as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as login_channel
,if_success
,cast (failure_reason as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as failure_reason
,cast (sign_up_method as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as sign_up_method
,is_member_from_store
,previous_page_type
,cast (loginchannel as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as loginchannel
,cast (vip_card as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as vip_card
,cast (vip_card_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as vip_card_type
,if_choose_existing_vip_card
,cast (ss_element_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_name
,cast (ss_latest_utm_source as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_utm_source
,cast (ss_latest_utm_medium as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_utm_medium
,cast (ss_latest_utm_campaign as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_utm_campaign
,cast (ss_latest_utm_content as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_utm_content
,cast (ss_bot_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_bot_name
,cast (ss_latest_utm_term as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_utm_term
,vip_is_new_pinkcard
,cast (ss_utm_medium as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_utm_medium
,cast (previous_page_type_new as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as previous_page_type_new
,cast (banner_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as banner_type
,cast (banner_content as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as banner_content
,cast (banner_current_url as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as banner_current_url
,cast (banner_current_page_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as banner_current_page_type
,cast (banner_belong_area as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as banner_belong_area
,cast (banner_to_url as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as banner_to_url
,cast (banner_to_page_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as banner_to_page_type
,cast (banner_ranking as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as banner_ranking
,cast (campaign_code as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as campaign_code
,cast (ss_utm_content as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_utm_content
,cast (ss_utm_term as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_utm_term
,cast (referrer as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as referrer
,cast (a as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as a
,cast (key_word_tpye as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as key_word_tpye
,cast (key_word_tpye_details as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as key_word_tpye_details
,has_result
,cast (commodity_sku as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as commodity_sku
,cast (op_code as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as op_code
,cast (color as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as color
,cast (platform_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as platform_type
,cast (system_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as system_type
,cast (orderid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as orderid
,cast (userid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as userid
,ss_kafka_offset
,detail_id
,cast (ss_latest_scene as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_scene
,cast (ss_scene as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_scene
,ss_share_depth
,cast (undefined as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as undefined
,cast (ss_url_query as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_url_query
,cast (ss_share_distinct_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_share_distinct_id
,cast (ss_share_url_path as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_share_url_path
,cast (activityid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as activityid
,if_share
,is_first_login
,cast (environment_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as environment_type
,cast (app_crashed_reason as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as app_crashed_reason
,cast (key_word_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as key_word_type
,cast (key_word_type_details as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as key_word_type_details
,cast (_latest_cmpid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as _latest_cmpid
,cast (beauty_article_current_page as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_article_current_page
,cast (beauty_article_tag as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_article_tag
,cast (beauty_author_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_author_name
,cast (beauty_author_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_author_id
,cast (beauty_article_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_article_id
,cast (productid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as productid
,enviorment_type
,cast (userno as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as userno
,cast (beauty_article_product_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_article_product_id
,cast (beauty_function_current_position as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_function_current_position
,cast (beauty_function_operation_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_function_operation_type
,cast (share_method as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as share_method
,cast (beauty_article_product_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_article_product_name
,cast (beauty_clicked_product_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_clicked_product_name
,cast (beauty_clicked_product_sku as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_clicked_product_sku
,cast (beauty_article_title as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_article_title
,cast (ss_app_state as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_app_state
,cast (utm_content as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_content
,cast (ss_short_url_key as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_short_url_key
,cast (ss_short_url_target as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_short_url_target
,cast (ss_utm_matching_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_utm_matching_type
,if_a
,cast (button_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as button_name
,cast (page_type_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as page_type_detail
,cast (_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as _id
,cast (page_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as page_type
,cast (channelid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as channelid
,ss_receive_time
,cast (ss_matched_key as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_matched_key
,cast (log_time_millis as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as log_time_millis
,cast (key_words as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as key_words
,cast (brand_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as brand_id
,cast (categoryid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as categoryid
,cast (branden as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as branden
,cast (brandstoryen as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as brandstoryen
,cast (campaign_to_pagetype as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as campaign_to_pagetype
,cast (productcn as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as productcn
,cast (page_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as page_detail
,cast (brand_cn as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as brand_cn
,cast (level as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as level
,cast (message as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as message
,use_client_time
,cast (position as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as position
,cast (ss_browser_language as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_browser_language
,cast (placeholder as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as placeholder
,cast (timestring as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as timestring
,sensortime
,cast ([key] as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as [key]
,activity_status
,cast (url_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as url_detail
,cast (compaign_code as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as compaign_code
,activityclick
,cast (utm_source_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_source_detail
,cast (utm_medium_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_medium_detail
,cast (utm_campaign_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_campaign_detail
,cast (utm_content_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_content_detail
,cast (utm_term_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_term_detail
,cast (ref_page_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ref_page_type
,cast (ref_page_type_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ref_page_type_detail
,cast (utm_cource_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_cource_detail
,cast (topic_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as topic_name
,cast (topic_click_position as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as topic_click_position
,cast (campaign_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as campaign_type
,cast (msg_status as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as msg_status
,cast (msg_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as msg_type
,cast (Live_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as Live_id
,cast (utm_id_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_id_detail
,cast (beauty_signin_entrance as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as beauty_signin_entrance
,cast (sku_code as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as sku_code
,cast (source_op_code as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as source_op_code
,cast (sharechannel as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as sharechannel
,cast (utm_seb_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_seb_detail
,cast (sep_utm_campaign as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as sep_utm_campaign
,cast (sep_utm_source as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as sep_utm_source
,cast (sep_utm_medium as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as sep_utm_medium
,cast (sep_utm_content as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as sep_utm_content
,cast (sep_utm_term as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as sep_utm_term
,cast (namevaluepairs as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as namevaluepairs
,ss_timezone_offset
,cast (couponid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as couponid
,cast (ss_url_host as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_url_host
,cast (ss_app_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_app_id
,cast (ss_element_path as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_element_path
,cast (ss_deeplink_url as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_deeplink_url
,cast (test_version as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as test_version
,cast (roomid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as roomid
,cast (click_openid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as click_openid
,cast (success_status as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as success_status
,cast (room_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as room_id
,cast (share_openid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as share_openid
,cast (ss_hdfs_import_batch_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_hdfs_import_batch_name
,cast (ss_share_method as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_share_method
,cast (ss_latest_share_distinct_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_share_distinct_id
,ss_latest_share_depth
,cast (ss_latest_share_url_path as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_share_url_path
,cast (ss_latest_share_method as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_latest_share_method
,cast (ss_app_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ss_app_name
,cast (utm_acid_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as utm_acid_detail
,cast (url_path as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as url_path
,cast (url_query as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as url_query
,cast (ext_product_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_product_name
,cast (ext_brand_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_brand_type
,cast (ext_product_tag as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_product_tag
,ext_product_price
,cast (ext_product_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_product_type
,cast (ext_order_channel as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_order_channel
,cast (ext_order_platform as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_order_platform
,cast (ext_order_status as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_order_status
,ext_order_valid
,cast (ext_order_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_order_type
,cast (ext_delivery_addr_country as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_delivery_addr_country
,cast (ext_delivery_addr_province as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_delivery_addr_province
,cast (ext_delivery_addr_city as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_delivery_addr_city
,cast (ext_payment_mode as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_payment_mode
,ext_gift_card_used
,ext_mem_card_used
,cast (ext_mem_card_num as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_mem_card_num
,cast (ext_mem_card_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_mem_card_type
,cast (ext_coupon_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_coupon_name
,cast (ext_coupon_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_coupon_type
,ext_coupon_num
,cast (ext_coupon_code as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_coupon_code
,ext_order_amount
,ext_paid_amount
,cast (ext_product_brand_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_product_brand_name
,cast (ext_sku_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_sku_name
,cast (ext_sku_tag as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as ext_sku_tag
,ext_sku_price
,ext_order_time
,ext_payment_time
,cast (new_key_word_type_detail as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as new_key_word_type_detail
,cast (new_key_word_type as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as new_key_word_type
,cast (versionid as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as versionid
,cast (toprankinglist_name as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as toprankinglist_name
,cast (segment_id as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as segment_id
,cast (dt as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as dt
,cast (adhocExperiments as nvarchar(4000)) collate SQL_Latin1_General_CP1_CI_AS as adhocExperiments
from 
    [ODS_Sensor].[Events] with (nolock);
    

end
GO
