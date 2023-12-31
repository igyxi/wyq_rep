/****** Object:  StoredProcedure [SYS_QA].[SP_MySQL_SCHEMA_Table_Columns_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [SYS_QA].[SP_MySQL_SCHEMA_Table_Columns_Info] AS
BEGIN
delete from [SYS_QA].[MySQL_SCHEMA_Table_Columns_Info] where type = 'history';
insert into SYS_QA.MySQL_SCHEMA_Table_Columns_Info
SELECT
    a.table_schema,
    a.table_name,
    a.column_name,
    a.column_type,
    'history' as type,
    a.insert_timestamp
from 
    SYS_QA.MySQL_SCHEMA_Table_Columns_Info a
where
   a.type = 'current' 
;   
delete from [SYS_QA].[MySQL_SCHEMA_Table_Columns_Info] where type = 'current';
insert into SYS_QA.MySQL_SCHEMA_Table_Columns_Info
SELECT
    b.table_schema,
    b.table_name,
    b.column_name,
    b.column_type,
    b.type,
    b.insert_timestamp
from 
    SYS_QA.WRK_MySQL_SCHEMA_Table_Columns_Info b
;

END

GO
