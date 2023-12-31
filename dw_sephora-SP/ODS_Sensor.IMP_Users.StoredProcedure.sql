/****** Object:  StoredProcedure [ODS_Sensor].[IMP_Users]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Sensor].[IMP_Users] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Sensor.Users where dt = @dt;
insert into ODS_Sensor.Users
select 
    id,
    first_id,
    second_id,
    [$first_visit_time] as ss_first_visit_time,
    [$utm_source] as ss_utm_source,
    [$utm_campaign] as ss_utm_campaign,
    [$first_referrer] as ss_first_referrer,
    [$first_browser_language] as ss_first_browser_language,
    [$first_browser_charset] as ss_first_browser_charset,
    [$first_referrer_host] as ss_first_referrer_host,
    [$first_traffic_source_type] as ss_first_traffic_source_type,
    [$first_search_keyword] as ss_first_search_keyword,
    [$utm_medium] as ss_utm_medium,
    [$utm_content] as ss_utm_content,
    gender,
    convert(varchar, HASHBYTES('MD5', phonenumber),2) as phonenumber,
    [like],
    issuearticle,
    numberofcomment,
    numberofcommentreceived,
    likereceived,
    shoppingcredit,
    vip_card,
    vip_card_type,
    yanhuo,
    numofcoupon,
    convert(varchar, HASHBYTES('SHA2_256', email),2) as email,
    province,
    yearofbirth,
    city,
    birthday,
    lastordertime,
    numofcomment,
    numofcommentreceived,
    [$utm_term] as ss_utm_term,
    birthdaynew,
    userid,
    [$utm_matching_type] as ss_utm_matching_type,
    channelid,
    [$matched_key] as ss_matched_key,
    log_time_millis,
    idfa,
    vip_card_no,
    [$update_time] as ss_update_time,
    androidid,
    openid,
    unionid,
    imei,
    oaid,
    adhoc_clientid,
    @dt as dt 
from 
    ODS_Sensor.wrk_users
;
truncate table ODS_Sensor.wrk_users;
update statistics ODS_Sensor.Users
END

GO
