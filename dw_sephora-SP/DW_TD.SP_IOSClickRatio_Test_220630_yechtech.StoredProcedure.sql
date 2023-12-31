/****** Object:  StoredProcedure [DW_TD].[SP_IOSClickRatio_Test_220630_yechtech]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_IOSClickRatio_Test_220630_yechtech] @date [datetime] AS


 SELECT
        'IOS' AS [OS],
        channel_name,
        format([clicktime], 'yyyy-MM-dd') AS [Date],
        case
            when appkey is NOT null then 'TD'
            else 'Additional'
        end as [Source],
        count(1) AS [TotalClickWithDeviceID]
		into #clickwithdevice
    FROM
        [ODS_TD].[Tb_IOS_Click_Arrange] --WHERE appkey is NOT null
	where [clicktime] >= dateadd(dd,-89,@date)
	and [clicktime] < dateadd(dd,1,@date)
    GROUP BY
        channel_name
        ,format([clicktime], 'yyyy-MM-dd'),
        case
            when appkey is NOT null then 'TD'
            else 'Additional'
        end


    SELECT
        'IOS' AS [OS],
        'TD' as [Source],
        channel_name,
        format([clicktime], 'yyyy-MM-dd') AS [Date],
        count(1) AS [TotalClick]
		into #click
    FROM
        [ODS_TD].[Tb_IOS_Click]
	where [clicktime] >= dateadd(dd,-89,@date)
	and [clicktime] <dateadd(dd,1,@date)
    GROUP BY
        channel_name
		,format([clicktime], 'yyyy-MM-dd')
    union
    all
    SELECT
        [OS],
        'Additional' as [Source],
        [Channel Name] as channel_name,
        format([Date], 'yyyy-MM-dd') AS [Date],
        count(1) as [TotalClick]
    FROM
        [ODS_TD].[Tb_IOS_AdditionalClick]
	where [Date] >= dateadd(dd,-89,@date)
	and [Date] < dateadd(dd,1,@date)
    group by
        format([Date], 'yyyy-MM-dd'),
        [OS],
        [Channel Name]

insert into [DW_TD].[Tb_Attribution_EventType_Ratio_Test_220630_yechtech]
select format(@date, 'yyyy-MM-dd') as [day],
'click' as type,
'IOS' as OS,
'90D Attribution' as [attribution_type],
t.channel_name,t.TotalClick,t.[TotalClickWithDeviceID] ,
case when isnull(t.[TotalClickWithDeviceID],0)=0 then 0 else 
cast(cast(t.TotalClick as float) /t.[TotalClickWithDeviceID] as decimal(18,2)) end as ratio
from (
select a.channel_name,sum(a.[TotalClick]) as TotalClick,sum(b.[TotalClickWithDeviceID]) as TotalClickWithDeviceID
from #click a 
    LEFT JOIN #clickwithdevice b ON a.OS = b.OS
	AND a.channel_name = b.channel_name
    AND a.[Date] = b.[Date]
	and a.[Source] = b.[Source]
	group by a.channel_name
) t 	
union
select format(@date, 'yyyy-MM-dd') as [day],
'click' as type,
'IOS' as OS,
'30D Attribution' as [attribution_type],
t.channel_name,t.TotalClick,t.[TotalClickWithDeviceID] ,
case when isnull(t.[TotalClickWithDeviceID],0)=0 then 0 else 
cast(cast(t.TotalClick as float) /t.[TotalClickWithDeviceID] as decimal(18,2)) end as ratio
from (
select a.channel_name,sum(a.[TotalClick]) as TotalClick,sum(b.[TotalClickWithDeviceID]) as TotalClickWithDeviceID
from (select * from #click 
       where [Date]>= dateadd(dd,-29,@date)and [Date] < dateadd(dd,1,@date))a 
    LEFT JOIN 
	(select * from #clickwithdevice 
	where [Date]>= dateadd(dd,-29,@date)and [Date] < dateadd(dd,1,@date))b ON a.OS = b.OS
	AND a.channel_name = b.channel_name
    AND a.[Date] = b.[Date]
	and a.[Source] = b.[Source]
	group by a.channel_name
) t 	
union
select format(@date, 'yyyy-MM-dd') as [day],
'click' as type,
'IOS' as OS,
'14D Attribution' as [attribution_type],
t.channel_name,t.TotalClick,t.[TotalClickWithDeviceID] ,
case when isnull(t.[TotalClickWithDeviceID],0)=0 then 0 else 
cast(cast(t.TotalClick as float) /t.[TotalClickWithDeviceID] as decimal(18,2)) end as ratio
from (
select a.channel_name,sum(a.[TotalClick]) as TotalClick,sum(b.[TotalClickWithDeviceID]) as TotalClickWithDeviceID
from (select * from #click 
       where [Date]>= dateadd(dd,-13,@date)and [Date] < dateadd(dd,1,@date))a 
    LEFT JOIN (select * from #clickwithdevice 
	where [Date]>= dateadd(dd,-13,@date)and [Date] < dateadd(dd,1,@date))b ON a.OS = b.OS
	AND a.channel_name = b.channel_name
    AND a.[Date] = b.[Date]
	and a.[Source] = b.[Source]
	group by a.channel_name
) t 	
union
select format(@date, 'yyyy-MM-dd') as [day],
'click' as type,
'IOS' as OS,
'7D Attribution' as [attribution_type],
t.channel_name,t.TotalClick,t.[TotalClickWithDeviceID] ,
case when isnull(t.[TotalClickWithDeviceID],0)=0 then 0 else 
cast(cast(t.TotalClick as float) /t.[TotalClickWithDeviceID] as decimal(18,2)) end as ratio
from (
select a.channel_name,sum(a.[TotalClick]) as TotalClick,sum(b.[TotalClickWithDeviceID]) as TotalClickWithDeviceID
from (select * from #click 
       where [Date]>= dateadd(dd,-6,@date)and [Date] < dateadd(dd,1,@date))a 
    LEFT JOIN 
	(select * from  #clickwithdevice 
	where [Date]>= dateadd(dd,-6,@date)and [Date] < dateadd(dd,1,@date))b  ON a.OS = b.OS
	AND a.channel_name = b.channel_name
    AND a.[Date] = b.[Date]
	and a.[Source] = b.[Source]
	group by a.channel_name
) t 
union
select format(@date, 'yyyy-MM-dd') as [day],
'click' as type,
'IOS' as OS,
'1D Attribution' as [attribution_type],
t.channel_name,t.TotalClick,t.[TotalClickWithDeviceID] ,
case when isnull(t.[TotalClickWithDeviceID],0)=0 then 0 else 
cast(cast(t.TotalClick as float) /t.[TotalClickWithDeviceID] as decimal(18,2)) end as ratio
from (
select a.channel_name,sum(a.[TotalClick]) as TotalClick,sum(b.[TotalClickWithDeviceID]) as TotalClickWithDeviceID
from (select * from #click 
       where [Date]>= dateadd(dd,-0,@date)and [Date] < dateadd(dd,1,@date) )a 
    LEFT JOIN (select * from  #clickwithdevice 
	where [Date]>= dateadd(dd,-0,@date)and [Date] < dateadd(dd,1,@date))b ON a.OS = b.OS
	AND a.channel_name = b.channel_name
    AND a.[Date] = b.[Date]
	and a.[Source] = b.[Source]
	group by a.channel_name
) t 	

drop  table  #clickwithdevice
drop  table  #click



GO
