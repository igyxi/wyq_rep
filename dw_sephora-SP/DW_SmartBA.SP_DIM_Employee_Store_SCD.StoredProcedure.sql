/****** Object:  StoredProcedure [DW_SmartBA].[SP_DIM_Employee_Store_SCD]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_SmartBA].[SP_DIM_Employee_Store_SCD] AS
BEGIN
truncate table DW_SmartBA.DIM_Employee_Store_SCD;
insert into DW_SmartBA.DIM_Employee_Store_SCD
select 
    employee_id,
    transfer_to_department_cd as store_cd,
    process_time as start_process_time,
    lead(process_time,1,'9999-12-31') over(partition by employee_id order by process_time) as end_process_time,
    current_timestamp as insert_timestamp
from 
    [STG_SmartBA].[BA_Transfer_History]
where 
    type=N'部门调动'
and PATINDEX('%[^0-9]%',transfer_to_department_cd) = 0
union all
select distinct
    employee_id,
    first_value(transfer_from_department_cd) over(partition by employee_id order by process_time) as transfer_to_department_cd,
    '1970-01-01' as start_process_time,
    first_value(process_time) over(partition by employee_id order by process_time) as end_process_time,
    current_timestamp as insert_timestamp
from 
    [STG_SmartBA].[BA_Transfer_History]
where 
    type=N'部门调动'
and PATINDEX('%[^0-9]%',transfer_to_department_cd) = 0
END
GO
