/****** Object:  StoredProcedure [ODS_TD].[SP_PKG_Report]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_PKG_Report] @Date [date] AS

--declare @Date date='2020-09-03'

declare @Start date,@End date,@SevenStart date,@FourteenStart date,@ThirtyStart date, @NinetyStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @SevenStart=dateadd(dd,-6,@Date)
set @FourteenStart=dateadd(dd,-13,@Date)
set @ThirtyStart=dateadd(dd,-29,@Date)
set @NinetyStart=dateadd(dd,-89,@Date)


select
	sales_order_number
	,channel_cd
	,is_placed_flag
	,place_time
	,place_date
	,order_time
	,order_date
	,payed_amount
	,[user_id]
	--,case when  member_new_status ='NULL' then null 
	--else member_new_status end as  member_new_status
	,isnull(member_new_status,'') as member_new_status
	,case when member_daily_new_status ='NULL' then null else member_daily_new_status end as member_daily_new_status
	,case when member_monthly_new_status ='NULL' then null else member_monthly_new_status end as member_monthly_new_status
	,idfa
	,android_id
	,oaid
	,trigger_time
into #oms
from [ODS_TD].[Tb_OMS_Order]
where channel_cd='APP(ANDROID)'
	and is_placed_flag=1
	and 
	(
		(type_cd <> 7 and order_time >= @Start and order_time < @End)
		or
		(type_cd = 7 and place_time >= @Start and place_time < @End)
	)



select *
into #pkgorder
from (
	select distinct a.pkg_key,a.order_id,convert(numeric(16,5),order_amount) pay_amount
	from [ODS_TD].[Tb_PKG_Order] a
	where order_id is not null
		and order_time>= @Start
		and order_time < @End
	union
	select distinct a.pkg_key,a.order_id,convert(numeric(16,5),pay_amount) pay_amount
	from [ODS_TD].[Tb_PKG_PayOrder] a
	where order_id is not null
		and pay_time>= @Start
		and pay_time < @End
)a


select a.pkg_key,a.order_id,a.pay_amount,b.member_new_status,b.sales_order_number,b.is_placed_flag,convert(numeric(15,2),b.payed_amount) payed_amount
into #pkgoms
from #pkgorder a
left join #oms b on a.order_id=b.sales_order_number
--join #oms b on a.order_id=b.sales_order_number


----PKG
create table #pkgData
(
	ActiveTime date,
	pkg_key nvarchar(255),
	androidid nvarchar(255),
	campaign_name nvarchar(255)
)

insert into #pkgData
select active_time,pkg_key,android_id,campaign_name
from [ODS_TD].[Tb_PKG_Install]
where active_time >= @NinetyStart
	and active_time < @End
--and isnull(campaign_name,'')=''


--OneDay
select *
into #OneDay
from (
	select *,ROW_NUMBER() OVER(PARTITION BY androidid,pkg_key ORDER BY ActiveTime DESC) Num
	from #pkgData
	where ActiveTime>= @Start
		and ActiveTime< @End
		and isnull(campaign_name,'')=''
)a
where Num=1


--7Day
select *
into #SevenDay
from (
	select *,ROW_NUMBER() OVER(PARTITION BY androidid,pkg_key ORDER BY ActiveTime DESC) Num
	from #pkgData
	where ActiveTime>= @SevenStart
		and ActiveTime<@End
		and isnull(campaign_name,'')=''
)a
where Num=1


--14Day
select *
into #FourteenDay
from (
	select *,ROW_NUMBER() OVER(PARTITION BY androidid,pkg_key ORDER BY ActiveTime DESC) Num
	from #pkgData
	where ActiveTime>=@FourteenStart
		and ActiveTime< @End
		and isnull(campaign_name,'')=''
)a
where Num=1

--30Day
select *
into #ThirtyDay
from (
	select *,ROW_NUMBER() OVER(PARTITION BY androidid,pkg_key ORDER BY ActiveTime DESC) Num
	from #pkgData
	where ActiveTime>=@ThirtyStart
		and ActiveTime< @End
		and isnull(campaign_name,'')=''
)a
where Num=1

--90Day
select *
into #NinetyDay
from (
	select *,ROW_NUMBER() OVER(PARTITION BY androidid,pkg_key ORDER BY ActiveTime DESC) Num
	from #pkgData
	where ActiveTime>=@NinetyStart
		and ActiveTime< @End
		and isnull(campaign_name,'')=''
)a
where Num=1


select distinct pkg_key
into #pkg
from #pkgData
union
select distinct pkg_key
from #pkgoms


delete from [DW_TD].[Tb_Fact_Android_Report]
where [ActiveDate] >= @Start
and [ActiveDate] < @End
and ChannelName=N'PKG'


insert into [DW_TD].[Tb_Fact_Android_Report]
select
	convert(date,@Date) ActiveDate,
	'Android' OS,
	'PKG' channel_name,
	f.pkg_key CampaignGroupName,
	null,
	d.member_new_status,
	a.uv UV,
	isnull(d.PlacedOrder,0) PlacedOrder,
	isnull(d.PlacedAmt,0) PlacedAmt,
	isnull(d.PaymentOrder,0) PaymentOrder,
	isnull(d.PaymentAmt,0) PaymentAmt,
	isnull(b.PlacedOrder,0)PlacedOrder,
	isnull(b.PlacedAmt,0)PlacedAmt,
	isnull(b.PaymentOrder,0)PaymentOrder,
	isnull(b.PaymentAmt,0)PaymentAmt,
	isnull(c.PlacedOrder,0)PlacedOrder,
	isnull(c.PlacedAmt,0)PlacedAmt,
	isnull(c.PaymentOrder,0)PaymentOrder,
	isnull(c.PaymentAmt,0)PaymentAmt,
	isnull(e.PlacedOrder,0)PlacedOrder,
	isnull(e.PlacedAmt,0)PlacedAmt,
	isnull(e.PaymentOrder,0)PaymentOrder,
	isnull(e.PaymentAmt,0)PaymentAmt,
	isnull(h.PlacedOrder,0)PlacedOrder,
	isnull(h.PlacedAmt,0)PlacedAmt,
	isnull(h.PaymentOrder,0)PaymentOrder,
	isnull(h.PaymentAmt,0)PaymentAmt,
	isnull(g.PlacedOrder,0)PlacedOrder,
	isnull(g.PlacedAmt,0)PlacedAmt,
	isnull(g.PaymentOrder,0)PaymentOrder,
	isnull(g.PaymentAmt,0)PaymentAmt,
	1 Flag
	--into #paid
from #pkg f
left join (
	--UV
	select
		a.pkg_key,
		count(distinct b.androidid) AS uv
	from #pkg a
	left join #OneDay b on a.pkg_key=b.pkg_key
	group by a.pkg_key
)a on a.pkg_key=f.pkg_key
left join (
	select
		a.pkg_key,
		count(distinct b.order_id) PlacedOrder,
		sum(b.pay_amount) PlacedAmt,
		count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
		isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt,
		b.member_new_status
	from #pkg a
	left join #pkgoms b on a.pkg_key=b.pkg_key
	group by a.pkg_key,b.member_new_status
)d on f.pkg_key=d.pkg_key 
-- and isnull(b.member_new_status,'')=isnull(d.member_new_status,'')
left join (
	--last click
	select 
		pkg_key,
		member_new_status,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,a.member_new_status,b.pkg_key
		from #oms a,#OneDay b
		where a.android_id=b.androidid  
		and isnull(a.android_id,'')<>''
	)a
	group by a.pkg_key,member_new_status
)b on f.pkg_key=b.pkg_key 
	and isnull(b.member_new_status,'')=isnull(d.member_new_status,'')
	and isnull(d.member_new_status,'') <> ''
left join (
	--7 last click
	select 
		a.pkg_key,
		a.member_new_status,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,a.member_new_status,b.pkg_key
		from #oms a,#SevenDay b
		where a.android_id=b.androidid
			and isnull(a.android_id,'')<>''
			and a.member_new_status is not null
	)a
	group by a.pkg_key,a.member_new_status
)c on f.pkg_key=c.pkg_key 
	and isnull(d.member_new_status,'not need')=isnull(c.member_new_status,'')
left join (
	--14 last click
	select 
		a.pkg_key,
		a.member_new_status,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,a.member_new_status,b.pkg_key
		from #oms a,#FourteenDay b
		where a.android_id=b.androidid
		and isnull(a.android_id,'')<>''
	)a
	group by a.pkg_key,a.member_new_status
)e on f.pkg_key=e.pkg_key
	and isnull(d.member_new_status,'not need')=isnull(e.member_new_status,'')
left join (
	--30 last click
	select 
		a.pkg_key,
		a.member_new_status,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,a.member_new_status,b.pkg_key
		from #oms a,#ThirtyDay b
		where a.android_id=b.androidid
			and isnull(a.android_id,'')<>''
	)a
	group by a.pkg_key,a.member_new_status
)h on f.pkg_key=h.pkg_key 
	and isnull(d.member_new_status,'not need')=isnull(h.member_new_status,'')
left join (
	--90 last click
	select 
		a.pkg_key,
		a.member_new_status,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,a.member_new_status,b.pkg_key
		from #oms a,#NinetyDay b
		where a.android_id=b.androidid
			and isnull(a.android_id,'')<>''
	)a
	group by a.pkg_key,a.member_new_status
)g on f.pkg_key=g.pkg_key 
	and isnull(d.member_new_status,'not need')=isnull(g.member_new_status,'')



drop table #oms
drop table #pkgorder
drop table #pkgoms
drop table #pkgData
drop table #OneDay
drop table #SevenDay
drop table #ThirtyDay
drop table #NinetyDay
drop table #FourteenDay
drop table #pkg
GO
