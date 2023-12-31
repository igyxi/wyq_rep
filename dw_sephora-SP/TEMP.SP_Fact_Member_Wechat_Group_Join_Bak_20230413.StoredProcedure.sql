/****** Object:  StoredProcedure [TEMP].[SP_Fact_Member_Wechat_Group_Join_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Member_Wechat_Group_Join_Bak_20230413] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       wangzhichun        Initial Version
-- 2022-01-12       tali           rename table
-- ========================================================================================
truncate table DWD.Fact_Member_Wechat_Group_Join;
insert into DWD.Fact_Member_Wechat_Group_Join
select 
	id,
	chat_time as chat_group_create_time,
	wxcp_userid,
	unionid,
	join_time,
	chat_name,
	chat_id,
	chat_type,
	channel_name,
	owner_name,
	tenant_id,
	create_time,
	'OMS' as source,
	current_timestamp as insert_timestamp
from 
	[STG_SmartBA].[T_WXChat_Sale] st
where dt=@dt;
END

GO
