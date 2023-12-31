/****** Object:  StoredProcedure [TEMP].[SP_IOS_Install_Report_bk20210809]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_IOS_Install_Report_bk20210809] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)

--select *
--from [DW_TD].[Tb_Fact_IOS_Ascribe]
--where DateKey >= convert(varchar(8),@Start,112)
--and DateKey < convert(varchar(8),@End,112)



--Campaign
create table #Campaign1(
	ChannelID nvarchar(64),
	ChannelName nvarchar(500),
	CampaignGroupName nvarchar(500),
	CampaignName nvarchar(500)
)

insert into #Campaign1
select distinct a.ChannelID,a.ChannelName,a.CampaignGroupName,a.CampaignName
from [DW_TD].[Tb_Dim_CampaignMapping] a
where appkey='8DD42261C4214813A642A9796F8AD664'



--OMS 订单数据
select 
sales_order_number
		  ,channel_cd
		  ,is_placed_flag
		  ,place_time
		  ,place_date
		  ,order_time
		  ,order_date
		  ,payed_amount
		  ,user_id 
			,case when  member_new_status ='NULL' then null 
			else member_new_status end as  member_new_status
      ,case when  member_daily_new_status ='NULL' then null
			else member_daily_new_status  end as  member_daily_new_status
      ,case when  member_monthly_new_status   ='NULL' then null
			else  member_monthly_new_status end as member_monthly_new_status
		  ,idfa
		  ,android_id
		  ,oaid
		  ,trigger_time
into #oms1
from [ODS_TD].[Tb_OMS_Order]
where channel_cd='APP(IOS)'
and order_time >= @Start
and order_time < @End




select *
into #IOSOrder
from (
	select distinct a.campaign_name,a.channel_name,a.order_id,convert(numeric(15,2),order_amount) pay_amount
	from ODS_TD.Tb_IOS_Order a
	where order_time >= @Start
	and order_time < @End
	union
	select distinct a.campaign_name,a.channel_name,a.order_id,convert(numeric(15,2),pay_amount) pay_amount
	from ODS_TD.Tb_IOS_PayOrder a
	where pay_time >= @Start
	and pay_time < @End
)a
--where channel_name in (N'巨量引擎',N'百度oCPX',N'超级粉丝通（原新浪应用家）',N'百度原生信息流常规投放',N'广点通',N'幽蓝互动',N'北京易彩',N'语斐',N'GoogleAdwords', N'Google Adwords')

select a.campaign_name,a.channel_name,a.order_id,a.pay_amount,b.member_new_status,b.sales_order_number,b.is_placed_flag,convert(numeric(15,2),b.payed_amount) payed_amount
into #andoms1
from #IOSOrder a
left join #oms1 b on a.order_id=b.sales_order_number


--活动
select 
	channel_name ChannelName,
	campaign_name CampaignName,
	member_new_status,
	count(distinct order_id) PlacedOrder,
	isnull(sum(convert(numeric(10,2),pay_amount)),0) PlacedSales,
	count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
	isnull(sum(case when is_placed_flag=1 then convert(numeric(10,2),payed_amount) end),0) PaymentSales
into #and1
from #andoms1 a
group by channel_name,campaign_name,member_new_status


select 
	ChannelName,
	CampaignName,
	MemberNewStatus,
	count(distinct case when a.LastInstall=1 and UVFlag=1 then a.IDFA end) UV,
	count(distinct case when a.LastInstall=1 and UVFlag=0 then a.OrderID end) LastInstallPlacedOrder,
	sum(distinct case when a.LastInstall=1 and UVFlag=0 then a.PayedAmount end) LastInstallPlacedSales,
	count(distinct case when a.LastInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) LastInstallPaymentOrder,
	sum(distinct case when a.LastInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) LastInstallPaymentSales,
	count(distinct case when a.SevenDayInstall=1 and UVFlag=0 then a.OrderID end) SevenDayInstallPlacedOrder,
	sum(distinct case when a.SevenDayInstall=1 and UVFlag=0 then a.PayedAmount end) SevenDayInstallPlacedSales,
	count(distinct case when a.SevenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) SevenDayInstallPaymentOrder,
	sum(distinct case when a.SevenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) SevenDayInstallPaymentSales,
	count(distinct case when a.FourteenDayInstall=1 and UVFlag=0 then a.OrderID end) FourteenDayInstallPlacedOrder,
	sum(distinct case when a.FourteenDayInstall=1 and UVFlag=0 then a.PayedAmount end) FourteenDayInstallPlacedSales,
	count(distinct case when a.FourteenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) FourteenDayInstallPaymentOrder,
	sum(distinct case when a.FourteenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) FourteenDayInstallPaymentSales,
	count(distinct case when a.ThirtyDayInstall=1 and UVFlag=0 then a.OrderID end) ThirtyDayInstallPlacedOrder,
	sum(distinct case when a.ThirtyDayInstall=1 and UVFlag=0 then a.PayedAmount end) ThirtyDayInstallPlacedSales,
	count(distinct case when a.ThirtyDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) ThirtyDayInstallPaymentOrder,
	sum(distinct case when a.ThirtyDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) ThirtyDayInstallPaymentSales,
	count(distinct case when a.NinetyDayInstall=1 and UVFlag=0 then a.OrderID end) NinetyDayInstallPlacedOrder,
	sum(distinct case when a.NinetyDayInstall=1 and UVFlag=0 then a.PayedAmount end) NinetyDayInstallPlacedSales,
	count(distinct case when a.NinetyDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) NinetyDayInstallPaymentOrder,
	sum(distinct case when a.NinetyDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) NinetyDayInstallPaymentSales
into #Ascribe1
from [DW_TD].[Tb_Fact_IOS_Install_Ascribe] a
where a.DateKey >= convert(varchar(8),@Start,112)
and a.DateKey < convert(varchar(8),@End,112)
group by ChannelName,CampaignName,MemberNewStatus




delete from [DW_TD].[Tb_Fact_IOS_Install_Report]
where ActiveDate >=@Start
and ActiveDate < @End
and ChannelName<>N'Google Adwords'



insert into [DW_TD].[Tb_Fact_IOS_Install_Report]
select 
	convert(date,@Date) ActiveDate,
	'IOS' OS,
	a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then N'NoGroup' else a.CampaignGroupName end CampaignGroupName,
	a.CampaignName,
  b.MemberNewStatus,
	UV,
	c.PlacedOrder,
	c.PlacedSales,
	c.PaymentOrder,
	c.PaymentSales,
	b.LastInstallPlacedOrder,
	b.LastInstallPlacedSales,
	b.LastInstallPaymentOrder,
	b.LastInstallPaymentSales,
	b.SevenDayInstallPlacedOrder,
	b.SevenDayInstallPlacedSales,
	b.SevenDayInstallPaymentOrder,
	b.SevenDayInstallPaymentSales,
	b.FourteenDayInstallPlacedOrder,
	b.FourteenDayInstallPlacedSales,
	b.FourteenDayInstallPaymentOrder,
	b.FourteenDayInstallPaymentSales,
	b.ThirtyDayInstallPlacedOrder,
	b.ThirtyDayInstallPlacedSales,
	b.ThirtyDayInstallPaymentOrder,
	b.ThirtyDayInstallPaymentSales,
	b.NinetyDayInstallPlacedOrder,
	b.NinetyDayInstallPlacedSales,
	b.NinetyDayInstallPaymentOrder,
	b.NinetyDayInstallPaymentSales,
	0 Flag
from #Campaign1 a
left join #Ascribe1 b on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
left join #and1 c on a.ChannelName=c.ChannelName and a.CampaignName=c.CampaignName and isnull(b.MemberNewStatus,'')=isnull(c.member_new_status,'')

--(
--	select 
--		b.ChannelName,
--		case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end CampaignGroupName,
--		b.CampaignName,
--		count(distinct case when a.LastInstall=1 and UVFlag=1 then a.IDFA end) UV,
--		count(distinct case when a.LastInstall=1 and UVFlag=0 then a.OrderID end) LastInstallPlacedOrder,
--		sum(distinct case when a.LastInstall=1 and UVFlag=0 then a.PayedAmount end) LastInstallPlacedSales,
--		count(distinct case when a.LastInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) LastInstallPaymentOrder,
--		sum(distinct case when a.LastInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) LastInstallPaymentSales,
--		count(distinct case when a.SevenDayInstall=1 and UVFlag=0 then a.OrderID end) SevenDayInstallPlacedOrder,
--		sum(distinct case when a.SevenDayInstall=1 and UVFlag=0 then a.PayedAmount end) SevenDayInstallPlacedSales,
--		count(distinct case when a.SevenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) SevenDayInstallPaymentOrder,
--		sum(distinct case when a.SevenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) SevenDayInstallPaymentSales,
--		count(distinct case when a.FourteenDayInstall=1 and UVFlag=0 then a.OrderID end) FourteenDayInstallPlacedOrder,
--		sum(distinct case when a.FourteenDayInstall=1 and UVFlag=0 then a.PayedAmount end) FourteenDayInstallPlacedSales,
--		count(distinct case when a.FourteenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) FourteenDayInstallPaymentOrder,
--		sum(distinct case when a.FourteenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) FourteenDayInstallPaymentSales
--	from #Campaign1 b 
--	left join [DW_TD].[Tb_Fact_IOS_Ascribe] a on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
--	where a.DateKey >= convert(varchar(8),@Start,112)
--	and a.DateKey < convert(varchar(8),@End,112)
--	group by b.ChannelName,
--		case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end ,
--		b.CampaignName
--)a
--left join 
--(
--select 
--	b.ChannelName ChannelName,
--	case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end CampaignGroupName,
--	b.CampaignName CampaignName,
--	count(distinct a.order_id) PlacedOrder,
--	isnull(sum(a.pay_amount),0) PlacedSales,
--	count(distinct case when a.is_placed_flag=1 then a.sales_order_number end) PaymentOrder,
--	isnull(sum(case when a.is_placed_flag=1 then a.payed_amount end),0) PaymentSales
--from #Campaign1 b
--left join #andoms1 a on a.channel_name=b.ChannelName and a.campaign_name=b.CampaignName
--group by b.ChannelName,
--	case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end ,
--	b.CampaignName
--)c on a.ChannelName=c.ChannelName and a.CampaignGroupName=c.CampaignGroupName and a.CampaignName=c.CampaignName

union all
select 
	convert(date,@Date) ActiveDate,
	'IOS' OS,
	a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then N'NoGroup' else a.CampaignGroupName end CampaignGroupName,
	null CampaignName,
	b.MemberNewStatus,
	UV,
	c.PlacedOrder,
	c.PlacedSales,
	c.PaymentOrder,
	c.PaymentSales,
	b.LastInstallPlacedOrder,
	b.LastInstallPlacedSales,
	b.LastInstallPaymentOrder,
	b.LastInstallPaymentSales,
	b.SevenDayInstallPlacedOrder,
	b.SevenDayInstallPlacedSales,
	b.SevenDayInstallPaymentOrder,
	b.SevenDayInstallPaymentSales,
	b.FourteenDayInstallPlacedOrder,
	b.FourteenDayInstallPlacedSales,
	b.FourteenDayInstallPaymentOrder,
	b.FourteenDayInstallPaymentSales,
	b.ThirtyDayInstallPlacedOrder,
	b.ThirtyDayInstallPlacedSales,
	b.ThirtyDayInstallPaymentOrder,
	b.ThirtyDayInstallPaymentSales,
	b.NinetyDayInstallPlacedOrder,
	b.NinetyDayInstallPlacedSales,
	b.NinetyDayInstallPaymentOrder,
	b.NinetyDayInstallPaymentSales,
	1 Flag
from (select distinct ChannelName,case when isnull(CampaignGroupName,'')='' then N'NoGroup' else CampaignGroupName end CampaignGroupName from #Campaign1)a
left join (
	select 
		b.ChannelName,
		case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end CampaignGroupName,
		a.MemberNewStatus,
		count(distinct case when a.LastInstall=1 and UVFlag=1 then a.IDFA end) UV,
		count(distinct case when a.LastInstall=1 and UVFlag=0 then a.OrderID end) LastInstallPlacedOrder,
		sum(distinct case when a.LastInstall=1 and UVFlag=0 then a.PayedAmount end) LastInstallPlacedSales,
		count(distinct case when a.LastInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) LastInstallPaymentOrder,
		sum(distinct case when a.LastInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) LastInstallPaymentSales,
		count(distinct case when a.SevenDayInstall=1 and UVFlag=0 then a.OrderID end) SevenDayInstallPlacedOrder,
		sum(distinct case when a.SevenDayInstall=1 and UVFlag=0 then a.PayedAmount end) SevenDayInstallPlacedSales,
		count(distinct case when a.SevenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) SevenDayInstallPaymentOrder,
		sum(distinct case when a.SevenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) SevenDayInstallPaymentSales,
		count(distinct case when a.FourteenDayInstall=1 and UVFlag=0 then a.OrderID end) FourteenDayInstallPlacedOrder,
		sum(distinct case when a.FourteenDayInstall=1 and UVFlag=0 then a.PayedAmount end) FourteenDayInstallPlacedSales,
		count(distinct case when a.FourteenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) FourteenDayInstallPaymentOrder,
		sum(distinct case when a.FourteenDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) FourteenDayInstallPaymentSales,
		count(distinct case when a.ThirtyDayInstall=1 and UVFlag=0 then a.OrderID end) ThirtyDayInstallPlacedOrder,
		sum(distinct case when a.ThirtyDayInstall=1 and UVFlag=0 then a.PayedAmount end) ThirtyDayInstallPlacedSales,
		count(distinct case when a.ThirtyDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) ThirtyDayInstallPaymentOrder,
		sum(distinct case when a.ThirtyDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) ThirtyDayInstallPaymentSales,
		count(distinct case when a.NinetyDayInstall=1 and UVFlag=0 then a.OrderID end) NinetyDayInstallPlacedOrder,
		sum(distinct case when a.NinetyDayInstall=1 and UVFlag=0 then a.PayedAmount end) NinetyDayInstallPlacedSales,
		count(distinct case when a.NinetyDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) NinetyDayInstallPaymentOrder,
		sum(distinct case when a.NinetyDayInstall=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) NinetyDayInstallPaymentSales
	from #Campaign1 b
	left join [DW_TD].[Tb_Fact_IOS_Install_Ascribe] a on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
	where a.DateKey >= convert(varchar(8),@Start,112)
	and a.DateKey < convert(varchar(8),@End,112)
	group by b.ChannelName,case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end,a.MemberNewStatus
)b on a.ChannelName=b.ChannelName and a.CampaignGroupName=b.CampaignGroupName
left join 
(
select 
	b.ChannelName ChannelName,
	case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end CampaignGroupName,
	a.member_new_status,
	count(distinct a.order_id) PlacedOrder,
	isnull(sum(a.pay_amount),0) PlacedSales,
	count(distinct case when a.is_placed_flag=1 then a.sales_order_number end) PaymentOrder,
	isnull(sum(case when a.is_placed_flag=1 then a.payed_amount end),0) PaymentSales
from #Campaign1 b
left join #andoms1 a on a.channel_name=b.ChannelName and a.campaign_name=b.CampaignName
group by b.ChannelName,case when isnull(b.CampaignGroupName,'')='' then 'Nogroup' else b.CampaignGroupName end,a.member_new_status
)c on a.ChannelName=c.ChannelName and a.CampaignGroupName=c.CampaignGroupName   and isnull(b.MemberNewStatus,'')=isnull(c.member_new_status,'')

drop table #Campaign1
drop table #oms1
drop table #IOSOrder
drop table #andoms1
drop table #and1
drop table #Ascribe1
GO
