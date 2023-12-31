/****** Object:  StoredProcedure [STG_WechatCenter].[TRANS_Wechat_BA_Bind]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_WechatCenter].[TRANS_Wechat_BA_Bind] AS
BEGIN
truncate table STG_WechatCenter.Wechat_BA_Bind ;
insert into STG_WechatCenter.Wechat_BA_Bind
select 
    id,
    case when trim(union_id) in ('null','') then null else trim(union_id) end as union_id,
    case when trim(open_id) in ('null','') then null else trim(open_id) end as open_id,
    null as mobile,
    case when trim(first_ba_account) in ('null','') then null else trim(first_ba_account) end as first_ba_account,
    case when trim(first_store_code) in ('null','') then null else trim(first_store_code) end as first_store_code,
    case when trim(current_ba_account) in ('null','') then null else trim(current_ba_account) end as current_ba_account,
    case when trim(current_store_code) in ('null','') then null else trim(current_store_code) end as current_store_code,
    is_delete,
    create_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    update_time,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_WechatCenter.Wechat_BA_Bind
) t
where rownum = 1
END


GO
