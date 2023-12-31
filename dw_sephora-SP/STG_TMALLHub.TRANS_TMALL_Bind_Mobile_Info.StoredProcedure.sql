/****** Object:  StoredProcedure [STG_TMALLHub].[TRANS_TMALL_Bind_Mobile_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TMALLHub].[TRANS_TMALL_Bind_Mobile_Info] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_TMALLHub.TMALL_Bind_Mobile_Info;
insert into STG_TMALLHub.TMALL_Bind_Mobile_Info
select 
     id,		
    case when trim(customer_id) in ('null','') then null else trim(customer_id) end as customer_id,		
    case when trim(channel) in ('null','') then null else trim(channel) end as channel,		
    null,		
    bind_time,		
    user_id,		
    create_time,		
    update_time,		
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,		
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,		
    is_delete,
    case when trim(ouid) in ('null','') then null else trim(ouid) end as ouid,
    is_copy,  
    current_timestamp as insert_timestamp
from 
    ODS_TMALLHub.TMALL_Bind_Mobile_Info 
where dt = @dt
END


GO
