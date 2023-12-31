/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_System_Param_Definition]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_System_Param_Definition] AS
BEGIN
truncate table STG_OMS.OMS_System_Param_Definition;
insert into STG_OMS.OMS_System_Param_Definition
select 
    system_param_def_sys_id,
    case when trim(system_param_name) in ('null','') then null else trim(system_param_name) end as system_param_name,
    case when trim(system_param_description) in ('null','') then null else trim(system_param_description) end as system_param_description,
    case when trim(system_param_code) in ('null','') then null else trim(system_param_code) end as system_param_code,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,
    case when trim(field3) in ('null','') then null else trim(field3) end as field3,
    case when trim(field4) in ('null','') then null else trim(field4) end as field4,
    field5,
    field6,
    sys_param_def_status,
    create_time,
    update_time,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by system_param_def_sys_id order by dt desc) rownum from ODS_OMS.OMS_System_Param_Definition
) t
where rownum = 1
END


GO
