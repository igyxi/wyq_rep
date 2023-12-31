/****** Object:  StoredProcedure [DW_TD].[SP_Android_Click_RowComp_Test_220630_yechtech]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_Android_Click_RowComp_Test_220630_yechtech] @StartDate [datetime],@EndDate [datetime] AS

declare @Start [datetime],@End [datetime]
set @Start=dateadd(dd,-89,@StartDate)
set @End = @EndDate


delete from DW_TD.Tb_Android_Click_RowComp_TEST_220630_yechtech
where [Date] >= @StartDate
and [Date] < @EndDate;

create table #andclick
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)


insert into #andclick

--点击事件
select *
from [ODS_TD].[Tb_Android_Click_Arrange]
where clicktime >= @Start
and clicktime < @End
and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（即将下线）',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'幽蓝互动',N'语斐')

union all

--激活事件

select distinct [active_time],'install',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].[Tb_Android_Install]
where [active_time] >= @Start--@StartDate
and [active_time] <@End --@EndDate


union all


--唤醒事件
select distinct deeplink_time,'wakeup',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].Tb_Android_Wakeup
where deeplink_time >= @Start--@StartDate
and deeplink_time < @End --@EndDate

;


with totalclick AS (
    SELECT
        'Android' AS [OS],
        'TD' as [Source],
        channel_name,
        @StartDate AS [Date],--format([clicktime], 'yyyy-MM-dd') AS [Date],
        count(1) AS [TotalClick]
    FROM  #andclick

        /* [ODS_TD].[Tb_Android_Click]
	where [clicktime] >= @StartDate
	and [clicktime] < @EndDate */
	--and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    GROUP BY
        channel_name
		--,format([clicktime], 'yyyy-MM-dd')
),
totalclickwithdevice AS (
    SELECT
       'Android' AS [OS],
        'TD' as [Source],
        channel_name,
        @StartDate AS [Date],--format([clicktime], 'yyyy-MM-dd') AS [Date],
        sum( case  WHEN isnull(androidid, N'') <> N'' THEN 1  ELSE 0 end ) AS [TotalClickWithDeviceID],
		count(1) AS [TotalClickWithDeviceIDOAID]
    FROM
        #andclick--WHERE appkey is NOT null --WHERE appkey is NOT null
	where [clicktime] >= @Start--@StartDate
	and [clicktime] < @End--@EndDate
	--and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'北京易彩',N'幽蓝互动',N'语斐')
    GROUP BY
        channel_name,
        -- format([clicktime], 'yyyy-MM-dd'),
        case
            when appkey is NOT null then 'TD'
            else 'Additional'
        end
),
installwithdevice as 
(
	SELECT 'Android' AS [OS], channel_name, format([active_time], 'yyyy-MM-dd') AS [Date], 'TD' AS [Source], sum(
    CASE
    WHEN isnull([android_id], N'') <> N'' THEN
    1
    ELSE 0
    END ) AS [TotalClickWithDeviceID]
FROM [ODS_TD].[Tb_Android_Install]
WHERE [active_time] >=@Start-- @StartDate
        AND [active_time] <@End-- @EndDate
		--and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
GROUP BY  channel_name, format([active_time], 'yyyy-MM-dd')
),
wakeupwithdevice as 
(
	SELECT 'Android' AS [OS], channel_name, format([deeplink_time], 'yyyy-MM-dd') AS [Date], 'TD' AS [Source], sum(
    CASE
    WHEN isnull([android_id], N'') <> N'' THEN
    1
    ELSE 0
    END ) AS [TotalClickWithDeviceID]
FROM [ODS_TD].[Tb_Android_Wakeup]
WHERE [deeplink_time] >= @Start--@StartDate
        AND [deeplink_time] <@End-- @EndDate
		--and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
GROUP BY  channel_name, format([deeplink_time], 'yyyy-MM-dd')
)

insert into DW_TD.Tb_Android_Click_RowComp_TEST_220630_yechtech
SELECT
    a.OS,
    a.channel_name,
    a.[Date],
	a.[Source],
    a.[TotalClick],
    isnull(b.[TotalClickWithDeviceID], 0) AS [TotalClickWithDeviceID],
    isnull(b.[TotalClickWithDeviceIDOAID], 0) AS [TotalClickWithDeviceIDOAID],
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


drop table #andclick
GO
