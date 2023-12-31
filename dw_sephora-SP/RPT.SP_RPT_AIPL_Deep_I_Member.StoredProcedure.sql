/****** Object:  StoredProcedure [RPT].[SP_RPT_AIPL_Deep_I_Member]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_AIPL_Deep_I_Member] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-08       litao          Initial Version
-- ========================================================================================

DECLARE @statistics_date DATE 
SET @statistics_date = (select DATEADD(day,1,@dt));

DELETE FROM [RPT].[RPT_AIPL_Deep_I_Member] WHERE statistics_month=format(@statistics_date,'yyyy-MM');  
insert into [RPT].[RPT_AIPL_Deep_I_Member]
select 
distinct 
format(@statistics_date,'yyyy-MM') as statistics_month,
vip_card as member_card, 
case when platform_type='APP' then 'APP'
     when platform_type='MINIPROGRAM' then 'MiniProgram'
     when platform_type='PC' then 'Web'
     when platform_type='MOBILE' then 'Mobile'
end as channel, 
vip_card_type as card_type, 
'Deep_I_App_MP_Web' as table_name,
CURRENT_TIMESTAMP insert_timestamp
from [DW_Sensor].[DWS_Events_Session_Cutby30m]
where event ='viewCommodityDetail'
and platform_type in ('APP', 'MINIPROGRAM', 'PC', 'MOBILE') --DWS_Events_Session_Cutby30m表platform_type字段逻辑做过转化
and vip_card is not null
and vip_card_type not in ('BLACK', 'GOLDEN','TEST','O2O','EMPLOYEE')
and date between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
union all
SELECT 
distinct
format(@statistics_date,'yyyy-MM') as statistics_month,
(member_card),
'InStoreService' as channel,
case when card_type=N'粉卡' then 'PINK'
     when card_type=N'白卡' then 'WHITE'
end as card_type,
'Deep_I_Offline' as table_name,
CURRENT_TIMESTAMP insert_timestamp
FROM [DWD].[Fact_InStore_Service] 
where (status = N'已签到' or status = N'已评价') 
and member_card is not null
and format(complete_time,'yyyy-MM-dd') between cast(DATEADD(year,-1, DATEADD(mm,DATEDIFF(mm,0,@statistics_date),0)) as date) and EOMONTH(DATEADD(month,-1,@statistics_date))
and card_type in (N'粉卡',N'白卡')
;

END
GO
