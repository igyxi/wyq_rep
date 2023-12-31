/****** Object:  StoredProcedure [TEMP].[SP_PKG_Report_bak20210602]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_PKG_Report_bak20210602] @Date [date] AS

--declare @Date date='2020-09-03'

declare @Start date,@End date,@SevenStart date,@FourteenStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @SevenStart=dateadd(dd,-6,@Date)
set @FourteenStart=dateadd(dd,-13,@Date)



select *
into #oms
from [ODS_TD].[Tb_OMS_Order]
where channel_cd='APP(ANDROID)'
and order_time >= @Start
and order_time < @End



select *
into #pkgorder
from (
	select distinct a.pkg_key,a.order_id,convert(numeric(16,5),order_amount) pay_amount
	from [ODS_TD].[Tb_PKG_Order] a
	where order_time>= @Start
	and order_time < @End
	union
	select distinct a.pkg_key,a.order_id,convert(numeric(16,5),pay_amount) pay_amount
	from [ODS_TD].[Tb_PKG_PayOrder] a
	where pay_time>= @Start
	and pay_time < @End
)a


select a.pkg_key,a.order_id,a.pay_amount,b.sales_order_number,b.is_placed_flag,convert(numeric(15,2),b.payed_amount) payed_amount
into #pkgoms
from #pkgorder a
left join #oms b on a.order_id=b.sales_order_number



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
where active_time >= @FourteenStart
and active_time < @End
--and isnull(campaign_name,'')=''




--OneDay
select *
into #OneDay
from (
	select *,ROW_NUMBER()over(partition by androidid,pkg_key order by ActiveTime desc) Num
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
	select *,ROW_NUMBER()over(partition by androidid,pkg_key order by ActiveTime desc) Num
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
	select *,ROW_NUMBER()over(partition by androidid,pkg_key order by ActiveTime desc) Num
	from #pkgData
	where ActiveTime>=@FourteenStart
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
select convert(date,@Date) ActiveDate,
'Android' OS,'PKG' channel_name,f.pkg_key CampaignGroupName,null,a.uv UV,
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
from #pkg f
left join (
	--UV
	select a.pkg_key,
	count(distinct b.androidid)uv
	from #pkg a
	left join #OneDay b on a.pkg_key=b.pkg_key
	group by a.pkg_key
	)a on a.pkg_key=f.pkg_key
left join (
	--last click
	select 
		pkg_key,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,b.pkg_key
		from #oms a,#OneDay b
		where a.android_id=b.androidid
		and isnull(a.android_id,'')<>''
		)a
	group by a.pkg_key
)b on f.pkg_key=b.pkg_key
left join (
	--7 last click
	select 
		a.pkg_key,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,b.pkg_key
		from #oms a,#SevenDay b
		where a.android_id=b.androidid
		and isnull(a.android_id,'')<>''
		)a
	group by a.pkg_key
)c on f.pkg_key=c.pkg_key
left join (
	select 
	a.pkg_key,
	count(distinct b.order_id) PlacedOrder,
	sum(b.pay_amount) PlacedAmt,
	count(distinct case when b.is_placed_flag=1 then b.sales_order_number end) PaymentOrder,
	isnull(sum(case when b.is_placed_flag=1 then b.payed_amount end),0) PaymentAmt
	from #pkg a
	left join #pkgoms b on a.pkg_key=b.pkg_key
	group by a.pkg_key
)d on f.pkg_key=d.pkg_key
left join (
	--14 last click
	select 
		a.pkg_key,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,b.pkg_key
		from #oms a,#FourteenDay b
		where a.android_id=b.androidid
		and isnull(a.android_id,'')<>''
		)a
	group by a.pkg_key
)e on f.pkg_key=e.pkg_key


drop table #oms
drop table #pkgorder
drop table #pkgoms
drop table #pkgData
drop table #OneDay
drop table #SevenDay
drop table #FourteenDay
drop table #pkg
GO
