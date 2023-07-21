 

-- --------------------------------sqlserver表导入记录----------------------------------------
select 
   *
from 
    [Management].[DW_Source_Table_List]
where 
    source_table in (
 'ODS_deleted_obj_record'
)
;
select COUNT(1) from 
ods_crm.ODS_deleted_obj_record
;

-- --------------------------------sqlserver建表语句----------------------------------------
select 
concat('create table ',t1.table_name,' ('+char(13),STRING_AGG(concat('    '+t2.[name],' '+t3.[name],'(',t2.max_length,') ','comment '''''),','+char(13)),char(13)+')')
from
(
select 
concat(b.[name],'.',a.[name]) as table_name,
a.object_id,
a.schema_id
from
[sys].[objects] a
left join [sys].[schemas] b on b.schema_id=a.schema_id
where concat(b.[name],'.',a.[name])='ODS_Product.SKU_Mapping'
) t1
left join [sys].[columns] t2 on t1.object_id=t2.object_id
left join [sys].[types] t3 on t2.system_type_id=t3.system_type_id
where t3.[name]<>'sysname'
group by t1.table_name

;



SELECT * from ods_crm.DIM_PaymentCode_Mapping
;

select * from
ODS_Product.SKU_Mapping
order by dt desc

SELECT 
*
-- max(update_time)
 from ODS_Product.WRK_PROD_Product_Comment
order by update_time desc 



-- [Management].[Table_Last_Update_Logging]




;
select 
max(update_time)
from 
ODS_Product.WRK_PROD_Product_Comment



