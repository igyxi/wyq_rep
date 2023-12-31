/****** Object:  StoredProcedure [TEMP].[SP_IOS_Google_Report_bak20210602]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_IOS_Google_Report_bak20210602] @Date [date] AS
--declare @Date datetime='2020-09-03'


declare @Start datetime,@End datetime,@SevenStart datetime,@FoueteenStart datetime

set @Start= @Date
set @End=dateadd(dd,1,@Date)
set @SevenStart= dateadd(dd,-6,@Date)
set @FoueteenStart = dateadd(dd,-13,@Date)


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
where active_time >= @FoueteenStart
and active_time < @End
and channel_name in (N'Google Adwords',N'GoogleAdwords')




select sales_order_number,is_placed_flag,convert(numeric(15,2),payed_amount) payed_amount,idfa
into #oms
from [ODS_TD].Tb_OMS_Order
where channel_cd='APP(IOS)'
and order_time>= @Start
and order_time< @End




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

select a.campaign_name,a.channel_name,a.order_id,a.pay_amount,b.sales_order_number,b.is_placed_flag,convert(numeric(15,2),b.payed_amount) payed_amount
into #ios
from #IOSOrder a
left join #oms b on a.order_id=b.sales_order_number




delete from [DW_TD].[Tb_Fact_IOS_Report]
where ChannelName=N'Google Adwords'
and [ActiveDate] >= @Start
and [ActiveDate]< @End


insert into [DW_TD].[Tb_Fact_IOS_Report]
select convert(date,@Date)DateKey,
'IOS' OS,a.ChannelName,a.CampaignGroupName,null CampaignName,a.uv UV,
isnull(d.PlacedOrder,0) PlacedOrder,isnull(d.PlacedAmt,0) PlacedAmt,
isnull(d.PaymentOrder,0) PaymentOrder,isnull(d.PaymentAmt,0) PaymentAmt,
isnull(b.PlacedOrder,0)PlacedOrder,isnull(b.PlacedAmt,0)PlacedAmt,
isnull(b.PaymentOrder,0)PaymentOrder,isnull(b.PaymentAmt,0)PaymentAmt,
isnull(c.PlacedOrder,0)PlacedOrder,isnull(c.PlacedAmt,0)PlacedAmt,
isnull(c.PaymentOrder,0)PaymentOrder,isnull(c.PaymentAmt,0)PaymentAmt,
isnull(e.PlacedOrder,0)PlacedOrder,isnull(e.PlacedAmt,0)PlacedAmt,
isnull(e.PaymentOrder,0)PaymentOrder,isnull(e.PaymentAmt,0)PaymentAmt,
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
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.campaign_name
		from #oms a,#ggOneDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)b on a.CampaignGroupName=b.CampaignGroupName and a.ChannelName=b.ChannelName
left join (
	--7 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.campaign_name
		from #oms a,#ggSevenDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)c on a.CampaignGroupName=c.CampaignGroupName and a.ChannelName=c.ChannelName
left join (
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		count(distinct b.order_id) PlacedOrder,
		sum(b.pay_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join #ios b on a.ChannelName=b.channel_name and a.CampaignName=b.campaign_name
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)d on a.CampaignGroupName=d.CampaignGroupName and a.ChannelName=d.ChannelName
left join (
	--14 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join 
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.campaign_name
		from #oms a,#ggFourteenDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)e on a.CampaignGroupName=e.CampaignGroupName and a.ChannelName=e.ChannelName


union all
--明细
select convert(date,@Date)DateKey,
'IOS' OS,a.ChannelName,a.CampaignGroupName,a.CampaignName,a.uv UV,
isnull(d.PlacedOrder,0) PlacedOrder,isnull(d.PlacedAmt,0) PlacedAmt,
isnull(d.PaymentOrder,0) PaymentOrder,isnull(d.PaymentAmt,0) PaymentAmt,
isnull(b.PlacedOrder,0)PlacedOrder,isnull(b.PlacedAmt,0)PlacedAmt,
isnull(b.PaymentOrder,0)PaymentOrder,isnull(b.PaymentAmt,0)PaymentAmt,
isnull(c.PlacedOrder,0)PlacedOrder,isnull(c.PlacedAmt,0)PlacedAmt,
isnull(c.PaymentOrder,0)PaymentOrder,isnull(c.PaymentAmt,0)PaymentAmt,
isnull(e.PlacedOrder,0)PlacedOrder,isnull(e.PlacedAmt,0)PlacedAmt,
isnull(e.PaymentOrder,0)PaymentOrder,isnull(e.PaymentAmt,0)PaymentAmt,
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
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.campaign_name
		from #oms a,#ggOneDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,a.CampaignName
)b on a.CampaignGroupName=b.CampaignGroupName and a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
left join 
(
	--7 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		a.CampaignName,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.campaign_name
		from #oms a,#ggSevenDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,a.CampaignName
)c on a.CampaignGroupName=c.CampaignGroupName and a.ChannelName=c.ChannelName and a.CampaignName=c.CampaignName
left join (
	select 
		a.ChannelName,a.CampaignName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		count(distinct b.order_id) PlacedOrder,
		sum(b.pay_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join #ios b on a.ChannelName=b.channel_name and a.CampaignName=b.campaign_name
	group by a.ChannelName,a.CampaignName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)d on a.CampaignGroupName=d.CampaignGroupName and a.ChannelName=d.ChannelName and a.CampaignName=d.CampaignName
left join (
	--14 last click
	select 
		a.ChannelName,
		case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end CampaignGroupName,
		a.CampaignName,
		count(distinct b.sales_order_number) PlacedOrder,
		sum(b.payed_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #Campaign a
	left join 
	(
		select distinct a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.campaign_name
		from #oms a,#ggFourteenDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,a.CampaignName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)e on a.CampaignGroupName=e.CampaignGroupName and a.ChannelName=e.ChannelName and a.CampaignName=e.CampaignName

drop table #ggData
drop table #oms
drop table #ggOneDay
drop table #ggSevenDay
drop table #ggFourteenDay
drop table #Campaign
drop table #IOSOrder
drop table #ios
GO
