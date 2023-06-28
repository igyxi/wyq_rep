/****** Object:  StoredProcedure [TEMP].[SP_DIM_Member_Card_Grade_SCD_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Member_Card_Grade_SCD_Bak_20230518] @dt [VARCHAR](10) AS
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
-- 2023-05-11       leozhai     change source table to ODS_CRM.account_upgrade_downgrade_log
-- ========================================================================================

truncate table DWD.DIM_Member_Card_Grade_SCD;

with scd_di as (
    select 
        al.up_down_log_id,
        al.account_id as member_id,
        al.account_number as member_card,
        null as account_status,
        al.card_type,
        b.card_type_name,
        al.start_card_type_time as start_time
    from
        ODS_CRM.account_upgrade_downgrade_log al
    left join
        ODS_CRM.knCard_Type b
    on 
        al.card_type = b.card_type_id 
    where  
        al.type <> 3
)

insert into DWD.DIM_Member_Card_Grade_SCD
select
    t.up_down_log_id,
    t.member_id,
    t.member_card,
    t.account_status,
    t.card_type,
    t.card_type_name,
    t.start_time,
    isnull(lead(start_time) over (partition by member_card order by start_time),'9999-12-31 00:00:00') as end_time,
    -- t.member_seq,
    'CRM' as source,
    current_timestamp  as insert_timestamp,
    @dt
from
    scd_di t
;

END

GO
