/****** Object:  StoredProcedure [STG_WechatCenter].[TRANS_Wechat_Bind_Mobile_History]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_WechatCenter].[TRANS_Wechat_Bind_Mobile_History] AS
BEGIN
truncate table STG_WechatCenter.Wechat_Bind_Mobile_History ;
insert into STG_WechatCenter.Wechat_Bind_Mobile_History
select 
    id,
    case when trim(lower(openid)) in ('null','') then null else trim(openid) end as openid,
    case when trim(lower(newbindmobile)) in ('null','') then null else trim(newbindmobile) end as newbindmobile,
    case when trim(lower(oldbindmobile)) in ('null','') then null else trim(oldbindmobile) end as oldbindmobile,
    changebindtime,
    case when trim(lower(changedesc)) in ('null','') then null else trim(changedesc) end as changedesc,
    case when trim(lower(currentbindstore)) in ('null','') then null else trim(currentbindstore) end as currentbindstore,
    case when trim(lower(currentsubchannel)) in ('null','') then null else trim(currentsubchannel) end as currentsubchannel,
    case when trim(lower(attachedchannel)) in ('null','') then null else trim(attachedchannel) end as attachedchannel,
    case when trim(lower(newphonearea)) in ('null','') then null else trim(newphonearea) end as newphonearea,
    case when trim(lower(newphonefull)) in ('null','') then null else trim(newphonefull) end as newphonefull,
    newbinduserid,
    isnewregister,
    registertime,
    case when trim(lower(bindmobilecardno)) in ('null','') then null else trim(bindmobilecardno) end as bindmobilecardno,
    case when trim(lower(bindmobilecardlevel)) in ('null','') then null else trim(bindmobilecardlevel) end as bindmobilecardlevel,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *,row_number() over(partition by id order by dt desc) rownum from ODS_WechatCenter.Wechat_Bind_Mobile_History 
) t
where rownum = 1
END

GO
