/****** Object:  StoredProcedure [DWD].[INI_DIM_Member_Card_Grade_SCD]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[INI_DIM_Member_Card_Grade_SCD] @dt [varchar](10) AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-08       tali           add id
-- ========================================================================================
truncate table DWD.DIM_Member_Card_Grade_SCD;

DECLARE @ts bigint = null;
select 
    -- get max timestamp of the day before 
    @ts = max_timestamp 
from 
(
    select  *, row_number() over(order by last_update_time desc) rownum
    from [Management].[Table_Last_Update_Logging] 
    where CONCAT([schema],'.',[table]) = 'ODS_CRM.ACCOUNT_LOG' 
    and last_update_time between @dt and DATEADD(day, 1, @dt)
) t
where rownum = 1;

insert into DWD.DIM_Member_Card_Grade_SCD
select
    account_log_id as id,
    account_id as member_id,
    account_number as member_card,
    account_status,
    card_type,
    card_type_name,
    last_modified as start_time,
    isnull(lead(t.last_modified) over (partition by t.account_number order by t.account_log_id, t.last_modified), '9999-12-31 00:00:00') as end_time,
    'CRM' as source,
    CURRENT_TIMESTAMP,
    format(dateadd(day, -1, @dt), 'yyyy-MM-dd') dt
from
(
    select 
        al.account_log_id,
        al.account_id,
        al.account_number,
        al.account_status,
        al.card_type,
        b.card_type_name,
        al.last_modified
    from
        ODS_CRM.account_log al
    left join
        ODS_CRM.deleted_obj_record d
    on al.account_log_id = d.obj_id
    and d.from_table_name = 'account_log' 
    left join
        ODS_CRM.knCard_Type b
    on 
        al.card_type = b.card_type_id
    where  
        d.obj_id is null
    and al.timestamp <= @ts
) t
;
END

GO
