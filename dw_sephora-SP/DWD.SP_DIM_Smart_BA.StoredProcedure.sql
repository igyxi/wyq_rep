/****** Object:  StoredProcedure [DWD].[SP_DIM_Smart_BA]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Smart_BA] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-01-10       Eric           delete column and change column name
-- ========================================================================================
truncate table DWD.DIM_Smart_BA;
insert into DWD.DIM_Smart_BA
select 
    id,
    storeid as store_code,
    employeeid as employee_id,
    employeename as employee_name,
    englishname as english_name,
    position,
    joindate as join_date,
    leavedate as leave_date,
    email,
    empstatus as emp_status,
    etype as emp_type,
    effectdate as effect_date,
    insert_time,
    last_update_time,
    -- source_file_path,
    'CRM' as source,
    current_timestamp as insert_timestamp
from
    [ODS_HR].[Retail_Employee]
END
GO
