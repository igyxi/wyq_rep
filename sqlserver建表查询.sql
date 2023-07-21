

-- --------------------------------sqlserver表导入记录----------------------------------------
select
    *
from
    [Management].[DW_Source_Table_List]
where 
    source_table in (
 'BAS_Adminarea'
)
;


-- =================================================sqlserver建表语句================================================
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
    where concat(b.[name],'.',a.[name])='ODS_crm.account'
) t1
    left join [sys].[columns] t2 on t1.object_id=t2.object_id
    left join [sys].[types] t3 on t2.system_type_id=t3.system_type_id
where t3.[name]<>'sysname'
group by t1.table_name
;
-- ========================================表对应最新更新时间======================================================================


SELECT
    top 100
    *, max(dt) over() max_time_over
from ODS_IMS.Bas_Channel
;

-- ==================================================


SELECT top 100
    OBJECT_SCHEMA_NAME(object_id), OBJECT_NAME(object_id), [definition]
FROM sys.sql_modules
WHERE [definition] LIKE '%shelf_product%'






-- ==============================================================


select *
from [Management].[DW_Source_Table_List]
where source_table in (
        'account_offer'
        -- ,'sap_sku'
        -- ,'Space_Meter_History'
    );

-- ==========================================================================

select value , row_number() over(order by (select null)) rn
from string_split('11|22|33|44','|')[0];
select *
from ODS_JDA.Confg_JDA_Files_Type
;
select *
from ODS_JDA.JDA_File_List_Data_Load
;
select *
from ODS_JDA.JDA_Files_Info
;
select *
from ODS_JDA.Space_Meter_RowToRevise
order by insert_time desc
;
select *
from ODS_JDA.Space_Shelf_Meter_History
order by insert_time desc
;
-- ==============================

SELECT
    reverse(parsename(replace(REVERSE('Hello World|hah|wuxi'),'|','.'),1)) AS ReversedString1
, reverse(parsename(replace(REVERSE('Hello World|hah|wuxi'),'|','.'),2)) AS ReversedString2
, reverse(parsename(replace(REVERSE('Hello World|hah|wuxi'),'|','.'),3)) AS ReversedString3
;




select
    cast(create_time as date)   dt
, count(1) ct 
, max(timestamp) max_time
, max(cast(timestamp as bigint)) max_time
from ODS_crm.account_offer
group by  cast(create_time as date)
order by  dt desc
;



select * 
, lag(ma_) over(order by dt desc) -A.ma_ gap_col
from
    (
SELECT
        -- top 3 *
        cast(send_date as date) dt 
-- ,count(1) ct 
, max(cast(timestamp1 as bigint) ) ma_
, min(cast(timestamp1 as bigint) ) mi_
    FROM ODS_crm.communication_track_linked_obj
    where send_date>'2023-05-01'
    group by cast(send_date as date)
)A
order by dt desc



SELECT
    top 3
    *
FROM ODS_crm.communication_track_linked_obj
where send_date>'2023-05-01'
order by TIMESTAMP1 desc
;

SELECT
    max(TIMESTAMP1 ) dt, max(cast(TIMESTAMP1 as bigint)  )
FROM ODS_crm.communication_track_linked_obj
where send_date>'2023-05-01'
;

select count(1)
from
    ods_crm.account
where   TIMESTAMP >= 108397530000
order by dt desc
;

select count(1)
from
    ods_crm.account_log
where   TIMESTAMP >= 108397530000
;

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


select max(file_create_date)
from ods_jda.JDA_Files_Info







;


select
    nvl(if(trim(a.play_video_id) ='',null,a.play_video_id),b.njxj_code)  play_video_id
    a.cartoon_id,
    b.id,
    
from
    dw_play_video_info_dd a left join njxj_das_job.njxj_product_cartoon_detail_tab b on a.cartoon_id = b.id
where
a.STATISTICS_DATE = '20230608'
;





