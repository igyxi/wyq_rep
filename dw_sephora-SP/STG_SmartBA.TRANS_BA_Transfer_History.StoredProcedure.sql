/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_BA_Transfer_History]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_BA_Transfer_History] AS
BEGIN
truncate table STG_SmartBA.BA_Transfer_History ;
insert into STG_SmartBA.BA_Transfer_History
select 
    case when trim(type) in ('null','') then null else trim(type) end as type,
    case when trim(employee_id) in ('null','') then null else trim(employee_id) end as employee_id,
    case when trim(employee_name) in ('null','') then null else trim(employee_name) end as employee_name,
    case when trim(transfer_from_department_cd) in ('null','') then null else trim(transfer_from_department_cd) end as transfer_from_department_cd,
    case when trim(transfer_from_department_type) in ('null','') then null else trim(transfer_from_department_type) end as transfer_from_department_type,
    case when trim(transfer_from_post) in ('null','') then null else trim(transfer_from_post) end as transfer_from_post,
    case when trim(transfer_from_city) in ('null','') then null else trim(transfer_from_city) end as transfer_from_city,
    case when trim(transfer_to_department_cd) in ('null','') then null else trim(transfer_to_department_cd) end as transfer_to_department_cd,
    case when trim(transfer_to_department_type) in ('null','') then null else trim(transfer_to_department_type) end as transfer_to_department_type,
    case when trim(transfer_to_post) in ('null','') then null else trim(transfer_to_post) end as transfer_to_post,
    case when trim(transfer_to_city) in ('null','') then null else trim(transfer_to_city) end as transfer_to_city,
    case when trim(orginal_superior_employee_id) in ('null','') then null else trim(orginal_superior_employee_id) end as orginal_superior_employee_id,
    case when trim(orginal_superior_name) in ('null','') then null else trim(orginal_superior_name) end as orginal_superior_name,
    case when trim(current_superior_employee_id) in ('null','') then null else trim(current_superior_employee_id) end as current_superior_employee_id,
    case when trim(current_superior_name) in ('null','') then null else trim(current_superior_name) end as current_superior_name,
    case when trim(transfer_type) in ('null','') then null else trim(transfer_type) end as transfer_type,
    case when trim(transfer_reason) in ('null','') then null else trim(transfer_reason) end as transfer_reason,
    case when trim(due_time) in ('null','') then null else trim(due_time) end as due_time,
    cast(active_time as date),
    cast(process_time as date),
    current_timestamp as insert_timestamp
from 
   ODS_SmartBA.BA_Transfer_History
where 
	trim(employee_id) not in ('null','')
END

GO
