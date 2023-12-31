/****** Object:  StoredProcedure [DW_TD].[SP_Android_ReportComp]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_Android_ReportComp] @StartDate [datetime],@EndDate [datetime] AS

delete from DW_TD.Tb_Android_ReportComp
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
    substring(
        [CampaignGroupName],
        0,
        charindex(N'-', [CampaignGroupName])
    ) as [Agency],
    substring(
        substring(
            [CampaignGroupName],
            charindex(N'-', [CampaignGroupName]) + 1,
            100
        ),
        0,
        charindex(
            N'-',
            substring(
                [CampaignGroupName],
                charindex(N'-', [CampaignGroupName]) + 1,
                100
            )
        )
    ) as [Channel_EN],
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
    SUM([UV]) as [UV],
	--AVG([UV]) as [UV],
    SUM([PlacedOrder]) as [TD Placed_Paid Order],
    SUM([PaymentOrder]) as [TD Payment_Paid Order],
    --[LastClickPlacedOrder] as [1D Attribution_Paid Order],
    --[SevenDayClickPlacedOrder] as [7D Attribution_Paid Order],
    --[FourteenDayClickPlacedOrder] as [14D Attribution_Paid Order],
    SUM(isnull([LastClickPaymentOrder], 0)) as [1D Attribution_Payment Order],
    SUM(isnull([SevenDayClickPaymentOrder], 0)) as [7D Attribution_Payment Order],
    SUM(isnull([FourteenDayClickPaymentOrder], 0)) as [14D Attribution_Payment Order],
    SUM(isnull(cast([PlacedSales] as int), 0)) as [TD Placed_Paid Sales],
    SUM(isnull(cast([PaymentSales] as int), 0)) as [TD Payment_Paid Sales],
    --isnull(cast([LastClickPlacedSales] as int), 0) as [1D Attribution_Paid Sales],
    --isnull(cast([SevenDayClickPlacedSales] as int), 0) as [7D Attribution_Paid Sales],
    --isnull(cast([FourteenDayClickPlacedSales] as int), 0) as [14D Attribution_Paid Sales],
    SUM(isnull(cast([LastClickPaymentSales] as int), 0)) as [1D Attribution_Payment Sales],
    SUM(isnull(cast([SevenDayClickPaymentSales] as int), 0)) as [7D Attribution_Payment Sales],
    SUM(isnull(cast([FourteenDayClickPaymentSales] as int), 0)) as [14D Attribution_Payment Sales]
FROM
    [DW_TD].[Tb_Fact_Android_Report]
where
    flag = 0
	and [ActiveDate] >= @StartDate
	and [ActiveDate] < @EndDate
group by 
datepart(year, [ActiveDate])  ,
    datepart(month, [ActiveDate])  ,
    [ActiveDate]  ,
    [OS],
    [ChannelName] ,
    [CampaignGroupName],
    substring(
        [CampaignGroupName],
        0,
        charindex(N'-', [CampaignGroupName])
    )  ,
    substring(
        substring(
            [CampaignGroupName],
            charindex(N'-', [CampaignGroupName]) + 1,
            100
        ),
        0,
        charindex(
            N'-',
            substring(
                [CampaignGroupName],
                charindex(N'-', [CampaignGroupName]) + 1,
                100
            )
        )
    )  ,
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
    )  ,
    [CampaignName]
)


insert into DW_TD.Tb_Android_ReportComp
select a.*,isnull(b.UV,0) as [UV]
from
(
select 
a.[Year],
a.[Month],
a.[Date],
a.[OS],
a.[Channel_CH],
a.[CampaignGroupName],
a.[Agency],
a.[Channel_EN],
a.[Media],
a.[CampaignName],
--a.[Paid Order],
--a.[Paid Sales],
isnull(SUM(a.[Paid Order]),0) as [Paid Order],
isnull(SUM(a.[Paid Sales]),0) as [Paid Sales],
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
P.[Agency],
P.[Channel_EN],
P.[Media],
P.[CampaignName],
P.[Paid Order],
null as [Paid Sales],
P.[Attribution Type]
from cte T
unpivot
(
	--[UV] for [UV]in ([UV]),
	[Paid Order] for [Attribution Type] in ([TD Payment_Paid Order],[TD Placed_Paid Order],[1D Attribution_Payment Order],[7D Attribution_Payment Order],[14D Attribution_Payment Order])
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
P.[Agency],
P.[Channel_EN],
P.[Media],
P.[CampaignName],
null as [Paid Order],
P.[Paid Sales],
P.[Attribution Type]
from cte T
unpivot
(
	--[UV] for [UV]in ([UV]),
	--[Paid Order] for [Attribution Type] in ([TD Placed_Paid Order],[TD Payment_Paid Order],[1D Attribution_Paid Order],[7D Attribution_Paid Order],[14D Attribution_Paid Order])
	[Paid Sales] for [Attribution Type] in ([TD Placed_Paid Sales],[TD Payment_Paid Sales],[1D Attribution_Payment Sales],[7D Attribution_Payment Sales],[14D Attribution_Payment Sales])
) P
)a
group by a.[Year],
a.[Month],
a.[Date],
a.[OS],
a.[Channel_CH],
a.[CampaignGroupName],
a.[Agency],
a.[Channel_EN],
a.[Media],
a.[CampaignName],
--a.[Attribution Type],
substring(a.[Attribution Type],0,charindex(N'_',a.[Attribution Type]))
) a
join cte b
on a.[Year] = b.[Year]
and a.[Month] = b.[Month]
and a.[Date] = b.[Date]
and a.[OS]= b.[OS]
and a.[Channel_CH] = b.[Channel_CH]
and a.[CampaignGroupName] = b.[CampaignGroupName]
and a.[CampaignName] = b.[CampaignName]
where isnull(b.UV,0) + [Paid Order] + [Paid Sales] <> 0
--where a.[Date] = '2020-09-03'
--and a.[CampaignName] =N'头条-转化追踪-new'
--order by [Paid Order] desc

--select * from  [DW_TD].[Tb_Fact_Android_Report]
--where [CampaignName] = N'头条-转化追踪-new'
GO
