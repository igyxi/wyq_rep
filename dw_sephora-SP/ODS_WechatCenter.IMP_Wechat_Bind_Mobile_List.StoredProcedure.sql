/****** Object:  StoredProcedure [ODS_WechatCenter].[IMP_Wechat_Bind_Mobile_List]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_WechatCenter].[IMP_Wechat_Bind_Mobile_List] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_WechatCenter.Wechat_Bind_Mobile_List where dt = @dt;
insert into ODS_WechatCenter.Wechat_Bind_Mobile_List
select 
    id,
	openid,
    convert(varchar(max),HASHBYTES('MD5', mobile),2) as mobile,
	isactive,
	bindtime,
	bindstore,
	subchannel,
	attachedchannel,
	sephoratoken,
	userid,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
    ODS_WechatCenter.WRK_Wechat_Bind_Mobile_List;
truncate table ODS_WechatCenter.WRK_Wechat_Bind_Mobile_List;
END



GO
