/****** Object:  StoredProcedure [DW_TD].[SP_AnroidWakeupInstallRatio_Test_220630_yechtech]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_AnroidWakeupInstallRatio_Test_220630_yechtech] @date [datetime] AS


 --------Android install
create table #andinstall
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)


insert into #andinstall
select  [active_time],'install',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].[Tb_Android_Install]
where [active_time] >= dateadd(dd,-89,@date)--@StartDate
and [active_time] < dateadd(dd,1,@date) --@EndDate

----------Android Wakeup
create table #andwakup
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)
insert into #andwakup
select [deeplink_time],'Wakeup',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].[Tb_Android_Wakeup]
where [deeplink_time] >= dateadd(dd,-89,@date)--@StartDate
and [deeplink_time] < dateadd(dd,1,@date) --@EndDate


insert into [DW_TD].[Tb_Attribution_EventType_Ratio_Test_220630_yechtech]
select * from (
select 
[day],
'install' as [type],
'Android' as [os],
'90D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day] ,[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andinstall
group by
[channel_name]
)t
union
select 
[day],
'install' as [type],
'Android' as [os],
'30D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day] ,[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andinstall
where  [clicktime] >= dateadd(dd,-29,@date)and [clicktime] < dateadd(dd,1,@date) 
group by
[channel_name]
)t
union
select 
[day],
'install' as [type],
'Android' as [os],
'14D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day] ,[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andinstall
where  [clicktime] >= dateadd(dd,-13,@date)and [clicktime] < dateadd(dd,1,@date) 
group by
[channel_name]
)t
union
select 
[day],
'install' as [type],
'Android' as [os],
'7D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day] ,[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andinstall
where  [clicktime] >= dateadd(dd,-6,@date)and [clicktime] < dateadd(dd,1,@date) 
group by
[channel_name]
)t
union
select 
[day],
'install' as [type],
'Android' as [os],
'1D Attribution' as [attribution_type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
format(@date,'yyyy-MM-dd') as [day] ,[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andinstall
where  [clicktime] >= dateadd(dd,0,@date)and [clicktime] < dateadd(dd,1,@date) 
group by
[channel_name]
)t
union 
select 
format(@date,'yyyy-MM-dd') as [day],
'Wakeup' as [type],
'Android' as [os],
'1D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andwakup
where  clicktime >= dateadd(dd,0,@date)--@StartDate
and clicktime < dateadd(dd,1,@date) --@EndDate
group by
[channel_name]
)t
union all
select 
format(@date,'yyyy-MM-dd') as [day],
'Wakeup' as [type],
'Android' as [os],
'7D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andwakup
where  clicktime >= dateadd(dd,-6,@date)--@StartDate
and clicktime < dateadd(dd,1,@date) --@EndDate
group by
[channel_name]
)t
union all
select 
format(@date,'yyyy-MM-dd') as [day],
'Wakeup' as [type],
'Android' as [os],
'14D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andwakup
where  clicktime >= dateadd(dd,-13,@date)--@StartDate
and clicktime < dateadd(dd,1,@date)--@EndDate
group by
[channel_name]
)t
union all
select 
format(@date,'yyyy-MM-dd') as [day],
'Wakeup' as [type],
'Android' as [os],
'30D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andwakup
where  clicktime >= dateadd(dd,-29,@date)--@StartDate
and clicktime < dateadd(dd,1,@date)--@EndDate
group by
[channel_name]
)t
union all
select 
format(@date,'yyyy-MM-dd') as [day],
'Wakeup' as [type],
'Android' as [os],
'90D Attribution' as [attribution type],
[channel_name],
TotalClick,
TotalClickWithDeviceID,
cast (isnull ((cast(TotalClick as float)/ NULLIF(TotalClickWithDeviceID , 0)),0) as decimal(10,2)) as rate
from 
(
select
[channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#andwakup
group by
[channel_name]
)t
)t2
--order by attribution_type


drop table #andinstall
drop table #andwakup



GO
