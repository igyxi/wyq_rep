/****** Object:  StoredProcedure [TEMP].[SP_Android_Report_bak20210602]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Android_Report_bak20210602] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)

--select *
--from [DW_TD].[Tb_Fact_Android_Ascribe]
--where DateKey >= convert(varchar(8),@Start,112)
--and DateKey < convert(varchar(8),@End,112)



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




select *
into #AndOrder
from (
	select distinct a.campaign_name,a.channel_name,a.order_id,convert(numeric(15,2),order_amount) pay_amount
	from ODS_TD.Tb_Android_Order a
	where order_time>= @Start
	and order_time < @End
	union
	select distinct a.campaign_name,a.channel_name,a.order_id,convert(numeric(15,2),pay_amount)  pay_amount
	from ODS_TD.Tb_Android_PayOrder a
	where pay_time>= @Start
	and pay_time < @End
)a
--where channel_name in (N'巨量引擎',N'百度oCPX',N'超级粉丝通（原新浪应用家）',N'百度原生信息流常规投放',N'广点通',N'幽蓝互动',N'北京易彩',N'语斐',N'GoogleAdwords', N'Google Adwords')

select 
	a.campaign_name,a.channel_name,a.order_id,a.pay_amount,
	b.sales_order_number,b.is_placed_flag,convert(numeric(15,2),b.payed_amount) payed_amount
into #andoms
from #AndOrder a
left join #oms b on a.order_id=b.sales_order_number


--活动
select 
	channel_name ChannelName,
	campaign_name CampaignName,
	count(distinct order_id) PlacedOrder,
	isnull(sum(convert(numeric(10,2),pay_amount)),0) PlacedSales,
	count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
	isnull(sum(case when is_placed_flag=1 then convert(numeric(10,2),payed_amount) end),0) PaymentSales
into #and
from (
	select 
	a.campaign_name,a.channel_name,a.order_id,a.pay_amount,
	b.sales_order_number,b.is_placed_flag,convert(numeric(15,2),b.payed_amount) payed_amount
	from #AndOrder a
	left join #oms b on a.order_id=b.sales_order_number
	)a
group by channel_name,campaign_name


select 
	ChannelName,
	CampaignName,
	count(distinct case when a.LastClick=1 and UVFlag=1 then a.AndroidId end) UV,
	count(distinct case when a.LastClick=1 and UVFlag=0 then a.OrderID end) LastClickPlacedOrder,
	sum(case when a.LastClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) LastClickPlacedSales,
	count(distinct case when a.LastClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) LastClickPaymentOrder,
	sum(case when a.LastClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) LastClickPaymentSales,
	count(distinct case when a.SevenDayClick=1 and UVFlag=0 then a.OrderID end) SevenDayClickPlacedOrder,
	sum(case when a.SevenDayClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) SevenDayClickPlacedSales,
	count(distinct case when a.SevenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) SevenDayClickPaymentOrder,
	sum(case when a.SevenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) SevenDayClickPaymentSales,
	count(distinct case when a.FourteenDayClick=1 and UVFlag=0 then a.OrderID end) FourteenDayClickPlacedOrder,
	sum(case when a.FourteenDayClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) FourteenDayClickPlacedSales,
	count(distinct case when a.FourteenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) FourteenDayClickPaymentOrder,
	sum(case when a.FourteenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) FourteenDayClickPaymentSales
into #Ascribe
from [DW_TD].[Tb_Fact_Android_Ascribe] a 
where DateKey >= convert(varchar(8),@Start,112)
and DateKey < convert(varchar(8),@End,112)
group by ChannelName,CampaignName




delete from [DW_TD].[Tb_Fact_Android_Report]
where [ActiveDate] >= @Start
and [ActiveDate] < @End
and ChannelName<>N'PKG'

insert into [DW_TD].[Tb_Fact_Android_Report]
select 
	convert(date,@Date) ActiveDate,
	'Android' OS,
	a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then N'NoGroup' else a.CampaignGroupName end CampaignGroupName,
	a.CampaignName,
	UV,
	c.PlacedOrder,
	c.PlacedSales,
	c.PaymentOrder,
	c.PaymentSales,
	b.LastClickPlacedOrder,
	b.LastClickPlacedSales,
	b.LastClickPaymentOrder,
	b.LastClickPaymentSales,
	b.SevenDayClickPlacedOrder,
	b.SevenDayClickPlacedSales,
	b.SevenDayClickPaymentOrder,
	b.SevenDayClickPaymentSales,
	b.FourteenDayClickPlacedOrder,
	b.FourteenDayClickPlacedSales,
	b.FourteenDayClickPaymentOrder,
	b.FourteenDayClickPaymentSales,
	0 Flag
from #Campaign a
left join #Ascribe b on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
left join #and c on a.ChannelName=c.ChannelName and a.CampaignName=c.CampaignName
--(
--	select 
--		b.ChannelName,
--		case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end CampaignGroupName,
--		b.CampaignName,
--		count(distinct case when a.LastClick=1 and UVFlag=1 then a.AndroidId end) UV,
--		count(distinct case when a.LastClick=1 and UVFlag=0 then a.OrderID end) LastClickPlacedOrder,
--		sum(case when a.LastClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) LastClickPlacedSales,
--		count(distinct case when a.LastClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) LastClickPaymentOrder,
--		sum(case when a.LastClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) LastClickPaymentSales,
--		count(distinct case when a.SevenDayClick=1 and UVFlag=0 then a.OrderID end) SevenDayClickPlacedOrder,
--		sum(case when a.SevenDayClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) SevenDayClickPlacedSales,
--		count(distinct case when a.SevenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) SevenDayClickPaymentOrder,
--		sum(case when a.SevenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) SevenDayClickPaymentSales,
--		count(distinct case when a.FourteenDayClick=1 and UVFlag=0 then a.OrderID end) FourteenDayClickPlacedOrder,
--		sum(case when a.FourteenDayClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) FourteenDayClickPlacedSales,
--		count(distinct case when a.FourteenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) FourteenDayClickPaymentOrder,
--		sum(case when a.FourteenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) FourteenDayClickPaymentSales
--	from #Campaign b
--	left join [DW_TD].[Tb_Fact_Android_Ascribe] a on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
--	where DateKey >= convert(varchar(8),@Start,112)
--	and DateKey < convert(varchar(8),@End,112)
--	group by b.ChannelName,
--		case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end ,b.CampaignName
--)a
--left join 
--(
--select 
--	b.ChannelName,
--	case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end CampaignGroupName,
--	b.CampaignName,
--	count(distinct a.order_id) PlacedOrder,
--	isnull(sum(convert(numeric(10,2),a.pay_amount)),0) PlacedSales,
--	count(distinct case when a.is_placed_flag=1 then a.sales_order_number end) PaymentOrder,
--	isnull(sum(case when a.is_placed_flag=1 then convert(numeric(10,2),a.payed_amount) end),0) PaymentSales
--from #Campaign b
--left join #andoms a on a.channel_name=b.ChannelName and a.campaign_name=b.CampaignName
--group by b.ChannelName,
--	case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end ,b.CampaignName
--)c on a.ChannelName=c.ChannelName and a.CampaignGroupName=c.CampaignGroupName and a.CampaignName=c.CampaignName

union all
select 
	convert(date,@Date) ActiveDate,
	'Android' OS,
	a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then N'NoGroup' else a.CampaignGroupName end CampaignGroupName,
	null CampaignName,
	UV,
	c.PlacedOrder,
	c.PlacedSales,
	c.PaymentOrder,
	c.PaymentSales,
	b.LastClickPlacedOrder,
	b.LastClickPlacedSales,
	b.LastClickPaymentOrder,
	b.LastClickPaymentSales,
	b.SevenDayClickPlacedOrder,
	b.SevenDayClickPlacedSales,
	b.SevenDayClickPaymentOrder,
	b.SevenDayClickPaymentSales,
	b.FourteenDayClickPlacedOrder,
	b.FourteenDayClickPlacedSales,
	b.FourteenDayClickPaymentOrder,
	b.FourteenDayClickPaymentSales,
	1 Flag
from (select distinct ChannelName,case when isnull(CampaignGroupName,'')='' then N'NoGroup' else CampaignGroupName end CampaignGroupName from #Campaign )a
left join
	(
	select 
		b.ChannelName,
		case when isnull(b.CampaignGroupName,'')='' then N'NoGroup' else b.CampaignGroupName end CampaignGroupName,
		count(distinct case when a.LastClick=1 and UVFlag=1 then a.AndroidId end) UV,
		count(distinct case when a.LastClick=1 and UVFlag=0 then a.OrderID end) LastClickPlacedOrder,
		sum(case when a.LastClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) LastClickPlacedSales,
		count(distinct case when a.LastClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) LastClickPaymentOrder,
		sum(case when a.LastClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) LastClickPaymentSales,
		count(distinct case when a.SevenDayClick=1 and UVFlag=0 then a.OrderID end) SevenDayClickPlacedOrder,
		sum(case when a.SevenDayClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) SevenDayClickPlacedSales,
		count(distinct case when a.SevenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) SevenDayClickPaymentOrder,
		sum(case when a.SevenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) SevenDayClickPaymentSales,
		count(distinct case when a.FourteenDayClick=1 and UVFlag=0 then a.OrderID end) FourteenDayClickPlacedOrder,
		sum(case when a.FourteenDayClick=1 and UVFlag=0 then convert(numeric(10,2),a.PayedAmount) end) FourteenDayClickPlacedSales,
		count(distinct case when a.FourteenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) FourteenDayClickPaymentOrder,
		sum(case when a.FourteenDayClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then convert(numeric(10,2),a.PayedAmount) end) FourteenDayClickPaymentSales
	from #Campaign b
	left join [DW_TD].[Tb_Fact_Android_Ascribe] a on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
	where DateKey >= convert(varchar(8),@Start,112)
	and DateKey < convert(varchar(8),@End,112)
	group by b.ChannelName,case when isnull(b.CampaignGroupName,'')='' then N'NoGroup' else b.CampaignGroupName end
)b on a.ChannelName=b.ChannelName and a.CampaignGroupName=b.CampaignGroupName
left join 
(
select 
	b.ChannelName,
	case when isnull(b.CampaignGroupName,'')='' then N'NoGroup' else b.CampaignGroupName end CampaignGroupName,
	count(distinct a.order_id) PlacedOrder,
	isnull(sum(convert(numeric(10,2),a.pay_amount)),0) PlacedSales,
	count(distinct case when a.is_placed_flag=1 then a.sales_order_number end) PaymentOrder,
	isnull(sum(case when a.is_placed_flag=1 then convert(numeric(10,2),a.payed_amount) end),0) PaymentSales
from #Campaign b
left join #andoms a on a.channel_name=b.ChannelName and a.campaign_name=b.CampaignName
group by b.ChannelName,case when isnull(b.CampaignGroupName,'')='' then N'NoGroup' else b.CampaignGroupName end
)c on a.ChannelName=c.ChannelName and a.CampaignGroupName=c.CampaignGroupName




drop table #Campaign
drop table #oms
drop table #AndOrder
drop table #andoms
drop table #and
drop table #Ascribe


GO
