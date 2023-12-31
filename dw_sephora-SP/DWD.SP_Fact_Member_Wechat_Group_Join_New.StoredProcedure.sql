/****** Object:  StoredProcedure [DWD].[SP_Fact_Member_Wechat_Group_Join_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Member_Wechat_Group_Join_New] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       wangzhichun        Initial Version
-- 2022-01-12       tali               rename table
-- 2023-04-23       wangzhichun        change STG_SmartBA to ODS_SmartBA
-- ========================================================================================
truncate table DWD.Fact_Member_Wechat_Group_Join_New;
insert into DWD.Fact_Member_Wechat_Group_Join_New
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
	[test].[T_WXChat_Sale] st
where st.dt = @dt
END

GO
