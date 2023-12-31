/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_WXChat_Sale]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_WXChat_Sale] @dt [varchar](10) AS
BEGIN
delete from STG_SmartBA.T_WXChat_Sale where dt = @dt;
insert into STG_SmartBA.T_WXChat_Sale
select 
    id,
    chat_time,
    case when trim(wxcp_userid) in ('null', '') then null else trim(wxcp_userid) end as wxcp_userid,
    case when trim(unionid) in ('null', '') then null else trim(unionid) end as unionid,
    join_time,
    case when trim(chat_name) in ('null', '') then null else trim(chat_name) end as chat_name,
    case when trim(chat_id) in ('null', '') then null else trim(chat_id) end as chat_id,
    chat_type,
    case when trim(channel_name) in ('null', '') then null else trim(channel_name) end as channel_name,
    case when trim(owner_name) in ('null', '') then null else trim(owner_name) end as owner_name,
    tenant_id,
    create_time,
    case when trim(store_code) in ('null', '') then null else trim(store_code) end as store_code,
    current_timestamp as insert_timestamp,
    dt
from 
    ODS_SmartBA.T_WXChat_Sale
where dt = @dt
END


GO
