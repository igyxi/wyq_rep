/****** Object:  StoredProcedure [DW_TD].[SP_PKG_ReportComp_New_Test_220601]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_PKG_ReportComp_New_Test_220601] @StartDate [datetime],@EndDate [datetime] AS

--exec [DW_TD].[SP_PKG_ReportComp_New] '2021-06-01', '2021-06-02'

delete from DW_TD.Tb_PKG_ReportComp_New_Test_220601
where [Date] >= @StartDate
and [Date] < @EndDate;

with cte as 
(
	SELECT
    datepart(year, [ActiveDate]) as [Year],
    datepart(month, [ActiveDate]) as [Month],
    [ActiveDate] as [Date],
    [OS],
    [ChannelName] as [Channel_CH],
    [CampaignGroupName],
	'Recruit' as [Audience],  --添加的为固定值
    'Ang' as [Agency],
    'APP Store' as [Channel_EN],
    substring(
        substring(
            [CampaignGroupName],
            charindex(N'-', [CampaignGroupName]) + 1,
            100
        ),
        charindex(
            N'-',
            substring(
                [CampaignGroupName],
                charindex(N'-', [CampaignGroupName]) + 1,
                100
            )
        ) + 1,
        100
    ) as [Media],
    [CampaignName],
	REPLACE(ISNULL([MemberStatus],''),'NULL','') as [MemberStatus],
    sum([UV]) as [UV],
    sum([PlacedOrder]) as [TD Placed_Paid Order],
    sum([PaymentOrder]) as [TD Payment_Paid Order],
    --[LastClickPlacedOrder] as [1D Attribution_Paid Order],
    --[SevenDayClickPlacedOrder] as [7D Attribution_Paid Order],
    --[FourteenDayClickPlacedOrder] as [14D Attribution_Paid Order],
    sum(isnull([LastClickPaymentOrder], 0)) as [1D Attribution_Payment Order],
    sum(isnull([SevenDayClickPaymentOrder], 0)) as [7D Attribution_Payment Order],
    sum(isnull([FourteenDayClickPaymentOrder], 0)) as [14D Attribution_Payment Order],
	SUM(isnull([ThirtyDayClickPaymentOrder], 0)) as [30D Attribution_Payment Order],
	SUM(isnull([NinetyDayClickPaymentOrder], 0)) as [90D Attribution_Payment Order],
    sum(isnull(PlacedSales, 0)) as [TD Placed_Paid Sales],
    sum(isnull(PaymentSales, 0)) as [TD Payment_Paid Sales],
    --isnull(cast([LastClickPlacedSales] as int), 0) as [1D Attribution_Paid Sales],
    --isnull(cast([SevenDayClickPlacedSales] as int), 0) as [7D Attribution_Paid Sales],
    --isnull(cast([FourteenDayClickPlacedSales] as int), 0) as [14D Attribution_Paid Sales],
    sum(isnull(LastClickPaymentSales, 0)) as [1D Attribution_Payment Sales],
    sum(isnull(SevenDayClickPaymentSales, 0)) as [7D Attribution_Payment Sales],
    sum(isnull(FourteenDayClickPaymentSales, 0)) as [14D Attribution_Payment Sales],
	SUM(isnull(cast([ThirtyDayClickPaymentSales] as numeric(16,2)), 0)) as [30D Attribution_Payment Sales],
	SUM(isnull(cast([NinetyDayClickPaymentSales] as numeric(16,2)), 0)) as [90D Attribution_Payment Sales]
FROM
    [DW_TD].[Tb_Fact_Android_Report]   
where
    flag = 1
and [ChannelName] = N'PKG'
and [ActiveDate] >= @StartDate
and [ActiveDate] < @EndDate
group by
	datepart(year, [ActiveDate]) ,
    datepart(month, [ActiveDate]) ,
    [ActiveDate] ,
    [OS],
    [ChannelName] ,
    [CampaignGroupName],
	[CampaignName],
	REPLACE(ISNULL([MemberStatus],''),'NULL',''),
    substring(
        substring(
            [CampaignGroupName],
            charindex(N'-', [CampaignGroupName]) + 1,
            100
        ),
        charindex(
            N'-',
            substring(
                [CampaignGroupName],
                charindex(N'-', [CampaignGroupName]) + 1,
                100
            )
        ) + 1,
        100
    )
)


insert into DW_TD.Tb_PKG_ReportComp_New_Test_220601
select a.*,b.UV
from
(
select 
a.[Year],
a.[Month],
a.[Date],
a.[OS],
a.[Channel_CH],
a.[CampaignGroupName],
a.[Audience],  --添加的为固定值字段名
a.[Agency],
a.[Channel_EN],
a.[Media],
a.[CampaignName],
ISNULL(a.[MemberStatus],'') as [MemberStatus],
--a.[Paid Order],
--a.[Paid Sales],
SUM(a.[Paid Order]) as [Paid Order],
SUM(a.[Paid Sales]) as [Paid Sales],
--a.[Attribution Type] as [Attribution],
--a.[Attribution Type] as [Attribution],
substring(a.[Attribution Type],0,charindex(N'_',a.[Attribution Type])) as [Attribution Type]
from
(
select 
P.[Year],
P.[Month],
P.[Date],
P.[OS],
P.[Channel_CH],
P.[CampaignGroupName],
P.[Audience],  --添加的为固定值字段名
P.[Agency],
P.[Channel_EN],
P.[Media],
P.[CampaignName],
P.[MemberStatus],
P.[Paid Order],
null as [Paid Sales],
P.[Attribution Type]
from cte T
unpivot
(
	--[UV] for [UV]in ([UV]),
	[Paid Order] for [Attribution Type] in ([TD Payment_Paid Order],[TD Placed_Paid Order],[1D Attribution_Payment Order],[7D Attribution_Payment Order],[14D Attribution_Payment Order],[30D Attribution_Payment Order],[90D Attribution_Payment Order])
	--[Paid Sales] for [Metrics] in ([Sales_TDPaymentOrder],[Sales_1D_Placed],[Sales_7D_Placed],[Sales_14D_Placed],[Sales_1D_Payment],[Sales_7D_Payment],[Sales_14D_Payment])
) P
union all
select 
P.[Year],
P.[Month],
P.[Date],
P.[OS],
P.[Channel_CH],
P.[CampaignGroupName],
P.[Audience],  --添加的为固定值字段名
P.[Agency],
P.[Channel_EN],
P.[Media],
P.[CampaignName],
P.[MemberStatus],
null as [Paid Order],
P.[Paid Sales],
P.[Attribution Type]
from cte T
unpivot
(
	--[UV] for [UV]in ([UV]),
	--[Paid Order] for [Attribution Type] in ([TD Placed_Paid Order],[TD Payment_Paid Order],[1D Attribution_Paid Order],[7D Attribution_Paid Order],[14D Attribution_Paid Order])
	[Paid Sales] for [Attribution Type] in ([TD Placed_Paid Sales],[TD Payment_Paid Sales],[1D Attribution_Payment Sales],[7D Attribution_Payment Sales],[14D Attribution_Payment Sales],[30D Attribution_Payment Sales],[90D Attribution_Payment Sales])
) P
)a
group by a.[Year],
a.[Month],
a.[Date],
a.[OS],
a.[Channel_CH],
a.[CampaignGroupName],
a.[Audience],  --添加的为固定值字段名
a.[Agency],
a.[Channel_EN],
a.[Media],
a.[CampaignName],
a.[MemberStatus],
--a.[Attribution Type],
substring(a.[Attribution Type],0,charindex(N'_',a.[Attribution Type]))
) a
join 
(
select [Year],[Month],[Date],[OS],[Channel_CH],[CampaignGroupName],[MemberStatus],max(UV) as [UV]
from cte
group by [Year],[Month],[Date],[OS],[Channel_CH],[CampaignGroupName],[MemberStatus]
)
b
on a.[Year] = b.[Year]
and a.[Month] = b.[Month]
and a.[Date] = b.[Date]
and a.[OS]= b.[OS]
and a.[Channel_CH] = b.[Channel_CH]
and a.[CampaignGroupName] = b.[CampaignGroupName]
and  a.[MemberStatus]=b.[MemberStatus]
--below added by Joey Shen 20210826
where NOT (a.[MemberStatus] = '' AND [Attribution Type] = 'TD Payment' AND [Paid Sales] > 0)
and NOT (a.[MemberStatus] = '' AND [Attribution Type] = '7D Attribution' AND [Paid Sales] > 0)
and NOT (a.[MemberStatus] = '' AND [Attribution Type] = '14D Attribution' AND [Paid Sales] > 0)
and NOT (a.[MemberStatus] = '' AND [Attribution Type] = '30D Attribution' AND [Paid Sales] > 0)
--and b.[MemberStatus] = ''
--and a.[CampaignName] = b.[CampaignName]
--where a.[Date] = '2020-09-03'
--and a.[CampaignName] =N'头条-转化追踪-new'
--order by [Paid Order] desc

--select * from  [DW_TD].[Tb_Fact_IOS_Report]
--where [CampaignName] = N'头条-转化追踪-new'
GO
