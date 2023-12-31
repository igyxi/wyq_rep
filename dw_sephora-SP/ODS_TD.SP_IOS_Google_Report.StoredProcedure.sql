/****** Object:  StoredProcedure [ODS_TD].[SP_IOS_Google_Report]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_IOS_Google_Report] @Date [date] AS
--declare @Date datetime='2020-09-03'


declare @Start datetime,@End datetime,@SevenStart datetime,@FoueteenStart datetime,@ThirtyStart datetime, @NinetyStart datetime
set @Start= @Date
set @End=dateadd(dd,1,@Date)
set @SevenStart= dateadd(dd,-6,@Date)
set @FoueteenStart = dateadd(dd,-13,@Date)
set @ThirtyStart= dateadd(dd,-29,@Date)
set @NinetyStart = dateadd(dd,-89,@Date)


----Google
create table #ggData
(
	ActiveTime date,
	channel_name nvarchar(255),
	campaign_name nvarchar(255),
	androidid nvarchar(255)
)

insert into #ggData
select active_time,case when channel_name=N'GoogleAdwords' then N'Google Adwords' else channel_name end channel_name,campaign_name,idfa
from [ODS_TD].[Tb_IOS_Install]
where active_time >= @NinetyStart
and active_time < @End
and channel_name in (N'Google Adwords',N'GoogleAdwords')




select 
sales_order_number
		  ,channel_cd
		  ,is_placed_flag
		  ,place_time
		  ,place_date
		  ,order_time
		  ,order_date
		  ,convert(numeric(15,2),payed_amount) payed_amount
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
into #oms
from [ODS_TD].Tb_OMS_Order
where channel_cd='APP(IOS)'
and 
(
 (type_cd <> 7 and order_time >= @Start and order_time < @End)
or
 (type_cd = 7 and place_time >= @Start and place_time < @End)
)
and is_placed_flag = 1




--OneDay
select *
into #ggOneDay
from (
	select *,ROW_NUMBER()over(partition by androidid,channel_name,campaign_name order by ActiveTime desc) Num
	from #ggData
	where ActiveTime>= @Start
	and ActiveTime< @End
	)a
where Num=1




--7Day
select *
into #ggSevenDay
from (
	select *,ROW_NUMBER()over(partition by androidid,channel_name,campaign_name order by ActiveTime desc) Num
	from #ggData
	where ActiveTime>= @SevenStart
	and ActiveTime<@End
	)a
where Num=1



--14Day
select *
into #ggFourteenDay
from (
	select *,ROW_NUMBER()over(partition by androidid,channel_name,campaign_name order by ActiveTime desc) Num
	from #ggData
	where ActiveTime>=@FoueteenStart
	and ActiveTime< @End
	)a
where Num=1

--30Day
select *
into #ggThirtyDay
from (
	select *,ROW_NUMBER()over(partition by androidid,channel_name,campaign_name order by ActiveTime desc) Num
	from #ggData
	where ActiveTime>=@ThirtyStart
	and ActiveTime< @End
	)a
where Num=1

--90Day
select *
into #ggNinetyDay
from (
	select *,ROW_NUMBER()over(partition by androidid,channel_name,campaign_name order by ActiveTime desc) Num
	from #ggData
	where ActiveTime>=@NinetyStart
	and ActiveTime< @End
	)a
where Num=1



create table #Campaign(
	ChannelID nvarchar(64),
	ChannelName nvarchar(500),
	CampaignGroupName nvarchar(500),
	CampaignName nvarchar(500)
)

insert into #Campaign
select a.ChannelID,'Google Adwords' ChannelName,a.CampaignGroupName,a.CampaignName
from [DW_TD].[Tb_Dim_CampaignMapping] a
where a.appkey='8DD42261C4214813A642A9796F8AD664'
and ChannelID=533



select *
into #IOSOrder
from (
	select distinct a.campaign_name,N'Google Adwords' channel_name,a.order_id,convert(numeric(15,2),order_amount) pay_amount
	from ODS_TD.Tb_IOS_Order a
	where order_time >= @Start
	and order_time < @End
	and channel_name in (N'GoogleAdwords', N'Google Adwords')
	union
	select distinct a.campaign_name,N'Google Adwords' channel_name,a.order_id,convert(numeric(15,2),pay_amount) pay_amount
	from ODS_TD.Tb_IOS_PayOrder a
	where pay_time >= @Start
	and pay_time < @End
	and channel_name in (N'GoogleAdwords', N'Google Adwords')
)a
--where channel_name in (N'巨量引擎',N'百度oCPX',N'超级粉丝通（原新浪应用家）',N'百度原生信息流常规投放',N'广点通',N'幽蓝互动',N'北京易彩',N'语斐',N'GoogleAdwords', N'Google Adwords')

select a.campaign_name,a.channel_name,a.order_id,a.pay_amount,b.member_new_status,b.sales_order_number,b.is_placed_flag,convert(numeric(15,2),b.payed_amount) payed_amount
into #ios
from #IOSOrder a
left join #oms b on a.order_id=b.sales_order_number




delete from [DW_TD].[Tb_Fact_IOS_Report]
where ChannelName=N'Google Adwords'
and [ActiveDate] >= @Start
and [ActiveDate]< @End


insert into [DW_TD].[Tb_Fact_IOS_Report]
select convert(date,@Date)DateKey,
'IOS' OS,a.ChannelName,a.CampaignGroupName,null CampaignName,
b.member_new_status,
a.uv UV,
isnull(d.PlacedOrder,0) PlacedOrder,
isnull(d.PlacedAmt,0) PlacedSales,
isnull(d.PaymentOrder,0) PaymentOrder,
isnull(d.PaymentAmt,0) PaymentSales,
isnull(b.PlacedOrder,0) LastClickPlacedOrder,
isnull(b.PlacedAmt,0)  LastClickPlacedSales,
isnull(b.PaymentOrder,0) LastClickPaymentOrder,
isnull(b.PaymentAmt,0) LastClickPaymentSales,
isnull(c.PlacedOrder,0) SevenDayClickPlacedOrder,
isnull(c.PlacedAmt,0) SevenDayClickPlacedSales,
isnull(c.PaymentOrder,0) SevenDayClickPaymentOrder,
isnull(c.PaymentAmt,0) SevenDayClickPaymentSales,
isnull(e.PlacedOrder,0) FourteenDayClickPlacedOrder,
isnull(e.PlacedAmt,0) FourteenDayClickPlacedSales,
isnull(e.PaymentOrder,0) FourteenDayClickPaymentOrder,
isnull(e.PaymentAmt,0) FourteenDayClickPaymentSales,
isnull(h.PlacedOrder,0) ThirtyDayClickPlacedOrder,
isnull(h.PlacedAmt,0) ThirtyDayClickPlacedSales,
isnull(h.PaymentOrder,0) ThirtyDayClickPaymentOrder,
isnull(h.PaymentAmt,0) ThirtyDayClickPaymentSales,
isnull(g.PlacedOrder,0) NinetyDayClickPlacedOrder,
isnull(g.PlacedAmt,0) NinetyDayClickPlacedSales,
isnull(g.PaymentOrder,0) NinetyDayClickPaymentOrder,
isnull(g.PaymentAmt,0) NinetyDayClickPaymentSales,
1 Flag
--into #paid
from (
	--UV
	select 
	c.ChannelName,
	case when isnull(c.CampaignGroupName,'')='' then 'Nogroup' else c.CampaignGroupName end CampaignGroupName,
	count(distinct a.androidid)uv
	from #Campaign c
	left join #ggOneDay a on a.campaign_name=c.CampaignName and a.channel_name=c.ChannelName 
	group by c.ChannelName,
	case when isnull(c.CampaignGroupName,'')='' then 'Nogroup' else c.CampaignGroupName end
	)a
left join (
	--last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggOneDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,member_new_status
)b on a.CampaignGroupName=b.CampaignGroupName and a.ChannelName=b.ChannelName
left join (
	--7 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggSevenDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,member_new_status
)c on a.CampaignGroupName=c.CampaignGroupName and a.ChannelName=c.ChannelName
left join (
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		count(distinct b.order_id) PlacedOrder,
		sum(b.pay_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join #ios b on a.ChannelName=b.channel_name and a.CampaignName=b.campaign_name
	group by a.ChannelName,b.member_new_status,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)d on a.CampaignGroupName=d.CampaignGroupName and a.ChannelName=d.ChannelName
and isnull(d.member_new_status,'') = isnull(b.member_new_status,'')
and d.member_new_status is not null

left join (
	--14 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join 
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggFourteenDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,member_new_status
)e on a.CampaignGroupName=e.CampaignGroupName and a.ChannelName=e.ChannelName
left join (
	--30 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join 
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggThirtyDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,member_new_status
)h on a.CampaignGroupName=h.CampaignGroupName and a.ChannelName=h.ChannelName
left join (
	--90 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join 
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggNinetyDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,member_new_status
)g on a.CampaignGroupName=g.CampaignGroupName and a.ChannelName=g.ChannelName


union all
--明细
select convert(date,@Date)DateKey,
'IOS' OS,a.ChannelName,a.CampaignGroupName,a.CampaignName,
b.member_new_status,
a.uv UV,
isnull(d.PlacedOrder,0) PlacedOrder,
isnull(d.PlacedAmt,0) PlacedSales,
isnull(d.PaymentOrder,0) PaymentOrder,
isnull(d.PaymentAmt,0) PaymentSales,
isnull(b.PlacedOrder,0) LastClickPlacedOrder,
isnull(b.PlacedAmt,0)  LastClickPlacedSales,
isnull(b.PaymentOrder,0) LastClickPaymentOrder,
isnull(b.PaymentAmt,0) LastClickPaymentSales,
isnull(c.PlacedOrder,0) SevenDayClickPlacedOrder,
isnull(c.PlacedAmt,0) SevenDayClickPlacedSales,
isnull(c.PaymentOrder,0) SevenDayClickPaymentOrder,
isnull(c.PaymentAmt,0) SevenDayClickPaymentSales,
isnull(e.PlacedOrder,0) FourteenDayClickPlacedOrder,
isnull(e.PlacedAmt,0) FourteenDayClickPlacedSales,
isnull(e.PaymentOrder,0) FourteenDayClickPaymentOrder,
isnull(e.PaymentAmt,0) FourteenDayClickPaymentSales,
isnull(h.PlacedOrder,0) ThirtyDayClickPlacedOrder,
isnull(h.PlacedAmt,0) ThirtyDayClickPlacedSales,
isnull(h.PaymentOrder,0) ThirtyDayClickPaymentOrder,
isnull(h.PaymentAmt,0) ThirtyDayClickPaymentSales,
isnull(g.PlacedOrder,0) NinetyDayClickPlacedOrder,
isnull(g.PlacedAmt,0) NinetyDayClickPlacedSales,
isnull(g.PaymentOrder,0) NinetyDayClickPaymentOrder,
isnull(g.PaymentAmt,0) NinetyDayClickPaymentSales,
0 Flag
--into #paid
from (
	--UV
	select 
	c.ChannelName,
	case when isnull(c.CampaignGroupName,'')='' then 'Nogroup' else c.CampaignGroupName end CampaignGroupName,
	c.CampaignName,
	count(distinct a.androidid)uv
	from #Campaign c
	left join #ggOneDay a on a.campaign_name=c.CampaignName and a.channel_name=c.ChannelName 
	group by c.ChannelName,c.CampaignName,
	case when isnull(c.CampaignGroupName,'')='' then 'Nogroup' else c.CampaignGroupName end
	)a
left join 
(
	--last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		a.CampaignName,
		b.member_new_status,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggOneDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,a.CampaignName,member_new_status
)b on a.CampaignGroupName=b.CampaignGroupName and a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
left join 
(
	--7 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		a.CampaignName,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggSevenDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,a.CampaignName,member_new_status
)c on a.CampaignGroupName=c.CampaignGroupName and a.ChannelName=c.ChannelName and a.CampaignName=c.CampaignName and b.member_new_status=c.member_new_status
left join (
	select 
		a.ChannelName,a.CampaignName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		count(distinct b.order_id) PlacedOrder,
		sum(b.pay_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join #ios b on a.ChannelName=b.channel_name and a.CampaignName=b.campaign_name
	group by a.ChannelName,a.CampaignName,b.member_new_status,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)d on a.CampaignGroupName=d.CampaignGroupName and a.ChannelName=d.ChannelName and a.CampaignName=d.CampaignName
and isnull(d.member_new_status,'') = isnull(b.member_new_status,'')
and d.member_new_status is not null
left join (
	--14 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		a.CampaignName,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join 
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggFourteenDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,a.CampaignName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,member_new_status
)e on a.CampaignGroupName=e.CampaignGroupName and a.ChannelName=e.ChannelName and a.CampaignName=e.CampaignName and b.member_new_status=e.member_new_status
left join (
	--30 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		a.CampaignName,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join 
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggThirtyDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,a.CampaignName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,member_new_status
)h on a.CampaignGroupName=h.CampaignGroupName and a.ChannelName=h.ChannelName and a.CampaignName=h.CampaignName and b.member_new_status=h.member_new_status

left join (
	--90 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		b.member_new_status,
		a.CampaignName,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join 
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,b.channel_name,b.campaign_name
		from #oms a,#ggNinetyDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,a.CampaignName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,member_new_status
)g on a.CampaignGroupName=g.CampaignGroupName and a.ChannelName=g.ChannelName and a.CampaignName=g.CampaignName and b.member_new_status=g.member_new_status


drop table #ggData
drop table #oms
drop table #ggOneDay
drop table #ggSevenDay
drop table #ggFourteenDay
drop table #ggThirtyDay
drop table #ggNinetyDay
drop table #Campaign
drop table #IOSOrder
drop table #ios
GO
