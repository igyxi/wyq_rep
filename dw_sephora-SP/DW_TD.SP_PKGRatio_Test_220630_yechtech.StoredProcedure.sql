/****** Object:  StoredProcedure [DW_TD].[SP_PKGRatio_Test_220630_yechtech]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_PKGRatio_Test_220630_yechtech] @date [datetime] AS


 --------Android install
-------install
create table #pkgData
(
	clicktime date,
	pkg_key nvarchar(255),
	androidid nvarchar(255),
	campaign_name nvarchar(255)
)


insert into #pkgData
select active_time,pkg_key,android_id,campaign_name
from [ODS_TD].[Tb_PKG_Install]
where [active_time] >= dateadd(dd,-89,@date)--@StartDate
and [active_time] < dateadd(dd,1,@date) --@EndDate
--and isnull(campaign_name,'')=''

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
format(@date,'yyyy-MM-dd') as [day] ,'PKG' as [channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
 #pkgData
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
format(@date,'yyyy-MM-dd')  as [day] ,'PKG' as [channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
 #pkgData
where  [clicktime] >= dateadd(dd,-29,@date)and [clicktime] < dateadd(dd,1,@date) 
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
format(@date,'yyyy-MM-dd')  as [day] ,'PKG' as [channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#pkgData
where  [clicktime] >= dateadd(dd,-13,@date)and [clicktime] < dateadd(dd,1,@date) 
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
format(@date,'yyyy-MM-dd') as [day] ,'PKG' as [channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#pkgData
where  [clicktime] >= dateadd(dd,-6,@date)and [clicktime] < dateadd(dd,1,@date) 
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
format(@date,'yyyy-MM-dd') as [day] ,'PKG' as [channel_name],
count(*) as TotalClick,
sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) as TotalClickWithDeviceID
from 
#pkgData
where  [clicktime] >= dateadd(dd,0,@date)and [clicktime] < dateadd(dd,1,@date) 
)t
)t2
--order by attribution_type

drop table  #pkgData



GO
