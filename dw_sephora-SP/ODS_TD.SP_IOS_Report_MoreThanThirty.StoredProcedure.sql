/****** Object:  StoredProcedure [ODS_TD].[SP_IOS_Report_MoreThanThirty]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_IOS_Report_MoreThanThirty] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)



--Campaign
create table #Campaign(
	ChannelID nvarchar(64),
	ChannelName nvarchar(500),
	CampaignGroupName nvarchar(500),
	CampaignName nvarchar(500)
)

insert into #Campaign
select distinct a.ChannelID,a.ChannelName,a.CampaignGroupName,a.CampaignName
from [DW_TD].[Tb_Dim_CampaignMapping] a
where appkey='8DD42261C4214813A642A9796F8AD664'



--OMS 订单数据
select *
into #oms
from [ODS_TD].[Tb_OMS_Order]
where channel_cd='APP(IOS)'
and order_time >= @Start
and order_time < @End




select 
	ChannelName,
	CampaignName,
	count(distinct case when a.ThirtyClick=1 then a.OrderID end) ThirtyDayClickPlacedOrder,
	sum(distinct case when a.ThirtyClick=1 then a.PayedAmount end) ThirtyDayClickPlacedSales,
	count(distinct case when a.ThirtyClick=1 and a.IsPlacedFlag=1 then a.OrderID end) ThirtyDayClickPaymentOrder,
	sum(distinct case when a.ThirtyClick=1 and a.IsPlacedFlag=1 then a.PayedAmount end) ThirtyDayClickPaymentSales,
	count(distinct case when a.SixtyClick=1 then a.OrderID end) SixtyDayClickPlacedOrder,
	sum(distinct case when a.SixtyClick=1 then a.PayedAmount end) SixtyDayClickPlacedSales,
	count(distinct case when a.SixtyClick=1 and a.IsPlacedFlag=1 then a.OrderID end) SixtyDayClickPaymentOrder,
	sum(distinct case when a.SixtyClick=1 and a.IsPlacedFlag=1 then a.PayedAmount end) SixtyDayClickPaymentSales
into #Ascribe
from [DW_TD].[Tb_Fact_IOS_Ascribe_MoreThanThirty] a
where a.DateKey >= convert(varchar(8),@Start,112)
and a.DateKey < convert(varchar(8),@End,112)
group by ChannelName,CampaignName




delete from [DW_TD].[Tb_Fact_IOS_Report_MoreThanThirty]
where ActiveDate >=@Start
and ActiveDate < @End
and ChannelName<>N'Google Adwords'



insert into [DW_TD].[Tb_Fact_IOS_Report_MoreThanThirty]
select 
	convert(date,@Date) ActiveDate,
	'IOS' OS,
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
	'IOS' OS,
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
from (select distinct ChannelName,case when isnull(CampaignGroupName,'')='' then N'NoGroup' else CampaignGroupName end CampaignGroupName from #Campaign)a
left join (
	select 
		b.ChannelName,
		case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end CampaignGroupName,
		count(distinct case when a.ThirtyClick=1 then a.OrderID end) ThirtyDayClickPlacedOrder,
		sum(distinct case when a.ThirtyClick=1 then a.PayedAmount end) ThirtyDayClickPlacedSales,
		count(distinct case when a.ThirtyClick=1 and a.IsPlacedFlag=1 then a.OrderID end) ThirtyDayClickPaymentOrder,
		sum(distinct case when a.ThirtyClick=1 and a.IsPlacedFlag=1 then a.PayedAmount end) ThirtyDayClickPaymentSales,
		count(distinct case when a.SixtyClick=1 then a.OrderID end) SixtyDayClickPlacedOrder,
		sum(distinct case when a.SixtyClick=1 then a.PayedAmount end) SixtyDayClickPlacedSales,
		count(distinct case when a.SixtyClick=1 and a.IsPlacedFlag=1 then a.OrderID end) SixtyDayClickPaymentOrder,
		sum(distinct case when a.SixtyClick=1 and a.IsPlacedFlag=1 then a.PayedAmount end) SixtyDayClickPaymentSales
	from #Campaign b
	left join [DW_TD].[Tb_Fact_IOS_Ascribe_MoreThanThirty] a on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
	where a.DateKey >= convert(varchar(8),@Start,112)
	and a.DateKey < convert(varchar(8),@End,112)
	group by b.ChannelName,case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end
)b on a.ChannelName=b.ChannelName and a.CampaignGroupName=b.CampaignGroupName

drop table #Campaign
drop table #oms
drop table #Ascribe
GO
