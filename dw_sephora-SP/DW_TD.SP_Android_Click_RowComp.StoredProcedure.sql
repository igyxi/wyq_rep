/****** Object:  StoredProcedure [DW_TD].[SP_Android_Click_RowComp]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_Android_Click_RowComp] @StartDate [datetime],@EndDate [datetime] AS

delete from DW_TD.Tb_Android_Click_RowComp
where [Date] >= @StartDate
and [Date] < @EndDate;

with totalclick AS (
    SELECT
        'Android' AS [OS],
        'TD' as [Source],
        channel_name,
        format([clicktime], 'yyyy-MM-dd') AS [Date],
        count(1) AS [TotalClick]
    FROM [ODS_TD].[Tb_Android_Click]
	where [clicktime] >= @StartDate
        and [clicktime] < @EndDate
        and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    GROUP BY channel_name,format([clicktime], 'yyyy-MM-dd')
    union all
    SELECT
        [OS],
        'Additional' as [Source],
        [Channel Name] as channel_name,
        format([Date], 'yyyy-MM-dd') AS [Date],
        count(1) as [TotalClick]
    FROM [ODS_TD].[Tb_Android_AdditionalClick]
	where [Date] >= @StartDate
	    and [Date] < @EndDate
    group by format([Date], 'yyyy-MM-dd'),[OS],[Channel Name]
),
totalclickwithdevice AS (
    SELECT
        'Android' AS [OS],
        channel_name,
        format([clicktime], 'yyyy-MM-dd') AS [Date],
        case
            when appkey is NOT null then 'TD'
            else 'Additional'
        end as [Source],
        sum(
            case
                WHEN isnull(androidid, N'') <> N'' THEN 1
                ELSE 0
            end
        ) AS [TotalClickWithDeviceID],
        count(1) AS [TotalClickWithDeviceIDOAID]
    FROM [ODS_TD].[Tb_Android_Click_Arrange] --WHERE appkey is NOT null
	where [clicktime] >= @StartDate
        and [clicktime] < @EndDate
        and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎',N'北京易彩',N'幽蓝互动',N'语斐')
    GROUP BY
        channel_name,
        format([clicktime], 'yyyy-MM-dd'),
        case
            when appkey is NOT null then 'TD'
            else 'Additional'
        end
),
installwithdevice as (
    SELECT
        'Android' AS [OS],
        channel_name,
        format([active_time], 'yyyy-MM-dd') AS [Date],
        'TD' AS [Source],
        sum(
            CASE
                WHEN isnull([android_id], N'') <> N'' THEN 1
                ELSE 0
            END
        ) AS [TotalClickWithDeviceID]
    FROM [ODS_TD].[Tb_Android_Install]
    WHERE [active_time] >= @StartDate
        AND [active_time] < @EndDate
        and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    GROUP BY channel_name, format([active_time], 'yyyy-MM-dd')
),
wakeupwithdevice as (
    SELECT
        'Android' AS [OS],
        channel_name,
        format([deeplink_time], 'yyyy-MM-dd') AS [Date],
        'TD' AS [Source],
        sum(
            CASE
                WHEN isnull([android_id], N'') <> N'' THEN 1
                ELSE 0
            END
        ) AS [TotalClickWithDeviceID]
    FROM [ODS_TD].[Tb_Android_Wakeup]
    WHERE [deeplink_time] >= @StartDate
        AND [deeplink_time] < @EndDate
        and channel_name in (N'百度oCPX',N'百度原生信息流常规投放',N'超级粉丝通（原新浪应用家）',N'广点通',N'巨量引擎')
    GROUP BY channel_name, format([deeplink_time], 'yyyy-MM-dd')
)
INSERT INTO DW_TD.Tb_Android_Click_RowComp
SELECT
    a.OS,
    a.channel_name,
    a.[Date],
	a.[Source],
    a.[TotalClick],
    isnull(b.[TotalClickWithDeviceID], 0) AS [TotalClickWithDeviceID],
    isnull(b.[TotalClickWithDeviceIDOAID], 0) AS [TotalClickWithDeviceIDOAID],
	isnull(c.[TotalClickWithDeviceID],0) AS [TotalInstallWithDeviceID],
	isnull(d.[TotalClickWithDeviceID],0) AS [TotalWakeupWithDeviceID]
FROM totalclick a
LEFT JOIN totalclickwithdevice b ON a.OS = b.OS AND a.channel_name = b.channel_name AND a.[Date] = b.[Date] AND a.[Source] = b.[Source]
LEFT JOIN installwithdevice c ON a.OS = c.OS AND a.channel_name = c.channel_name AND a.[Date] = c.[Date] AND a.[Source] = c.[Source]
LEFT JOIN wakeupwithdevice d ON a.OS = d.OS AND a.channel_name = d.channel_name AND a.[Date] = d.[Date] AND a.[Source] = d.[Source]
GO
