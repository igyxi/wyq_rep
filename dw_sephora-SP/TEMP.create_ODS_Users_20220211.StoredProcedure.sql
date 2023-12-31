/****** Object:  StoredProcedure [TEMP].[create_ODS_Users_20220211]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[create_ODS_Users_20220211] AS
begin

create table ODS_Sensor.Users_20220211 
WITH
(
      DISTRIBUTION =  hash(id),
      CLUSTERED COLUMNSTORE INDEX,
      PARTITION
      (
            dt RANGE FOR VALUES ()
      )
) as 
SELECT 
    id
    ,cast(first_id as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS first_id
    ,cast(second_id as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS second_id
    ,ss_first_visit_time
    ,cast(ss_utm_source as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_utm_source
    ,cast(ss_utm_campaign as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_utm_campaign
    ,cast(ss_first_referrer as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_first_referrer
    ,cast(ss_first_browser_language as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_first_browser_language
    ,cast(ss_first_browser_charset as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_first_browser_charset
    ,cast(ss_first_referrer_host as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_first_referrer_host
    ,cast(ss_first_traffic_source_type as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_first_traffic_source_type
    ,cast(ss_first_search_keyword as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_first_search_keyword
    ,cast(ss_utm_medium as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_utm_medium
    ,cast(ss_utm_content as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_utm_content
    ,cast(gender as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS gender
    ,cast(phonenumber as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS phonenumber
    ,[like] 
    ,issuearticle
    ,numberofcomment
    ,numberofcommentreceived
    ,likereceived
    ,shoppingcredit
    ,cast(vip_card as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS vip_card
    ,cast(vip_card_type as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS vip_card_type
    ,yanhuo
    ,numofcoupon
    ,cast(email as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS email
    ,cast(province as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS province
    ,yearofbirth
    ,cast(city as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS city
    ,birthday
    ,lastordertime
    ,numofcomment
    ,numofcommentreceived
    ,cast(ss_utm_term as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_utm_term
    ,cast(birthdaynew as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS birthdaynew
    ,userid
    ,cast(ss_utm_matching_type as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_utm_matching_type
    ,cast(channelid as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS channelid
    ,cast(ss_matched_key as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS ss_matched_key
    ,cast(log_time_millis as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS log_time_millis
    ,cast(idfa as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS idfa
    ,cast(vip_card_no as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS vip_card_no
    ,ss_update_time
    ,cast(androidid as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS androidid
    ,cast(openid as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS openid
    ,cast(unionid as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS unionid
    ,cast(imei as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS imei
    ,cast(oaid as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS oaid
    ,cast(adhoc_clientid as nvarchar(4000))  collate  SQL_Latin1_General_CP1_CI_AS adhoc_clientid
    ,cast(dt as nvarchar(10))  collate  SQL_Latin1_General_CP1_CI_AS dt
FROM ODS_Sensor.Users  with (nolock)

END
GO
