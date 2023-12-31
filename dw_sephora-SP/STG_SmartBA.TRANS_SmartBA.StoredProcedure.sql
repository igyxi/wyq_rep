/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_SmartBA]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_SmartBA] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_SmartBA.SmartBA ;
insert into STG_SmartBA.SmartBA
select 
    id,
    case when trim(storecode) in ('null', '') then null else trim(storecode) end as storecode, 
    case when trim(employeecode) in ('null', '') then null else trim(employeecode) end as employeecode,
    case when trim(unionid) in ('null', '') then null else trim(unionid) end as unionid, 
    status, 
    case when trim(region) in ('null', '') then null else trim(region) end as region, 
    case when trim(district) in ('null', '') then null else trim(district) end as district,
    case when trim(city) in ('null', '') then null else trim(city) end as city, 
    bindingtime, 
    insert_time, 
    last_update_time, 
    case when trim(source_file_path) in ('null', '') then null else trim(source_file_path) end as source_file_path,
    current_timestamp as insert_timestamp
from 
    ODS_SmartBA.SmartBA 
where dt =  @dt
END

GO
