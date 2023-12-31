/****** Object:  StoredProcedure [ODS_WechatCenter].[IMP_Wechat_Bind_Mobile_History]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_WechatCenter].[IMP_Wechat_Bind_Mobile_History] @dt [VARCHAR](10) AS
BEGIN
delete from [ODS_WechatCenter].[Wechat_Bind_Mobile_History]  where dt = @dt;
insert into [ODS_WechatCenter].[Wechat_Bind_Mobile_History]
select 
    id,
    openid,
    convert(varchar(max), HASHBYTES('MD5', newbindmobile),2) as newbindmobile,
    convert(varchar(max), HASHBYTES('MD5', oldbindmobile),2) as oldbindmobile,
    changebindtime,
    changedesc,
    currentbindstore,
    currentsubchannel,
    attachedchannel,
    newphonearea,
    convert(varchar(max), HASHBYTES('MD5', newphonefull),2) as newphonefull,
    newbinduserid,
    isnewregister,
    registertime,
    bindmobilecardno,
    bindmobilecardlevel,
    create_time,
    update_time,
    create_user,
    update_user,
    is_delete,
    @dt as dt
from 
    ODS_WechatCenter.WRK_Wechat_Bind_Mobile_History;
truncate table ODS_WechatCenter.WRK_Wechat_Bind_Mobile_History;
END

GO
