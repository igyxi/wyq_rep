/****** Object:  StoredProcedure [STG_WechatCenter].[TRANS_Wechat_Bind_Mobile_List]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_WechatCenter].[TRANS_Wechat_Bind_Mobile_List] AS
BEGIN
truncate table STG_WechatCenter.Wechat_Bind_Mobile_List ;
insert into STG_WechatCenter.Wechat_Bind_Mobile_List
select 
    id,
    case when trim(lower(openid)) in ('null','') then null else trim(openid) end as openid,
    null as mobile,
    isactive,
    bindtime,
    case when trim(lower(bindstore)) in ('null','') then null else trim(bindstore) end as bindstore,
    case when trim(lower(subchannel)) in ('null','') then null else trim(subchannel) end as subchannel,
    case when trim(lower(attachedchannel)) in ('null','') then null else trim(attachedchannel) end as attachedchannel,
    case when trim(lower(sephoratoken)) in ('null','') then null else trim(sephoratoken) end as sephoratoken,
    userid,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_WechatCenter.Wechat_Bind_Mobile_List
)t
where rownum = 1
END


GO
