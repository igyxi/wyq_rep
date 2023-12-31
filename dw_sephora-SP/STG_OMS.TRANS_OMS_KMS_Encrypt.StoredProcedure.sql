/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_KMS_Encrypt]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_KMS_Encrypt] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-23       Eric        Initial Version
-- ========================================================================================
truncate table STG_OMS.OMS_KMS_Encrypt;
insert into STG_OMS.OMS_KMS_Encrypt
select 
    id,
    case when trim(encrypt) in ('null','') then null else trim(encrypt) end as encrypt,
    case when trim(order_number) in ('null','') then null else trim(order_number) end as order_number,
    order_sys_id,
    address_sys_id,
    case when trim(type) in ('null','') then null else trim(type) end as type,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_OMS.OMS_KMS_Encrypt
) t
where rownum = 1
END


GO
