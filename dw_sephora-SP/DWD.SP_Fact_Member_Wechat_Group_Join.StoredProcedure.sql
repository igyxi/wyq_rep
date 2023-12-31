/****** Object:  StoredProcedure [DWD].[SP_Fact_Member_Wechat_Group_Join]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Member_Wechat_Group_Join] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       wangzhichun        Initial Version
-- 2022-01-12       tali           rename table
-- 2023-01-14       wangzhichun        add store_code
-- ========================================================================================
truncate table DWD.Fact_Member_Wechat_Group_Join;
insert into DWD.Fact_Member_Wechat_Group_Join
select distinct
	st.id,
	st.chat_time as chat_group_create_time,
	st.wxcp_userid,
	st.unionid,
    st.store_code as store_code,
	st.join_time,
	st.chat_name,
	st.chat_id,
	st.chat_type,
	st.channel_name,
	st.owner_name,
	st.tenant_id,
	st.create_time,
	'OMS' as source,
	current_timestamp as insert_timestamp
from 
	[STG_SmartBA].[T_WXChat_Sale] st
where st.dt = @dt
END
GO
