/****** Object:  StoredProcedure [ODS_TD].[SP_IOS_User_Report]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_IOS_User_Report] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)

 


 
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
into #oms
from [ODS_TD].[Tb_OMS_Order]
where channel_cd='APP(IOS)'
and 
(
 (type_cd <> 7 and order_time >= @Start and order_time < @End)
or
 (type_cd = 7 and place_time >= @Start and place_time < @End)
)



select *
into #IOSOrder
from (
	select distinct a.campaign_name,a.channel_name,a.order_id,convert(numeric(15,2),order_amount) pay_amount
	from ODS_TD.Tb_IOS_Order a
	where
    order_id is not null 
and	order_time >= @Start
	and order_time < @End
	union
	select distinct a.campaign_name,a.channel_name,a.order_id,convert(numeric(15,2),pay_amount) pay_amount
	from ODS_TD.Tb_IOS_PayOrder a
	where
   order_id is not null and	pay_time >= @Start
	and pay_time < @End
)a
 

select a.campaign_name,a.channel_name,a.order_id,a.pay_amount,b.member_new_status,b.sales_order_number,b.is_placed_flag,convert(numeric(15,2),b.payed_amount) payed_amount
into #andoms
from #IOSOrder a
left join #oms b on a.order_id=b.sales_order_number


 
select 
	channel_name ChannelName,
	campaign_name CampaignName,
	member_new_status,
	count(distinct order_id) PlacedOrder,
	isnull(sum(convert(numeric(15,2),pay_amount)),0) PlacedSales,
	count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
	isnull(sum(case when is_placed_flag=1 then convert(numeric(15,2),payed_amount) end),0) PaymentSales
into #and
from #andoms a
group by channel_name,campaign_name,member_new_status


select 
	ChannelName,
	CampaignName,
	MemberNewStatus,
	count(distinct case when a.LastClick=1 and UVFlag=1 then a.IDFA end) UV,
	count(distinct case when a.LastClick=1 and UVFlag=0 then a.OrderID end) LastClickPlacedOrder,
	sum(distinct case when a.LastClick=1 and UVFlag=0 then a.PayedAmount end) LastClickPlacedSales,
	count(distinct case when a.LastClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.OrderID end) LastClickPaymentOrder,
	sum(distinct case when a.LastClick=1 and UVFlag=0 and a.IsPlacedFlag=1 then a.PayedAmount end) LastClickPaymentSales,
  count(DISTINCT b.user_id) UserCount
into #Ascribe
from [DW_TD].[Tb_Fact_IOS_Ascribe] a
inner join 
#oms b
on a.OrderID=b.sales_order_number
where a.DateKey >= convert(varchar(8),@Start,112)
and a.DateKey < convert(varchar(8),@End,112)
group by ChannelName,CampaignName,MemberNewStatus




delete from [DW_TD].[Tb_Fact_IOS_User_Report]
where ActiveDate >=@Start
and ActiveDate < @End
and ChannelName<>N'Google Adwords'



insert into [DW_TD].[Tb_Fact_IOS_User_Report]
select 
	convert(date,@Date) ActiveDate,
	'IOS' OS,
	a.ChannelName,
	case when isnull(a.CampaignGroupName,'')='' then N'NoGroup' else a.CampaignGroupName end CampaignGroupName,
	a.CampaignName,
	c.member_new_status MemberNewStatus,
	b.UserCount,
	UV,
	c.PlacedOrder,
	c.PlacedSales,
	c.PaymentOrder,
	c.PaymentSales,
	b.LastClickPlacedOrder,
	b.LastClickPlacedSales,
	b.LastClickPaymentOrder,
	b.LastClickPaymentSales,
	0 Flag
from #Campaign a
left join #and c on a.ChannelName=c.ChannelName and a.CampaignName=c.CampaignName
left join #Ascribe b on a.ChannelName=b.ChannelName and a.CampaignName=b.CampaignName
and isnull(b.MemberNewStatus,'') = isnull(c.member_new_status,'')	 
 

 

drop table #Campaign
drop table #oms
drop table #IOSOrder
drop table #andoms
drop table #and
drop table #Ascribe
GO
