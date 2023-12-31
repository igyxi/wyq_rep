/****** Object:  StoredProcedure [DWD].[SP_Fact_Event]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Event] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       wangzhichun        Initial Version
-- 2022-02-11       tali           change the source value
-- ========================================================================================
delete from DWD.Fact_Event where dt = @dt;
insert into DWD.Fact_Event
select 
	event
	,user_id
	,distinct_id
	,date
	,time
	,ss_device_id as device_id
	,ss_os_version as os_version
	,ss_carrier as carrier
	,ss_os as os
	,ss_model as model
	,ss_network_type as network_type
	,ss_app_version as app_version
	,ss_is_first_time as is_first_time
	,ss_city as city
	,ss_province as province
	,ss_country as country
	,ss_browser as browser
	,ss_title as title
	,ss_element_content as element_content
	,ss_utm_source as utm_source
	,ss_utm_campaign as utm_campaign
	,ss_latest_traffic_source_type as latest_traffic_source_type
	,ss_latest_referrer as latest_referrer
	,ss_latest_referrer_host as latest_referrer_host
	,ss_latest_search_keyword as latest_search_keyword
	,ss_referrer as ss_referrer
	,ss_referrer_host as referrer_host
	,ss_url as url
	,ss_url_path as url_path
	,current_url 
	,vip_card
	,vip_card_type
	,ss_latest_utm_source as latest_utm_source
	,ss_latest_utm_medium as latest_utm_medium
	,ss_latest_utm_campaign as latest_utm_campaign
	,ss_latest_utm_content as latest_utm_content
	,ss_latest_utm_term as latest_utm_term
	,ss_utm_medium as utm_medium
	,previous_page_type_new
	,ss_utm_content as utm_content
	,ss_utm_term as utm_term
	,referrer 
	,ss_latest_scene as latest_scene 
	,ss_scene as scene
	,ss_share_depth as share_depth
	,ss_share_distinct_id as share_distinct_id
	,ss_share_url_path as share_url_path
	,ss_app_state as app_state
	,ss_short_url_key as short_url_key
	,ss_short_url_target as short_url_target
	,ss_utm_matching_type as utm_matching_type
	,ss_receive_time as receive_time
	,ss_matched_key as matched_key
	,ref_page_type
	,ref_page_type_detail
	,ss_timezone_offset as _timezone_offset
	,ss_app_id as _app_id
	,ss_element_path as _element_path
	,ss_deeplink_url as _deeplink_url
	,ss_share_method as _share_method
	,ss_latest_share_distinct_id as _latest_share_distinct_id
	,ss_latest_share_depth as _latest_share_depth
	,ss_latest_share_url_path as _latest_share_url_path
	,ss_latest_share_method as _latest_share_method
	,ss_app_name as _app_name
	,'SHENCE' as source
	,current_timestamp as insert_timestamp
    ,@dt as dt
from 
    [STG_Sensor].[Events]
where dt=@dt;
END


GO
