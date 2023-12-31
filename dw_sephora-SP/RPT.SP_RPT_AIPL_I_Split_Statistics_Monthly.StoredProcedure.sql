/****** Object:  StoredProcedure [RPT].[SP_RPT_AIPL_I_Split_Statistics_Monthly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_AIPL_I_Split_Statistics_Monthly] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-02       litao          Initial Version
-- ========================================================================================

DECLARE @statistics_date DATE 
SET @statistics_date = (select DATEADD(day,1,@dt)); 


--Logged in、Viewed PDP、Added to cart
delete from [RPT].[RPT_AIPL_I_Split_Statistics_Monthly] where statistics_month=format(@statistics_date, 'yyyy-MM') and i_stage in ('Deep_I_PDP','Deep_I_Cart','Initial_I_Login');
with i_stage_events as
(
    select
        distinct vip_card as member_card,
        --platform_type as channel,
        case when event= 'viewCommodityDetail' then 'Deep_I_PDP'
             when event like '%AddToShoppingcart%' then 'Deep_I_Cart'
        else 'other' end as stage_flag 
    from
        [DW_Sensor].[DWS_Events_Session_Cutby30m]
    where
        vip_card IS NOT NULL
        and date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
) 

insert into [RPT].[RPT_AIPL_I_Split_Statistics_Monthly]
select 
    format(@statistics_date,'yyyy-MM') as statistics_month,
    P.SupplyNum as member_card_quantity,
    P.Supplier as i_stage,
    current_timestamp as insert_timestamp 
from 
(
select 
    count(distinct t1.member_card) as Initial_I_Login,
    count(distinct case when t1.stage_flag='Deep_I_PDP' then t1.member_card end) as Deep_I_PDP,
    count(distinct case when t1.stage_flag='Deep_I_Cart' then t1.member_card end) as Deep_I_Cart 
from 
    i_stage_events t1
left join
(
    select
        member_card,
        card_type
    from
        (
        select
            member_card,
            card_type,
            row_number() over (partition by member_card order by start_time desc) as ro
        from
            [DWD].[DIM_Member_Card_Grade_SCD]
        where
            format(start_time,'yyyy-MM-dd') <= EOMONTH(DATEADD(month,-1,@statistics_date))
        ) temp
    where
        ro = 1
        and member_card is not null
        and card_type in (0, 1) 
) t2
on
    t1.member_card = t2.member_card
where
    t2.card_type is not null
) tab 
UNPIVOT 
(
    SupplyNum FOR Supplier IN
    (Initial_I_Login, Deep_I_PDP,Deep_I_Cart)
) P
;

--added BA
delete from [RPT].[RPT_AIPL_I_Split_Statistics_Monthly] where statistics_month=format(@statistics_date, 'yyyy-MM') and i_stage='Initial_I_BA';
insert into [RPT].[RPT_AIPL_I_Split_Statistics_Monthly]
select
    format(@statistics_date,'yyyy-MM') as statistics_month,
    count(distinct t1.member_card) as member_card_quantity,
    'Initial_I_BA' as i_stage,
    current_timestamp as insert_timestamp
from
    (
    select
        distinct member_card
    FROM
        (
        SELECT
            unionid as [smartba_member_unionid],
            min(bind_time) as [first bind time],
            max(bind_time) as [last bind time]
        FROM
            (
            SELECT
                *,
                row_number() over (partition by unionid,ba_staff_no order by bind_time desc) as ro
            FROM
                [DWD].[Fact_Member_BA_Bind]
            WHERE
                format(bind_time,'yyyy-MM-dd') between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date)) 
            ) temp1
        WHERE
            ro = 1
            AND status = 0
        GROUP BY
            unionid
) a
    LEFT JOIN
(
        SELECT
            *
        FROM
            [DWD].[Fact_Member_MNP_Register]
        WHERE
            [status] = 1
            and unionid is not null
) b
ON
        a.smartba_member_unionid = b.unionid
    where
        member_card is not null
) t1
left join 
 (
    select
        member_card,
        card_type
    from
        (
        select
            member_card,
            card_type,
            row_number() over (partition by member_card order by start_time desc) as ro
        from
            [DWD].[DIM_Member_Card_Grade_SCD]
        where
            format(start_time,'yyyy-MM-dd') <= EOMONTH(DATEADD(month,-1,@statistics_date))
        ) temp
    where
        ro = 1
        and member_card is not null
        and card_type in (0, 1) 
  ) t2
on
    t1.member_card = t2.member_card
where
    card_type is not null
;

 
--serviced in stores
delete from [RPT].[RPT_AIPL_I_Split_Statistics_Monthly] where statistics_month=format(@statistics_date, 'yyyy-MM') and i_stage='Deep_I_Service';
insert into [RPT].[RPT_AIPL_I_Split_Statistics_Monthly]
select
    format(@statistics_date,'yyyy-MM') as statistics_month,
    count(distinct t1.member_card) as member_card_quantity,
    'Deep_I_Service' as i_stage,
    current_timestamp as insert_timestamp 
from
    (
    SELECT
        distinct(member_card)
    FROM
        [DWD].[Fact_InStore_Service]
    where
        (status = N'已签到' or status = N'已评价')
        and member_card is not null
        and complete_time between DATEADD(year,-1, EOMONTH (DATEADD(month,-1, getdate()))) and EOMONTH (DATEADD(month,-1, getdate()))
    ) t1
left join 
   (
      select
          member_card,
          card_type
      from
          (
          select
              member_card,
              card_type,
              row_number() over (partition by member_card order by start_time desc) as ro
          from
              [DWD].[DIM_Member_Card_Grade_SCD]
          where
              format(start_time,'yyyy-MM-dd')<= EOMONTH(DATEADD(month,-1,@statistics_date))
          ) temp
      where
          ro = 1
          and member_card is not null
          and card_type in (0, 1) 
    ) t2
on
    t1.member_card = t2.member_card
where
    t2.card_type is not null
;
END
 
GO
