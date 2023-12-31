/****** Object:  StoredProcedure [DW_TD].[SP_IOS_Click_RowComp_Test_220630_yechtech]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_IOS_Click_RowComp_Test_220630_yechtech] @StartDate [datetime],@EndDate [datetime] AS

declare @Start [datetime],@End [datetime]
set @Start=dateadd(dd,-89,@StartDate)
set @End = @EndDate


delete from DW_TD.Tb_IOS_Click_RowComp_Test_220630_yechtech
where [Date] >= @StartDate
and [Date] < @EndDate;

create table #iosclick
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into #iosclick
--点击事件
select *
from [ODS_TD].Tb_IOS_Click_Arrange
where clicktime >= @Start
and clicktime < @End
-- and [channel_name] not in ('Google Adwords','GoogleAdwords')
and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（即将下线）',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'语斐',N'幽蓝互动')

union all 

--激活事件

select distinct [active_time],'install',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Install
where [active_time] >= @Start--@StartDate
and [active_time] < @End-- @EndDate
and [channel_name] not in ('Google Adwords','GoogleAdwords')


union all

--唤醒事件
select distinct deeplink_time,'wakeup',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Wakeup
where deeplink_time >=@Start--@StartDate
and deeplink_time < @End--@EndDate
and [channel_name] not in ('Google Adwords','GoogleAdwords')
;

with totalclick AS (
    SELECT
        'IOS' AS [OS],
        'TD' as [Source],
        channel_name,
        @StartDate AS [Date],--([clicktime], 'yyyy-MM-dd') AS [Date],15日修改
        count(1) AS [TotalClick]
    FROM  #iosclick
        /* [ODS_TD].[Tb_IOS_Click]
	where [clicktime] >= @StartDate
	and [clicktime] < @EndDate*/
	--and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
    GROUP BY
        channel_name
		--,format([clicktime], 'yyyy-MM-dd') 15日修改
),
totalclickwithdevice AS (
    SELECT
       'IOS' AS [OS],
        'TD' as [Source],
        channel_name,
        @StartDate AS [Date],--format([clicktime], 'yyyy-MM-dd') AS [Date],15日修改
        sum( case  WHEN isnull(idfa, N'') <> N'' THEN 1  ELSE 0 end ) AS [TotalClickWithDeviceID] 
    FROM
        #iosclick --WHERE appkey is NOT null
	where [clicktime] >= @Start--@StartDate
	and [clicktime] <@End--@EndDate
	--and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'北京易彩',N'幽蓝互动',N'语斐',N'Google Adwords',N'GoogleAdwords')
    GROUP BY
        channel_name,
        --format([clicktime], 'yyyy-MM-dd'),15日修改
        case
            when appkey is NOT null then 'TD'
            else 'Additional'
        end
),
installwithdevice as 
(
	SELECT 'IOS' AS [OS], channel_name, format([active_time], 'yyyy-MM-dd') AS [Date], 'TD' AS [Source], sum(
    CASE
    WHEN isnull([idfa], N'') <> N'' THEN
    1
    ELSE 0
    END ) AS [TotalClickWithDeviceID]
FROM [ODS_TD].[Tb_IOS_Install]
WHERE [active_time] >= @Start--@StartDate
        AND [active_time] < @End --@EndDate
		--and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
GROUP BY  channel_name, format([active_time], 'yyyy-MM-dd')
),
wakeupwithdevice as 
(
	SELECT 'IOS' AS [OS], channel_name, format([deeplink_time], 'yyyy-MM-dd') AS [Date], 'TD' AS [Source], sum(
    CASE
    WHEN isnull([idfa], N'') <> N'' THEN
    1
    ELSE 0
    END ) AS [TotalClickWithDeviceID]
FROM [ODS_TD].[Tb_IOS_Wakeup]
WHERE [deeplink_time] >= @Start--@StartDate
        AND [deeplink_time] < @End--@EndDate
		--and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'Google Adwords',N'GoogleAdwords')
GROUP BY  channel_name, format([deeplink_time], 'yyyy-MM-dd')
)

insert into DW_TD.Tb_IOS_Click_RowComp_Test_220630_yechtech
SELECT
    a.OS,
    a.channel_name,
    a.[Date],
	a.[Source],
    a.[TotalClick],
    isnull(b.[TotalClickWithDeviceID],0) AS [TotalClickWithDeviceID],
	isnull(c.[TotalClickWithDeviceID],0) as [TotalInstallWithDeviceID],
	isnull(d.[TotalClickWithDeviceID],0) as [TotalWakeupWithDeviceID]
FROM
    totalclick a
    LEFT JOIN totalclickwithdevice b ON a.OS = b.OS
    AND a.channel_name = b.channel_name
    AND a.[Date] = b.[Date]
	and a.[Source] = b.[Source]
	left join installwithdevice c
	ON a.OS = c.OS
    AND a.channel_name = c.channel_name
    AND a.[Date] = c.[Date]
	and a.[Source] = c.[Source]
	left join wakeupwithdevice d
	ON a.OS = d.OS
    AND a.channel_name = d.channel_name
    AND a.[Date] = d.[Date]
	and a.[Source] = d.[Source]

   drop table #iosclick
GO
