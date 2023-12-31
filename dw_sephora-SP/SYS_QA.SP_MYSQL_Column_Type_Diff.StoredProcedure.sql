/****** Object:  StoredProcedure [SYS_QA].[SP_MYSQL_Column_Type_Diff]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [SYS_QA].[SP_MYSQL_Column_Type_Diff] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- ========================================================================================
truncate table SYS_QA.MYSQL_Column_Type_Diff;
with tmp_schema_table as
(
    SELECT
        a.table_schema as source_table_schema,
        a.table_name as source_table_name,
        a.tran_table_schema as source_tran_table_schema,
        b.TABLE_SCHEMA,
        b.table_name
    FROM
    (
        select 
            table_schema,
            table_name,
            case when table_schema in ('ims','oims_goods','oims_support','oms_order','oims_system') then 'ods_new_oms'
                else CONCAT('ODS_', table_schema) end as tran_table_schema 
        from     
            SYS_QA.MySQL_SCHEMA_Table_Columns_Info
        where
            type = 'current'    
        group by  
            table_schema,
            table_name   
    )  a
    inner join
    (
        select 
             TABLE_SCHEMA,
             TABLE_NAME 
        from 
            information_schema.columns 
        where 
            TABLE_SCHEMA like 'ODS%' 
        group by  
             TABLE_SCHEMA,
             TABLE_NAME   
    ) b    
    on a.table_name = b.TABLE_NAME AND a.tran_table_schema = b.TABLE_SCHEMA
    inner join 
    (
        select 
            table_schema,
            table_name,
            case when table_schema in ('ims','oims_goods','oims_support','oms_order','oims_system') then 'ods_new_oms'
                else CONCAT('ODS_', table_schema) end as tran_table_schema 
        from     
            SYS_QA.MySQL_SCHEMA_Table_Columns_Info
        where
            type = 'history'    
        group by  
            table_schema,
            table_name   
    ) c
   on c.table_name = b.TABLE_NAME AND c.tran_table_schema = b.TABLE_SCHEMA
)

insert into SYS_QA.MYSQL_Column_Type_Diff 
select
    a.source_table_schema
    ,a.source_tran_table_schema as adw_table_schema
    ,a.source_table_name as table_name
    ,a.column_name
    ,a.column_type as current_mysql_column_type
    ,b.column_type as history_mysql_column_type
    ,c.data_type as current_adw_column_type
    ,current_timestamp as insert_timestamp
from
(    

    select 
        t2.source_table_schema,
        t2.source_table_name,
        t2.source_tran_table_schema,
        t1.column_name,
        t1.column_type
    from     
        SYS_QA.MySQL_SCHEMA_Table_Columns_Info t1
    inner join tmp_schema_table t2
    on t1.table_schema = t2.source_table_schema and t1.table_name = t2.source_table_name
    where
        t1.type = 'current' 
) a   
inner join
(     
    select 
        t2.source_table_schema,
        t2.source_table_name,
        t2.source_tran_table_schema,
        t1.column_name,
        t1.column_type
    from     
        SYS_QA.MySQL_SCHEMA_Table_Columns_Info t1
    inner join tmp_schema_table t2
    on t1.table_schema = t2.source_table_schema and t1.table_name = t2.source_table_name
    where
        t1.type = 'history' 
) b
on a.source_table_schema = b.source_table_schema and a.source_table_name = b.source_table_name and a.column_name = b.column_name
left join information_schema.columns c
on a.source_tran_table_schema = c.table_schema AND a.source_table_name = c.table_name AND a.column_name = c.column_name
where 
    a.column_type <> b.column_type 
;
end

GO
