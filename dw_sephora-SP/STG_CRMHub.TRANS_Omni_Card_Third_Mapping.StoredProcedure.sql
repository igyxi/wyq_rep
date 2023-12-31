/****** Object:  StoredProcedure [STG_CRMHub].[TRANS_Omni_Card_Third_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_CRMHub].[TRANS_Omni_Card_Third_Mapping] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_CRMHub.Omni_Card_Third_Mapping ;
insert into STG_CRMHub.Omni_Card_Third_Mapping
select 
    id,
    case when trim(union_id) in ('null','') then null else trim(union_id) end as union_id,
    omni_card_base_info_id,
    null as encrypt_mobile,
    case when trim(third_channel) in ('null','') then null else trim(third_channel) end as third_channel,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(ouid) in ('null','') then null else trim(ouid) end as ouid,
    is_copy,
    current_timestamp as insert_timestamp
from 
    ODS_CRMHub.Omni_Card_Third_Mapping 
where dt = @dt
END
GO
