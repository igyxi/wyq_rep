/****** Object:  StoredProcedure [STG_MS_Wechat].[TRANS_Fans_10010001]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MS_Wechat].[TRANS_Fans_10010001] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-24       eddie.zhang        Initial Version
-- ========================================================================================
truncate table STG_MS_Wechat.Fans_10010001;
insert into STG_MS_Wechat.Fans_10010001
select 
     id
    ,case when trim(openid) in ('','null') then null else trim(openid) end as openid
    ,subscribe
    ,case when trim(nickname) in ('','null') then null else trim(nickname) end as nickname
    ,sex
    ,case when trim(language) in ('','null') then null else trim(language) end as language
    ,case when trim(city) in ('','null') then null else trim(city) end as city
    ,case when trim(province) in ('','null') then null else trim(province) end as province
    ,case when trim(country) in ('','null') then null else trim(country) end as country
    ,case when trim(headimgurl) in ('','null') then null else trim(headimgurl) end as headimgurl
    ,subscribe_time
    ,case when trim(unionid) in ('','null') then null else trim(unionid) end as unionid
    ,case when trim(remark) in ('','null') then null else trim(remark) end as remark
    ,case when trim(groupid) in ('','null') then null else trim(groupid) end as groupid
    ,case when trim(tagid_list) in ('','null') then null else trim(tagid_list) end as tagid_list
    ,case when trim(subscribe_scene) in ('','null') then null else trim(subscribe_scene) end as subscribe_scene
    ,case when trim(qr_scene) in ('','null') then null else trim(qr_scene) end as qr_scene
    ,case when trim(qr_scene_str) in ('','null') then null else trim(qr_scene_str) end as qr_scene_str
    ,create_time
    ,update_time
    ,current_timestamp as insert_timestamp
from 
(
    select *, ROW_NUMBER() over(partition by id order by dt desc) as rownum from [ODS_MS_Wechat].[Fans_10010001]
)t
where t.rownum = 1
END


GO
