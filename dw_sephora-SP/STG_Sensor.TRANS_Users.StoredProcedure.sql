/****** Object:  StoredProcedure [STG_Sensor].[TRANS_Users]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Sensor].[TRANS_Users] AS
BEGIN
truncate table STG_Sensor.Users;
insert into STG_Sensor.Users
select 
    id,
    case when trim(lower(first_id)) in ('null', '') then null else trim(first_id) end as first_id,
    case when trim(lower(second_id)) in ('null', '') then null else trim(second_id) end as second_id,
    ss_first_visit_time,
    case when trim(lower(ss_utm_source)) in ('null', '') then null else trim(ss_utm_source) end as ss_utm_source,
    case when trim(lower(ss_utm_campaign)) in ('null', '') then null else trim(ss_utm_campaign) end as ss_utm_campaign,
    case when trim(lower(ss_first_referrer)) in ('null', '') then null else trim(ss_first_referrer) end as ss_first_referrer,
    case when trim(lower(ss_first_browser_language)) in ('null', '') then null else trim(ss_first_browser_language) end as ss_first_browser_language,
    case when trim(lower(ss_first_browser_charset)) in ('null', '') then null else trim(ss_first_browser_charset) end as ss_first_browser_charset,
    case when trim(lower(ss_first_referrer_host)) in ('null', '') then null else trim(ss_first_referrer_host) end as ss_first_referrer_host,
    case when trim(lower(ss_first_traffic_source_type)) in ('null', '') then null else trim(ss_first_traffic_source_type) end as ss_first_traffic_source_type,
    case when trim(lower(ss_first_search_keyword)) in ('null', '') then null else trim(ss_first_search_keyword) end as ss_first_search_keyword,
    case when trim(lower(ss_utm_medium)) in ('null', '') then null else trim(ss_utm_medium) end as ss_utm_medium,
    case when trim(lower(ss_utm_content)) in ('null', '') then null else trim(ss_utm_content) end as ss_utm_content,
    case when trim(lower(gender)) in ('null', '') then null else trim(gender) end as gender,
    null as phonenumber,
    [like],
    issuearticle,
    numberofcomment,
    numberofcommentreceived,
    likereceived,
    shoppingcredit,
    case when trim(lower(vip_card)) in ('null', '') then null else trim(vip_card) end as vip_card,
    case when trim(lower(vip_card_type)) in ('null', '') then null else trim(vip_card_type) end as vip_card_type,
    yanhuo,
    numofcoupon,
    null as email,
    case when trim(lower(province)) in ('null', '') then null else trim(province) end as province,
    yearofbirth,
    case when trim(lower(city)) in ('null', '') then null else trim(city) end as city,
    birthday,
    lastordertime,
    numofcomment,
    numofcommentreceived,
    case when trim(lower(ss_utm_term)) in ('null', '') then null else trim(ss_utm_term) end as ss_utm_term,
    case when trim(lower(birthdaynew)) in ('null', '') then null else trim(birthdaynew) end as birthdaynew,
    userid,
    case when trim(lower(ss_utm_matching_type)) in ('null', '') then null else trim(ss_utm_matching_type) end as ss_utm_matching_type,
    case when trim(lower(channelid)) in ('null', '') then null else trim(channelid) end as channelid,
    case when trim(lower(ss_matched_key)) in ('null', '') then null else trim(ss_matched_key) end as ss_matched_key,
    case when trim(lower(log_time_millis)) in ('null', '') then null else trim(log_time_millis) end as log_time_millis,
    case when trim(lower(idfa)) in ('null', '') then null else trim(idfa) end as idfa,
    case when trim(lower(vip_card_no)) in ('null', '') then null else trim(vip_card_no) end as vip_card_no,
    ss_update_time,
    case when trim(lower(androidid)) in ('null', '') then null else trim(androidid) end as androidid,
    case when trim(lower(openid)) in ('null', '') then null else trim(openid) end as openid,
    case when trim(lower(unionid)) in ('null', '') then null else trim(unionid) end as unionid,
    case when trim(lower(imei)) in ('null', '') then null else trim(imei) end as imei,
    case when trim(lower(oaid)) in ('null', '') then null else trim(oaid) end as oaid,
    case when trim(lower(adhoc_clientid)) in ('null', '') then null else trim(adhoc_clientid) end as adhoc_clientid,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Sensor.Users 
) t
where rownum = 1;
update statistics STG_Sensor.Users;
END
GO
