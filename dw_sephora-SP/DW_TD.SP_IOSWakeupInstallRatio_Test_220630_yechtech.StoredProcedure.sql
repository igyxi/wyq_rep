/****** Object:  StoredProcedure [DW_TD].[SP_IOSWakeupInstallRatio_Test_220630_yechtech]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_IOSWakeupInstallRatio_Test_220630_yechtech] @date [datetime] AS


 --------Android install
-------install
create table #IOSInstall
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into #IOSInstall
select [active_time],'install',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Install
where [active_time] >=dateadd(dd,-89,@date)--@StartDate
and [active_time] < dateadd(dd,1,@date)--@EndDate
and [channel_name] not in ('Google Adwords','GoogleAdwords');


-----wakeup
create table #IOSWakeup
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)
insert into #IOSWakeup
select [deeplink_time],'Wakeup',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Wakeup
where [deeplink_time] >= dateadd(dd,-89,@date)--@StartDate
and [deeplink_time] < dateadd(dd,1,@date) --@EndDate
and [channel_name] not in ('Google Adwords','GoogleAdwords');


insert into [DW_TD].[Tb_Attribution_EventType_Ratio_Test_220630_yechtech]
select * from 
(
select 
[day],
'install' as [type],
'IOS' as [os],
'90D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSInstall
group by
[channel_name]
)t
union
select 
[day],
'install' as [type],
'IOS' as [os],
'30D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSInstall
where  [clicktime] >= dateadd(dd,-29,@date)and [clicktime] < dateadd(dd,1,@date)
group by
[channel_name]
)t
union
select 
[day],
'install' as [type],
'IOS' as [os],
'14D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSInstall
where  [clicktime] >= dateadd(dd,-13,@date)and [clicktime] < dateadd(dd,1,@date)
group by
[channel_name]
)t
union
select 
[day],
'install' as [type],
'IOS' as [os],
'7D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSInstall
where  [clicktime] >= dateadd(dd,-6,@date)and [clicktime] < dateadd(dd,1,@date)
group by
[channel_name]
)t
union
select 
[day],
'install' as [type],
'IOS' as [os],
'1D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSInstall
where  [clicktime] >= dateadd(dd,0,@date)and [clicktime] < dateadd(dd,1,@date)
group by
[channel_name]
)t
union
select 
[day],
'Wakeup' as [type],
'IOS' as [os],
'1D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSWakeup
where  clicktime >= dateadd(dd,0,@date)--@StartDate
and clicktime < dateadd(dd,1,@date) --@EndDate
group by
[channel_name]
)t
union all
select 
[day],
'Wakeup' as [type],
'IOS' as [os],
'7D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSWakeup
where  clicktime >= dateadd(dd,-6,@date)--@StartDate
and clicktime < dateadd(dd,1,@date) --@EndDate
group by
[channel_name]
)t
union all
select 
[day],
'Wakeup' as [type],
'IOS' as [os],
'14D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSWakeup
where  clicktime >= dateadd(dd,-13,@date)--@StartDate
and clicktime < dateadd(dd,1,@date) --@EndDate
group by
[channel_name]
)t
union all
select 
[day],
'Wakeup' as [type],
'IOS' as [os],
'30D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSWakeup
where  clicktime >= dateadd(dd,-29,@date)--@StartDate
and clicktime < dateadd(dd,1,@date) --@EndDate
group by
[channel_name]
)t
union all
select 
[day],
'Wakeup' as [type],
'IOS' as [os],
'90D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day],
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#IOSWakeup
group by
[channel_name]
)t
)t2
--order by [attribution_type]

drop table #IOSInstall
drop table #IOSWakeup



GO
