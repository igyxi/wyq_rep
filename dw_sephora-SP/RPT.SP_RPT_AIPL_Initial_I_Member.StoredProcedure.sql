/****** Object:  StoredProcedure [RPT].[SP_RPT_AIPL_Initial_I_Member]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_AIPL_Initial_I_Member] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By           Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-08       wangzhichun          Initial Version
-- ========================================================================================
declare @statistics_date date 
SET @statistics_date = (select dateadd(day,1,@dt));

delete from [RPT].[RPT_AIPL_Initial_I_Member] where statistics_month=format(@statistics_date,'yyyy-MM')
insert into [RPT].[RPT_AIPL_Initial_I_Member]
--Initial_I_App_MP
select 
    distinct
    format(@statistics_date,'yyyy-MM') as statistics_month,
    vip_card as member_card, 
    case when platform_type='MINIPROGRAM' then 'Miniprogram'
        else platform_type end  as channel, 
    upper(vip_card_type) as card_type,
    'Initial_I_App_MP' as table_name,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    [DW_Sensor].[DWS_Events_Session_Cutby30m]
where 
    vip_card IS NOT NULL 
    and platform_type in ('APP','MINIPROGRAM')  --[DW_Sensor].[DWS_Events_Session_Cutby30m]表对platform_type字段做过转化
    and date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
    and upper(vip_card_type) in (N'WHITE',N'PINK')

--Initial_I_Web
union all
SELECT 
    format(@statistics_date,'yyyy-MM') as statistics_month,
    member_card, 
    'Web' as channel, 
    case when card_type=1 then 'WHITE' else 'PINK' end as card_type,
    'Initial_I_Web' as table_name,
    CURRENT_TIMESTAMP as insert_timestamp
FROM 
    DWD.DIM_Member_Info 
where 
    register_date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
    and register_channel = 'SOA'
    and member_card is not null
    and card_type in (0,1)
union
select  
    format(@statistics_date,'yyyy-MM') as statistics_month,
    vip_card as member_card, 
    'Web' as channel, 
    vip_card_type AS card_type,
    'Initial_I_Web' as table_name,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    [DW_Sensor].[DWS_Events_Session_Cutby30m]
where vip_card IS NOT NULL
    and platform_type='PC'                        --[DW_Sensor].[DWS_Events_Session_Cutby30m]表对platform_type字段做过转化
    and vip_card_type in (N'WHITE',N'PINK')
    and date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))

--Initial_I_DY_JD_TM
union all 
SELECT 
    distinct 
    format(@statistics_date,'yyyy-MM') as statistics_month,
    member_card, 
    register_channel as channel, 
    case when card_type=1 then 'WHITE' else 'PINK' end as card_type,
    'Initial_I_DY_JD_TM' as table_name,
    CURRENT_TIMESTAMP as insert_timestamp
FROM
    DWD.DIM_Member_Info 
where register_date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
and register_channel in (N'JD',N'TMALL',N'DOUYIN') 
and member_card is not null
and card_type in (0,1)

--Initial_I_Offline
union all
select
    distinct 
    format(@statistics_date,'yyyy-MM') as statistics_month,
    member_card,
    'OFF_LINE' as channel,
    case when card_type=1 then 'WHITE' else 'PINK' end as card_type,
    'Initial_I_Offline' as table_name,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    DWD.DIM_Member_Info 
where register_date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
    and register_channel = 'OFF_LINE'
    and member_card is not null
    and card_type in (0,1)

union
select  
    format(@statistics_date,'yyyy-MM') as statistics_month,
    t1.member_card,
    'OFF_LINE' as channel,
    case when card_type=1 then 'WHITE' else 'PINK' end as card_type,
    'Initial_I_Offline' as table_name,
    CURRENT_TIMESTAMP as insert_timestamp
from 
(
    select
        distinct member_card
    FROM
    (
        SELECT 
            unionid as [smartba_member_unionid]
            -- min(bind_time) as [first bind time],
            -- max(bind_time) as [last bind time] 
        FROM 
        (
            SELECT 
                *, 
                row_number() over (partition by unionid, ba_staff_no order by bind_time desc) as ro
            FROM 
                [DWD].[Fact_Member_BA_Bind]
            WHERE format(bind_time,'yyyy-MM-dd') between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
        ) temp1
        WHERE ro=1 AND status=0 
        GROUP BY unionid
) a
left join
(
    SELECT 
        *
    FROM 
        [DWD].[Fact_Member_MNP_Register] 
    WHERE 
        [status] =1 and unionid is not null
) b
ON a.smartba_member_unionid = b.unionid
where member_card is not null
)t1
inner join 
(
    select  
        member_card, 
        card_type 
    from 
        dwd.dim_member_info
    where member_card is not null and card_type in (0,1)
) t2
on t1.member_card=t2.member_card
;
END 
GO
