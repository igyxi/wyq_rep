/****** Object:  StoredProcedure [ODS_TD].[SP_User_ReportComp]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_User_ReportComp] @Date [date] AS
declare @Start date,@End date
set @Start=@Date
set @End=dateadd(dd,1,@Date)

delete from DW_TD.Tb_User_ReportComp
where [Date]  = @Start
 
create table #Campaign(
	ChannelID nvarchar(64),
	ChannelName nvarchar(500),
	CampaignGroupName nvarchar(500),
	CampaignName nvarchar(500)
)

insert into #Campaign
select distinct a.ChannelID,a.ChannelName,a.CampaignGroupName,a.CampaignName
from [DW_TD].[Tb_Dim_CampaignMapping] a

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
where
(
 (type_cd <> 7 and order_time >= @Start and order_time < @End)
or
 (type_cd = 7 and place_time >= @Start and place_time < @End)
)



select *
into #Order
from (
	select distinct campaign_name,channel_name,order_id,convert(numeric(15,2),order_amount) pay_amount
	from ODS_TD.Tb_Android_Order 
	where
  order_id is not null and	order_time >= @Start
	and order_time < @End
	union
	select distinct campaign_name,channel_name,order_id,convert(numeric(15,2),pay_amount) pay_amount
	from ODS_TD.Tb_Android_PayOrder
	where
  order_id is not null and	pay_time >= @Start
	and pay_time < @End
		union  
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

select 
@Start [Date],
bb.channel_name,
bb.CampaignGroupName,
bb.member_new_status,
bb.UserCount,
bb.AttributionType
into #userAttribution 
from (
select 
@Start [Date],
a.channel_name,
c.CampaignGroupName,
b.member_new_status,
count(DISTINCT b.user_id) UserCount,
'TD Payment'  AttributionType
from #Campaign c
left join 
#Order a
on a.campaign_name=c.CampaignName and  a.channel_name=c.ChannelName
left join 
 #oms b on a.order_id=b.sales_order_number
 GROUP BY 
a.channel_name,
c.CampaignGroupName,
b.member_new_status



union all
select 
@Start [Date],
	a.ChannelName,
	c.CampaignGroupName,
	a.MemberNewStatus,
  count(DISTINCT b.user_id) UserCount
	,'1D Attribution'  AttributionType
	
from #Campaign c
left join 
(
select 
	ChannelName,
	CampaignName,
	MemberNewStatus,
  OrderID ,
	DateKey
from [DW_TD].[Tb_Fact_IOS_Ascribe] 
where  DateKey >= convert(varchar(8),@Start,112)
and  DateKey < convert(varchar(8),@End,112) 
and LastClick=1 and UVFlag=0 
union all 
select 
	ChannelName,
	CampaignName,
	MemberNewStatus,
  OrderID,
	DateKey
from 
[DW_TD].[Tb_Fact_Android_Ascribe]
where  DateKey >= convert(varchar(8),@Start,112)
and  DateKey < convert(varchar(8),@End,112)
and LastClick=1 and UVFlag=0 )a
on a.CampaignName=c.CampaignName and  a.ChannelName=c.ChannelName 
group by a.ChannelName,c.CampaignGroupName,a.MemberNewStatus
)bb

insert into DW_TD.Tb_User_ReportComp	
SELECT
	aa.[Date],
	aa.channel_name ChannelName,
	case when isnull(aa.CampaignGroupName,'')='' then 'Nogroup' else aa.CampaignGroupName end as CampaignGroupName,
	aa.AttributionType ,
  sum(aa.[RETURN]) 'RETURN',
  sum(aa.[BRAND_NEW]) 'BRAND_NEW',
  sum(aa.[CONVERT_NEW]) 'CONVERT_NEW'
FROM(

SELECT
	[Date],
	channel_name,
	CampaignGroupName,
CASE
	
	WHEN member_new_status = 'RETURN' THEN
	UserCount 
	END AS 'RETURN',
CASE
		
		WHEN member_new_status = 'BRAND_NEW' THEN
		UserCount 
	END AS 'BRAND_NEW',
CASE
		
		WHEN member_new_status = 'CONVERT_NEW' THEN
		UserCount 
	END AS 'CONVERT_NEW',
	AttributionType,
	UserCount 
FROM
#userAttribution)aa   
GROUP BY 
[Date],
	aa.channel_name,
case when isnull(aa.CampaignGroupName,'')='' then 'Nogroup' else aa.CampaignGroupName end,
aa.AttributionType 
	 

drop table #Campaign
drop table #oms
drop table #Order
drop table #userAttribution
GO
