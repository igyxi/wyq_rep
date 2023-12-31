/****** Object:  StoredProcedure [ODS_TD].[SP_Android_Report_MoreThanThirty]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_Android_Report_MoreThanThirty] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)




--Campaign
create table #Campaign(
	ChannelName nvarchar(500),
	CampaignGroupName nvarchar(500),
	CampaignName nvarchar(500)
)

insert into #Campaign
select distinct a.ChannelName,case when isnull(a.CampaignGroupName,'')='' then N'NoGroup' else a.CampaignGroupName end CampaignGroupName,a.CampaignName
from [DW_TD].[Tb_Dim_CampaignMapping] a
where appkey='A85FD453F75846BC8A8CA5046537EB5C'
--and ChannelName in (N'巨量引擎',N'百度oCPX',N'超级粉丝通（原新浪应用家）',N'百度原生信息流常规投放',N'广点通',N'幽蓝互动',N'北京易彩',N'语斐')



--OMS 订单数据
select *
into #oms
from [ODS_TD].[Tb_OMS_Order]
where channel_cd='APP(ANDROID)'
and order_time >= @Start
and order_time < @End





select 
	ChannelName,
	CampaignName,
	count(distinct case when a.ThirtyClick=1 then a.OrderID end) ThirtyDayClickPlacedOrder,
	sum(case when a.ThirtyClick=1 then convert(numeric(10,2),a.PayedAmount) end) ThirtyDayClickPlacedSales,
	count(distinct case when a.ThirtyClick=1 and a.IsPlacedFlag=1 then a.OrderID end) ThirtyDayClickPaymentOrder,
	sum(case when a.ThirtyClick=1 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) ThirtyDayClickPaymentSales,
	count(distinct case when a.SixtyClick=1 then a.OrderID end) SixtyDayClickPlacedOrder,
	sum(case when a.SixtyClick=1 then convert(numeric(10,2),a.PayedAmount) end) SixtyDayClickPlacedSales,
	count(distinct case when a.SixtyClick=1 and a.IsPlacedFlag=1 then a.OrderID end) SixtyDayClickPaymentOrder,
	sum(case when a.SixtyClick=1 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) SixtyDayClickPaymentSales
into #Ascribe
from [DW_TD].Tb_Fact_Android_Ascribe_MoreThanThirty a 
where DateKey >= convert(varchar(8),@Start,112)
and DateKey < convert(varchar(8),@End,112)
group by ChannelName,CampaignName




delete from [DW_TD].[Tb_Fact_Android_Report_MoreThanThirty]
where [ActiveDate] >= @Start
and [ActiveDate] < @End
and ChannelName<>N'PKG'

insert into [DW_TD].[Tb_Fact_Android_Report_MoreThanThirty]
select 
	convert(date,@Date) ActiveDate,
	'Android' OS,
	a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then N'NoGroup' else a.CampaignGroupName end CampaignGroupName,
	a.CampaignName,
	b.ThirtyDayClickPlacedOrder,
	b.ThirtyDayClickPlacedSales,
	b.ThirtyDayClickPaymentOrder,
	b.ThirtyDayClickPaymentSales,
	b.SixtyDayClickPlacedOrder,
	b.SixtyDayClickPlacedSales,
	b.SixtyDayClickPaymentOrder,
	b.SixtyDayClickPaymentSales,
	0 Flag
from #Campaign a
left join #Ascribe b on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName


union all
select 
	convert(date,@Date) ActiveDate,
	'Android' OS,
	a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then N'NoGroup' else a.CampaignGroupName end CampaignGroupName,
	null CampaignName,
	b.ThirtyDayClickPlacedOrder,
	b.ThirtyDayClickPlacedSales,
	b.ThirtyDayClickPaymentOrder,
	b.ThirtyDayClickPaymentSales,
	b.SixtyDayClickPlacedOrder,
	b.SixtyDayClickPlacedSales,
	b.SixtyDayClickPaymentOrder,
	b.SixtyDayClickPaymentSales,
	1 Flag
from (select distinct ChannelName,case when isnull(CampaignGroupName,'')='' then N'NoGroup' else CampaignGroupName end CampaignGroupName from #Campaign )a
left join
	(
	select 
		b.ChannelName,
		case when isnull(b.CampaignGroupName,'')='' then N'NoGroup' else b.CampaignGroupName end CampaignGroupName,
		count(distinct case when a.ThirtyClick=1 then a.OrderID end) ThirtyDayClickPlacedOrder,
		sum(case when a.ThirtyClick=1 then convert(numeric(10,2),a.PayedAmount) end) ThirtyDayClickPlacedSales,
		count(distinct case when a.ThirtyClick=1 and a.IsPlacedFlag=1 then a.OrderID end) ThirtyDayClickPaymentOrder,
		sum(case when a.ThirtyClick=1 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) ThirtyDayClickPaymentSales,
		count(distinct case when a.SixtyClick=1 then a.OrderID end) SixtyDayClickPlacedOrder,
		sum(case when a.SixtyClick=1 then convert(numeric(10,2),a.PayedAmount) end) SixtyDayClickPlacedSales,
		count(distinct case when a.SixtyClick=1 and a.IsPlacedFlag=1 then a.OrderID end) SixtyDayClickPaymentOrder,
		sum(case when a.SixtyClick=1 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) SixtyDayClickPaymentSales
	from #Campaign b
	left join [DW_TD].Tb_Fact_Android_Ascribe_MoreThanThirty a on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
	where DateKey >= convert(varchar(8),@Start,112)
	and DateKey < convert(varchar(8),@End,112)
	group by b.ChannelName,case when isnull(b.CampaignGroupName,'')='' then N'NoGroup' else b.CampaignGroupName end
)b on a.ChannelName=b.ChannelName and a.CampaignGroupName=b.CampaignGroupName




drop table #Campaign
drop table #oms
drop table #Ascribe


GO
