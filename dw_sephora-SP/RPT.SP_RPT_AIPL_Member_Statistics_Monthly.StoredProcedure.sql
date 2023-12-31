/****** Object:  StoredProcedure [RPT].[SP_RPT_AIPL_Member_Statistics_Monthly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_AIPL_Member_Statistics_Monthly] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-02       litao          Initial Version
-- ========================================================================================

DECLARE @statistics_date DATE 
SET @statistics_date = (select DATEADD(day,1,@dt)); 


--p1,2,3aipl trend
delete from [RPT].[RPT_AIPL_Member_Statistics_Monthly] where statistics_month=format(@statistics_date, 'yyyy-MM') and aipl_stage in ('IPL_All','IPL_Deep','IPL_PL','IPL_L');
insert into [RPT].[RPT_AIPL_Member_Statistics_Monthly]
select 
    format(@statistics_date,'yyyy-MM') as statistics_month,
    P.SupplyNum as member_card_quantity,
    P.Supplier as aipl_stage,
    current_timestamp as insert_timestamp
from 
(
    select 
       count(distinct member_card)  as IPL_All,
       count(distinct member_card1) as IPL_Deep,
       count(distinct member_card2) as IPL_PL,
       count(distinct member_card3) as IPL_L 
    from 
        (
            SELECT 
                 distinct 
                 member_card,
                 null as member_card1,
                 null as member_card2,
                 null as member_card3 
            from RPT.RPT_AIPL_Initial_I_Member 
            where statistics_month = format(@statistics_date,'yyyy-MM')
            union
            SELECT distinct 
                   member_card,
                   member_card as member_card1,
                   null as member_card2,
                   null as member_card3 
            from RPT.RPT_AIPL_Deep_I_Member 
            where statistics_month = format(@statistics_date,'yyyy-MM')
            union
            SELECT distinct 
                   member_card,
                   member_card as member_card1,
                   member_card as member_card2,
                   null as member_card3 
            from RPT.RPT_AIPL_Purchase_Member 
            where statistics_month = format(@statistics_date,'yyyy-MM')
            union
            SELECT distinct 
                   member_card,
                   member_card as member_card1,
                   member_card as member_card2,
                   member_card as member_card3 
            from RPT.RPT_AIPL_Loyalty_Member 
            where statistics_month = format(@statistics_date,'yyyy-MM')
        ) t 
    ) tab 
UNPIVOT 
    (
        SupplyNum FOR Supplier IN
        (IPL_All,IPL_Deep,IPL_PL,IPL_L)
    ) P
;

--Reactivate
delete from [RPT].[RPT_AIPL_Member_Statistics_Monthly] where statistics_month=format(@statistics_date, 'yyyy-MM') and aipl_stage in ('Reactivate');
insert into [RPT].[RPT_AIPL_Member_Statistics_Monthly]
select
    format(@statistics_date,'yyyy-MM') as statistics_month,
    count(distinct t1.member_card) as member_card_quantity,
    'Reactivate' as aipl_stage,
    current_timestamp as insert_timestamp
from
    (
    select
        distinct member_card
    from
        DWD.Fact_Sales_Order
    where
        format(payment_time,'yyyy-MM-dd') between cast(DATEADD(year,-3, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
        and member_card is not null
        and item_apportion_amount>0
        and is_placed = 1
        and member_card_grade in ('WHITE')
    ) t1
left join 
(
    select
        distinct t2.member_card,
        t2.statistics_month
    from
        (
        SELECT distinct member_card,statistics_month
        from
            RPT.RPT_AIPL_Initial_I_Member
        where
            statistics_month = format(@statistics_date,'yyyy-MM')
    union
        SELECT
            distinct member_card,
            statistics_month
        from
            RPT.RPT_AIPL_Deep_I_Member
        where
            statistics_month = format(@statistics_date,'yyyy-MM')
    union
        SELECT
            distinct member_card,
            statistics_month
        from
            RPT.RPT_AIPL_Purchase_Member
        where
            statistics_month = format(@statistics_date,'yyyy-MM')
    union
        SELECT
            distinct member_card,
            statistics_month
        from
            RPT.RPT_AIPL_Loyalty_Member
        where
            statistics_month = format(@statistics_date,'yyyy-MM')
        )t2
  )t3
on
    t1.member_card = t3.member_card
where
    t3.statistics_month is null

--p4,5,6aipl trend
delete from [RPT].[RPT_AIPL_Member_Statistics_Monthly] where statistics_month=format(@statistics_date, 'yyyy-MM') and aipl_stage in ('IPL_Initial_I','IPL_Deep_I','IPL_P');
insert into [RPT].[RPT_AIPL_Member_Statistics_Monthly]
select
    format(@statistics_date,'yyyy-MM') as statistics_month,
    count(distinct t1.member_card) as member_card_quantity,
    'IPL_Initial_I' as aipl_stage,
    current_timestamp as insert_timestamp
from
    (
    SELECT
        distinct member_card
    from
        RPT.RPT_AIPL_Initial_I_Member
    where
        statistics_month = format(@statistics_date,'yyyy-MM')
    ) t1
left join 
(
    select
        distinct t2.member_card,
        1 as ro
    from
        (
        select
            distinct member_card
        from
            RPT.RPT_AIPL_Deep_I_Member
        where
            statistics_month = format(@statistics_date,'yyyy-MM')
    union
        SELECT
            distinct member_card
        from
            RPT.RPT_AIPL_Purchase_Member
        where
            statistics_month = format(@statistics_date,'yyyy-MM')
)t2
) t3
on
    t1.member_card = t3.member_card
where
    t3.ro is null

union all
select
    format(@statistics_date,'yyyy-MM') as statistics_month,
    count(distinct t1.member_card) as member_card_quantity,
    'IPL_Deep_I' as aipl_stage,
    current_timestamp as insert_timestamp
from
    (
    SELECT
        distinct member_card
    from
        RPT.RPT_AIPL_Deep_I_Member
    where
        statistics_month = format(@statistics_date,'yyyy-MM')
    ) t1
left join 
(
    SELECT
        distinct member_card,
        1 as ro
    from
        RPT.RPT_AIPL_Purchase_Member
    where
        statistics_month = format(@statistics_date,'yyyy-MM')
) t2
on
    t1.member_card = t2.member_card
where
    t2.ro is null

union all 
select
    format(@statistics_date,'yyyy-MM') as statistics_month,
    count(distinct t1.member_card) as member_card_quantity,
    'IPL_P' as aipl_stage,
    current_timestamp as insert_timestamp
from
    (
    SELECT
        distinct member_card
    from
        RPT.RPT_AIPL_Purchase_Member
    where
        statistics_month = format(@statistics_date,'yyyy-MM')
    ) t1
left join 
(
    SELECT
        distinct member_card,
        1 as ro
    from
        RPT.RPT_AIPL_Loyalty_Member
    where
        statistics_month = format(@statistics_date,'yyyy-MM')
    ) t2
on
    t1.member_card = t2.member_card
where
    t2.ro is null

END
GO
