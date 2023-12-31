/****** Object:  StoredProcedure [SYS_QA].[SP_Sensor_Table_Columns_DIFF]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [SYS_QA].[SP_Sensor_Table_Columns_DIFF] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-25       Eric          Initial Version
-- ========================================================================================
truncate table SYS_QA.Sensor_Table_Columns_DIFF;
insert into SYS_QA.Sensor_Table_Columns_DIFF
select 
    'User' as table_name,
    'field_increase' as type,
     a.name as column_name,
     current_timestamp as insert_timestamp
from 
    SYS_QA.Sensor_Users_Columns_Info a
left join
( 
    select 
        column_name
    from     
        information_schema.columns
    where 
        TABLE_SCHEMA = 'ODS_Sensor'
        and TABLE_NAME = 'Users'
) b  
on replace(a.name,'$', 'ss_') = b.COLUMN_NAME  
where
    b.COLUMN_NAME is null 
    and a.name not like 'user_group_%'  
union all
select
    'Events' as table_name,
    'field_increase' as type,
    c.name as column_name,
    current_timestamp as insert_timestamp
from 
    SYS_QA.Sensor_Events_Columns_Info c
left join
( 
    select 
        column_name
    from     
        information_schema.columns
    where 
        TABLE_SCHEMA = 'ODS_Sensor'
        and TABLE_NAME = 'Events'
) d  
on replace(c.name,'$', 'ss_') = d.COLUMN_NAME  
where 
    d.COLUMN_NAME is null;
end 
GO
