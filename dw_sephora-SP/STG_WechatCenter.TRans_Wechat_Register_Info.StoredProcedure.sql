/****** Object:  StoredProcedure [STG_WechatCenter].[TRans_Wechat_Register_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_WechatCenter].[TRans_Wechat_Register_Info] AS
BEGIN
truncate table STG_WechatCenter.Wechat_Register_Info ;
insert into STG_WechatCenter.Wechat_Register_Info
select 
    id,
    case when trim(unionid) in ('null', '') then null else trim(unionid) end as unionid,
    case when trim(openid) in ('null', '') then null else trim(openid) end as openid,
    case when trim(sessionkey) in ('null', '') then null else trim(sessionkey) end as sessionkey,
    lastaccesstime,
    registertime,
    case when trim(registerchannel) in ('null', '') then null else trim(registerchannel) end as registerchannel,
    case when trim(registerstore) in ('null', '') then null else trim(registerstore) end as registerstore,
    case when trim(registersubchannel) in ('null', '') then null else trim(registersubchannel) end as registersubchannel,
    create_time,
    update_time,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_WechatCenter.Wechat_Register_Info
) t
where rownum = 1
END


GO
