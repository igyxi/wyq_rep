/****** Object:  StoredProcedure [SYS_QA].[SP_MYSQL_SQLSever_SCHEMA__TABLE_COLUMN_DIFF]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [SYS_QA].[SP_MYSQL_SQLSever_SCHEMA__TABLE_COLUMN_DIFF] AS
BEGIN
truncate table [SYS_QA].[MYSQL_SQLSever_SCHEMA__TABLE_COLUMN_DIFF];
with tmp_schema_table as
(
    SELECT
        a.table_schema as source_table_schema,
        a.table_name as source_table_name,
        a.tran_table_schema,
        b.TABLE_SCHEMA,
        b.table_name
    FROM
    (
        select 
            table_schema,
            -- case when table_schema in ('ims','oims_goods','oims_support','oms_market','oims_system')
            -- or (table_schema ='stg_new_oms_order' and table_name in 
            -- ('omni_refund_task_bill','omni_return_order_relation','oms_order_split_relation',
            -- 'ord_logistics_trail','oms_std_refund','oms_std_refund_item','oms_std_return_item',
            -- 'oms_std_return','oms_std_trade_invoice','oms_std_trade_item',
            -- 'oms_std_trade_promotion','oms_std_trade','omni_order_month_statistics','omni_refund_apply_bill'
            -- ,'omni_refund_apply_item','omni_retail_ord_goods_detail','omni_retail_ord_settl_de','omni_retail_order_bill',
            -- 'omni_retail_order_receipt','omni_retail_order_receipt_line','omni_retail_return_bill','omni_retail_return_gds_de'
            -- ))
            -- then CONCAT(table_name,'_STG')
            -- else table_name end as table_name,
            table_name,
            -- case when table_schema in ('ims','oims_goods','oims_support','oms_market','oims_system') then 'ods_ims'
            --     when table_schema ='stg_new_oms_order' then 'ods_new_oms'
            --     else CONCAT('ODS_', table_schema) end as tran_table_schema 
            CONCAT('ODS_', table_schema) as tran_table_schema
        from     
            SYS_QA.MySQL_SCHEMA_Table_Columns_Info
        where type = 'current'
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
)
insert into [SYS_QA].[MYSQL_SQLSever_SCHEMA__TABLE_COLUMN_DIFF]
SELECT
    a.source_table_schema,
    a.source_table_name,
    a.source_column_name,
    b.table_schema,
    b.table_name,
    b.column_name,
    current_timestamp as insert_timestamp
FROM
(
    select 
        t2.source_table_schema,
        t2.source_table_name,
        t1.column_name as source_column_name,
        t2.tran_table_schema
    from     
        SYS_QA.MySQL_SCHEMA_Table_Columns_Info t1
    inner join tmp_schema_table t2
    -- on t1.table_schema = t2.source_table_schema and  t2.source_table_name in (t1.table_name,CONCAT(t1.table_name,'_STG'))
    on t1.table_schema = t2.source_table_schema and  t2.source_table_name=t1.table_name
    where t1.type = 'current'
)  a
full join
(
    select 
        t3.table_schema,
        t3.table_name,
        t3.column_name
    from     
        information_schema.columns t3
    inner join tmp_schema_table t4
    on t3.table_schema = t4.table_schema and t3.table_name = t4.table_name 
    where 
        t3.column_name not in ('dt', 'insert_timestamp')
) b    
on a.tran_table_schema = b.table_schema AND a.source_table_name = b.table_name AND a.source_column_name = b.column_name
where 
    b.table_schema is null 
    or a.source_table_schema is null;
END

GO
