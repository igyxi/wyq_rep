/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_System_Param_Value]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_System_Param_Value] AS
BEGIN
truncate table STG_OMS.OMS_System_Param_Value;
insert into STG_OMS.OMS_System_Param_Value
select 
    sys_param_value_sys_id,
    system_param_def_sys_id,
    case when trim(system_param_name) in ('null','') then null else trim(system_param_name) end as system_param_name,
    case when trim(system_param_description) in ('null','') then null else trim(system_param_description) end as system_param_description,
    case when trim(system_param_value) in ('null','') then null else trim(system_param_value) end as system_param_value,
    system_param_value_order,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,
    case when trim(field3) in ('null','') then null else trim(field3) end as field3,
    case when trim(field4) in ('null','') then null else trim(field4) end as field4,
    case when trim(field5) in ('null','') then null else trim(field5) end as field5,
    case when trim(field6) in ('null','') then null else trim(field6) end as field6,
    sys_param_value_status,
    create_time,
    update_time,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    case when trim(system_param_set) in ('null','') then null else trim(system_param_set) end as system_param_set,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by sys_param_value_sys_id order by dt desc) rownum from ODS_OMS.OMS_System_Param_Value
) t
where rownum = 1
END


GO
