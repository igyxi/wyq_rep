/****** Object:  StoredProcedure [TEMP].[SP_DIM_Member_Card_Grade_SCD_Bak_20230512]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Member_Card_Grade_SCD_Bak_20230512] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       Eric           Initial Version
-- 2022-01-14       Mac            update
-- 2022-03-21       Tali           add deleted_obj_record logic
-- 2022-04-01       Tali           change the update logic
-- 2022-04-06       tali           delete member_seq
-- 2022-07-11       tali           change delete logic
-- 2022-07-11       tali           change sort column to account_log_id
-- 2022-12-08       tali           change update logic
-- 2023-04-04       yaozhipeng     change [Management].[Table_Last_Update_Logging] to [Management].[DW_Table_Update_Logging]
-- ========================================================================================
/*
DECLARE @ts bigint = null;
select 
    -- get max timestamp of the day before 
    @ts = max_timestamp 
from 
(
    select  *, row_number() over(order by last_update_time desc) rownum
    from [Management].[Table_Last_Update_Logging] with (nolock)
    where CONCAT([schema],'.',[table]) = 'ODS_CRM.ACCOUNT_LOG' 
    and last_update_time between @dt and DATEADD(day, 1, @dt)
) t
where rownum = 1;
*/
DECLARE @ts bigint = null;select     -- get max timestamp of the day before     @ts = last_incremental_timestampfrom (    select  *, row_number() over(order by last_update_time desc) rownum    from [Management].[DW_Table_Update_Logging] with (nolock)    where CONCAT([schema],'.',[table]) = 'ODS_CRM.ACCOUNT_LOG'    and last_update_time between @dt and DATEADD(day, 1, @dt)) twhere rownum = 1;

insert into DWD.DIM_Member_Card_Grade_SCD
select 
    a.id,
    a.member_id,
    a.member_card,
    a.account_status,
    a.card_type,
    a.card_type_name,
    a.start_time,
    '9999-12-31 00:00:00',
    a.source,
    a.insert_timestamp,
    '1970-01-01' as dt
from 
    DWD.DIM_Member_Card_Grade_SCD a 
left join 
    (select distinct account_log_id from ODS_CRM.account_log where [timestamp] > @ts) b
on a.id = b.account_log_id
where a.dt = @dt
and b.account_log_id is null

delete from DWD.DIM_Member_Card_Grade_SCD where dt = @dt;

with scd_di as (
    select 
        al.account_log_id,
        al.account_id as member_id,
        al.account_number as member_card,
        al.account_status,
        al.card_type,
        b.card_type_name,
        al.last_modified as start_time
    from
        ODS_CRM.account_log al
    left join
        ODS_CRM.knCard_Type b
    on 
        al.card_type = b.card_type_id 
    left join
        ODS_CRM.deleted_obj_record d
    on al.account_log_id = d.obj_id
    and d.from_table_name = 'account_log' 
    where  
        d.obj_id is null
    and al.[timestamp] > @ts
)

insert into DWD.DIM_Member_Card_Grade_SCD
select
    t.account_log_id,
    t.member_id,
    t.member_card,
    t.account_status,
    t.card_type,
    t.card_type_name,
    t.start_time,
    isnull(lead(start_time) over (partition by member_card order by account_log_id, start_time),'9999-12-31 00:00:00') as end_time,
    -- t.member_seq,
    'CRM' as source,
    current_timestamp  as insert_timestamp,
    @dt
from
(
    select 
        a.id as account_log_id,
        a.member_id, 
        a.member_card, 
        a.account_status,
        a.card_type,
        a.card_type_name,
        a.start_time
    from 
        DWD.DIM_Member_Card_Grade_SCD a
    join
    (
        select distinct member_card from scd_di
    ) b
    on a.member_card = b.member_card
    and cast(a.end_time as date) = '9999-12-31'
    where a.dt < @dt
    union all
    select 
        * 
    from 
        scd_di
) t
;
delete a from DWD.DIM_Member_Card_Grade_SCD a join  (
    select distinct account_number from ODS_CRM.account_log where [timestamp] > @ts
) b 
on a.member_card = b.account_number
where 
    a.dt < @dt 
and cast(a.end_time as date) = '9999-12-31';
END

GO
