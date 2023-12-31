/****** Object:  StoredProcedure [ODS_WechatCenter].[IMP_Wechat_BA_Bind]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_WechatCenter].[IMP_Wechat_BA_Bind] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_WechatCenter.Wechat_BA_Bind where dt = @dt;
insert into ODS_WechatCenter.Wechat_BA_Bind
select 
    id,
	union_id,
	open_id,
    convert(varchar(max),HASHBYTES('MD5', mobile),2) as mobile,
	first_ba_account,
	first_store_code,
	current_ba_account,
	current_store_code,
	is_delete,
	create_time,
	create_user,
	update_time,
	update_user,
    @dt as dt
from 
    ODS_WechatCenter.WRK_Wechat_BA_Bind;
truncate table ODS_WechatCenter.WRK_Wechat_BA_Bind;
END

GO
