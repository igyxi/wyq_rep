/****** Object:  StoredProcedure [ODS_WechatCenter].[IMP_Wechat_Register_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_WechatCenter].[IMP_Wechat_Register_Info] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_WechatCenter.Wechat_Register_Info where dt = @dt;
insert into ODS_WechatCenter.Wechat_Register_Info
select 
    a.id,
	unionid,
	openid,
	sessionkey,
	lastaccesstime,
	registertime,
	registerchannel,
	registerstore,
	registersubchannel,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_WechatCenter.Wechat_Register_Info where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_WechatCenter.WRK_Wechat_Register_Info
) b
on a.id = b.id
where b.id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_WechatCenter.WRK_Wechat_Register_Info;
delete from ODS_WechatCenter.Wechat_Register_Info where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
