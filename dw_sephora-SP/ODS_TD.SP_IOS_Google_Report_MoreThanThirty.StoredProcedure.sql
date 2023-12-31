/****** Object:  StoredProcedure [ODS_TD].[SP_IOS_Google_Report_MoreThanThirty]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_IOS_Google_Report_MoreThanThirty] @Date [date] AS
--declare @Date datetime='2020-09-03'


declare @Start datetime,@End datetime,@ThirtyStart datetime,@SixtyStart datetime

set @Start= @Date
set @End=dateadd(dd,1,@Date)
set @ThirtyStart= dateadd(dd,-29,@Date)
set @SixtyStart = dateadd(dd,-59,@Date)


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
where active_time >= @SixtyStart
and active_time < @End
and channel_name in (N'Google Adwords',N'GoogleAdwords')




select sales_order_number,is_placed_flag,convert(numeric(15,2),payed_amount) payed_amount,idfa
into #oms
from [ODS_TD].Tb_OMS_Order
where channel_cd='APP(IOS)'
and order_time>= @Start
and order_time< @End




--30Day
select *
into #ggthDay
from (
	select *,ROW_NUMBER()over(partition by androidid,channel_name,campaign_name order by ActiveTime desc) Num
	from #ggData
	where ActiveTime>= @ThirtyStart
	and ActiveTime< @End
	)a
where Num=1




--60Day
select *
into #ggSixDay
from (
	select *,ROW_NUMBER()over(partition by androidid,channel_name,campaign_name order by ActiveTime desc) Num
	from #ggData
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






delete from [DW_TD].[Tb_Fact_IOS_Report_MoreThanThirty]
where ChannelName=N'Google Adwords'
and [ActiveDate] >= @Start
and [ActiveDate]< @End


insert into [DW_TD].[Tb_Fact_IOS_Report_MoreThanThirty]
select convert(date,@Date)DateKey,
'IOS' OS,a.ChannelName,a.CampaignGroupName,null CampaignName,
isnull(b.PlacedOrder,0)PlacedOrder,isnull(b.PlacedAmt,0)PlacedAmt,
isnull(b.PaymentOrder,0)PaymentOrder,isnull(b.PaymentAmt,0)PaymentAmt,
isnull(c.PlacedOrder,0)PlacedOrder,isnull(c.PlacedAmt,0)PlacedAmt,
isnull(c.PaymentOrder,0)PaymentOrder,isnull(c.PaymentAmt,0)PaymentAmt,
1 Flag
from (
	select distinct
	c.ChannelName,
	case when isnull(c.CampaignGroupName,'')='' then 'Nogroup' else c.CampaignGroupName end CampaignGroupName
	from #Campaign c
	)a
left join (
	--30 click
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
		from #oms a,#ggthDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)b on a.CampaignGroupName=b.CampaignGroupName and a.ChannelName=b.ChannelName
left join (
	--60 last click
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
		from #oms a,#ggSixDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end
)c on a.CampaignGroupName=c.CampaignGroupName and a.ChannelName=c.ChannelName


union all
--明细
select convert(date,@Date)DateKey,
'IOS' OS,a.ChannelName,a.CampaignGroupName,a.CampaignName,
isnull(b.PlacedOrder,0)PlacedOrder,isnull(b.PlacedAmt,0)PlacedAmt,
isnull(b.PaymentOrder,0)PaymentOrder,isnull(b.PaymentAmt,0)PaymentAmt,
isnull(c.PlacedOrder,0)PlacedOrder,isnull(c.PlacedAmt,0)PlacedAmt,
isnull(c.PaymentOrder,0)PaymentOrder,isnull(c.PaymentAmt,0)PaymentAmt,
0 Flag
--into #paid
from (
	select distinct
	c.ChannelName,
	case when isnull(c.CampaignGroupName,'')='' then 'Nogroup' else c.CampaignGroupName end CampaignGroupName,
	c.CampaignName
	from #Campaign c
	)a
left join 
(
	--30 click
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
		from #oms a,#ggthDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,a.CampaignName
)b on a.CampaignGroupName=b.CampaignGroupName and a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
left join 
(
	--60 last click
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
		from #oms a,#ggSixDay b
		where a.idfa=b.androidid
		and isnull(a.idfa,'')<>''
	)b on a.CampaignName=b.campaign_name and b.channel_name=a.ChannelName 
	group by a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then 'Nogroup' else a.CampaignGroupName end,a.CampaignName
)c on a.CampaignGroupName=c.CampaignGroupName and a.ChannelName=c.ChannelName and a.CampaignName=c.CampaignName



drop table #ggData
drop table #oms
drop table #ggthDay
drop table #ggSixDay
drop table #Campaign

GO
