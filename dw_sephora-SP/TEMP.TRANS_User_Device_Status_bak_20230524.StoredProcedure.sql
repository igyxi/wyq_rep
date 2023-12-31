/****** Object:  StoredProcedure [TEMP].[TRANS_User_Device_Status_bak_20230524]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_User_Device_Status_bak_20230524] AS
BEGIN
truncate table STG_User.User_Device_Status ;
insert into STG_User.User_Device_Status
select 
    client_id,
    user_id,
    case when trim(lower(supplier)) in ('null', '') then null else trim(supplier) end as supplier,
    status,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over (partition by client_id,user_id order by dt desc) rownum from ODS_User.User_Device_Status 
)t
where rownum = 1
END


GO
