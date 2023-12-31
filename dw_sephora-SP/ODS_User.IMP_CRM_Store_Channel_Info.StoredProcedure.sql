/****** Object:  StoredProcedure [ODS_User].[IMP_CRM_Store_Channel_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_User].[IMP_CRM_Store_Channel_Info] @dt [varchar](10) AS
BEGIN
delete from ODS_User.[CRM_Store_Channel_Info] where dt = @dt;
insert into ODS_User.[CRM_Store_Channel_Info]
select 
    id,
    union_id,
    store_name,
    channel,
    create_time,
    update_time,
    create_user,
    update_user,
    is_deleted,
    @dt as dt 
from 
    ODS_User.WRK_CRM_Store_Channel_Info;
TRUNCATE table ODS_User.WRK_CRM_Store_Channel_Info;
update statistics ODS_User.[CRM_Store_Channel_Info];
end
GO
