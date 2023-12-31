/****** Object:  StoredProcedure [ODS_TD].[PKG_Test]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[PKG_Test] AS

declare @i int  
declare @Start date,@End date,@SevenStart date,@FourteenStart date,@ThirtyStart date, @NinetyStart date,@Date date
set @i=0
set @Date='2021-05-24'
while @i<101
begin
  --  update Student set demo = @i+5 where Uid=@i
 

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
		  ,user_id 
			--,case when  member_new_status ='NULL' then null 
			--else member_new_status end as  member_new_status
			,isnull(member_new_status,'') as member_new_status
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
	where 
	order_id is not null
	and order_time>= @Start
	and order_time < @End
	union
	select distinct a.pkg_key,a.order_id,convert(numeric(16,5),pay_amount) pay_amount
	from [ODS_TD].[Tb_PKG_PayOrder] a
	where
  order_id is not null and
  pay_time>= @Start
	and pay_time < @End
)a


select a.pkg_key,a.order_id,a.pay_amount,b.member_new_status,b.sales_order_number,b.is_placed_flag,
convert(numeric(15,2),b.payed_amount) payed_amount,b.user_id
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
where active_time >=@NinetyStart
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


select distinct pkg_key
into #pkg
from #pkgData
union
select distinct pkg_key
from #pkgoms

delete from  [DW_TD].[Tb_Fact_PKG_Ascribe_Temp] where ActiveDate= convert(date,@Date) 
insert into [DW_TD].[Tb_Fact_PKG_Ascribe_Temp]
select convert(date,@Date) ActiveDate,
'PKG' channel_name,f.pkg_key CampaignGroupName,'1D' as [attribution type],
isnull(b.member_new_status,''),
User_id
--into #paid
from #pkg f

left join (
	--last click
	select 
		isnull(pkg_key,'') as pkg_key,
		isnull(member_new_status,'') as member_new_status,
		count(distinct sales_order_number) PlacedOrder,
		sum(payed_amount) PlacedAmt,
		count(distinct case when is_placed_flag=1 then sales_order_number end) PaymentOrder,
		isnull(sum(case when is_placed_flag=1 then payed_amount end),0) PaymentAmt,
		count(distinct user_id)  [User_id]
	from (
		select distinct a.sales_order_number,is_placed_flag,convert(numeric(16,5),a.payed_amount) payed_amount,
		a.member_new_status,b.pkg_key,a.user_id
		from #oms a,#OneDay b
		where a.android_id=b.androidid  
		and isnull(a.android_id,'')<>''
		)a
	group by isnull(a.pkg_key,''),isnull(member_new_status,'')
)b on f.pkg_key=b.pkg_key 
--and isnull(b.member_new_status,'')=isnull(f.member_new_status,'')
and isnull(b.member_new_status,'') <> ''

drop table #oms
drop table #pkgorder
drop table #pkgoms
drop table #pkgData
drop table #OneDay
drop table #pkg

set @i=@i +1
set @Date=dateadd(dd,1,@Date)

END
GO
