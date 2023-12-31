/****** Object:  StoredProcedure [DWD].[SP_DIM_Member_Card_Grade_SCD_DI]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Member_Card_Grade_SCD_DI] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       Eric    Initial Version
-- ========================================================================================
truncate table DWD.DIM_Member_Card_Grade_SCD_DI;
with account_log AS
(
    select
        a.account_id,
        a.account_status,
        a.card_type,
        a.last_modified,
        b.card_type_name COLLATE Chinese_PRC_CS_AI_WS as card_type_name
    FROM
    (
        select 
            account_id,
            account_status,
            card_type,
            last_modified
        FROM
            ODS_CRM.DimAccount_Log 
        where 
            process_time > @dt
    )a
    left join
        ODS_CRM.knCard_Type b
    on 
        a.card_type = b.card_type_id
    left JOIN
    (
        select
            member_id,
            start_time
        from
            DWD.DIM_Member_Card_Grade_SCD
        where 
            end_time = '9999-12-31'
    )c
    ON
        a.account_id = c.member_id
    where
        a.last_modified > c.start_time
    or 
        c.member_id is null 
)

insert into DWD.DIM_Member_Card_Grade_SCD_DI
select 
    a.member_id,
    a.member_status,
    a.card_type,
    a.card_type_name,
    a.start_time,
    b.last_modified as end_time,
    current_timestamp as insert_timestamp
from
(
    select
        member_id,
        member_status,
        card_type,
        card_type_name,
        start_time,
        end_time
    from
        DWD.DIM_Member_Card_Grade_SCD
    where 
        end_time = '9999-12-31'
)a
inner join 
(
    select
        account_id,
        account_status,
        card_type,
        card_type_name,
        last_modified
    from
    (
        SELECT
            account_id,
            account_status,
            card_type,
            card_type_name,
            last_modified,
            row_number() over (partition by account_id order by last_modified) as rownum
        from
            account_log
    )t
    where rownum = 1
) b
on a.member_id = b.account_id
union all
SELECT
    a.account_id,
    a.account_status,
    a.card_type,
    a.card_type_name,
    a.last_modified as start_time,
    coalesce(lead(last_modified) over (partition by a.account_id order by a.last_modified),'9999-12-31') as end_time,
    current_timestamp as insert_timestamp
from
    account_log a
;
END
GO
