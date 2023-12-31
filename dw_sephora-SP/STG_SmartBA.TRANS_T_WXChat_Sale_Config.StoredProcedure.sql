/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_WXChat_Sale_Config]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_WXChat_Sale_Config] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_SmartBA.T_WXChat_Sale_Config ;
insert into STG_SmartBA.T_WXChat_Sale_Config
select
    id,
    case when trim(chat_name) in ('null', '') then null else trim(chat_name) end as chat_name,
    case when trim(chat_id) in ('null', '') then null else trim(chat_id) end as chat_id,
    chat_type,
    case when trim(channel_name) in ('null', '') then null else trim(channel_name) end as channel_name,
    case when trim(owner_name) in ('null', '') then null else trim(owner_name) end as owner_name,
    tenant_id,
    case when trim(create_at) in ('null', '') then null else trim(create_at) end as create_at,
    create_time,
    current_timestamp as insert_timestamp
from 
    ODS_SmartBA.T_WXChat_Sale_Config
where dt = @dt
END



GO
