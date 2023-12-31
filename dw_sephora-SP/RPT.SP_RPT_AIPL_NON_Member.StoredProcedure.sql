/****** Object:  StoredProcedure [RPT].[SP_RPT_AIPL_NON_Member]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_AIPL_NON_Member] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-15       litao          Initial Version 
-- ========================================================================================

DECLARE @statistics_date DATE 
SET @statistics_date = (select DATEADD(day,1,@dt));

--non_member
DELETE FROM [RPT].[RPT_AIPL_NON_Member] WHERE statistics_month=format(@statistics_date,'yyyy-MM') and table_name='non_member';
insert into [RPT].[RPT_AIPL_NON_Member]
select
  format(@statistics_date,'yyyy-MM') as statistics_month,
  count(distinct smartba_member_unionid) as smartba_member_unionid_quantity,
  'non_member' as table_name,
  current_timestamp as insert_timestamp
FROM 
(
    SELECT 
        unionid as [smartba_member_unionid],
        min(bind_time) as [first_bind_time],
        max(bind_time) as [last_bind_time]
    FROM 
    ( 
        SELECT 
            *, 
            row_number() over (partition by unionid, ba_staff_no order by bind_time desc) as ro
        FROM 
            [DWD].[Fact_Member_BA_Bind]
        WHERE 
          format(bind_time,'yyyy-MM-dd') between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date)) 
    ) temp1
    WHERE ro=1 
    AND status=0 
    GROUP BY unionid  
) a
LEFT JOIN 
(
    SELECT 
         DISTINCT [unionid],member_card
    FROM 
        [DWD].[Fact_Member_MNP_Register] 
    WHERE [status] = 1  
    and unionid is not null
) b 
ON a.smartba_member_unionid = b.unionid
where b.member_card is null
;

--non_member_app_uv

DELETE FROM [RPT].[RPT_AIPL_NON_Member] WHERE statistics_month=format(@statistics_date,'yyyy-MM') and table_name='non_member_app_uv';
insert into [RPT].[RPT_AIPL_NON_Member]
select
  format(@statistics_date,'yyyy-MM') as statistics_month,
  count(1) as non_member_app_uv,
  'non_member_app_uv' as table_name,
  current_timestamp as insert_timestamp
from 
(
    select 
         distinct user_id 
    from 
       [DW_Sensor].[DWS_Events_Session_Cutby30m]
    where vip_card is null 
    and upper(platform_type) ='APP'
    and date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date)) 
) a
left join
(
    select 
         distinct user_id
    from 
        [DW_Sensor].[DWS_Events_Session_Cutby30m] 
    where vip_card is not null 
    and upper(platform_type) ='APP'
    and date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date)) 
) b
on a.user_id=b.user_id
where b.user_id is null
;

END
GO
