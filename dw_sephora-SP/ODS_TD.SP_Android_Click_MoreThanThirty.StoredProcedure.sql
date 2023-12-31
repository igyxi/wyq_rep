/****** Object:  StoredProcedure [ODS_TD].[SP_Android_Click_MoreThanThirty]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_Android_Click_MoreThanThirty] @Date [date] AS

declare @Start date,@End date,@ThirtyStart date,@SixtyStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @ThirtyStart=dateadd(dd,-29,@Date)
set @SixtyStart=dateadd(dd,-59,@Date)


--获取60天的点击、激活、唤醒事件的数据
--ODS_TD.Tb_Android_FourteenClick_Temp属于临时物理表，先判断是否存在，存在则先删除，再创建
if object_id(N'ODS_TD.Tb_Android_SixtyClick_Temp',N'U') is not null
begin
	drop table ODS_TD.Tb_Android_SixtyClick_Temp
end

create table ODS_TD.Tb_Android_SixtyClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)


insert into ODS_TD.Tb_Android_SixtyClick_Temp
--点击事件
select *
from [ODS_TD].[Tb_Android_Click_Arrange]
where clicktime >= @SixtyStart
and clicktime < @End

union all
--激活事件
select distinct [active_time],'install',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].[Tb_Android_Install]
where [active_time] >= @SixtyStart
and [active_time] < @End

union all
--唤醒事件
select distinct deeplink_time,'wakeup',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].Tb_Android_Wakeup
where deeplink_time >= @SixtyStart
and deeplink_time < @End



--30Day
--ODS_TD.Tb_Android_OneClick_Temp属于临时物理表，先判断是否存在，存在则先删除，再创建
if object_id(N'ODS_TD.Tb_Android_ThirtyClick_Temp',N'U') is not null
begin
	drop table ODS_TD.Tb_Android_ThirtyClick_Temp
end

create table ODS_TD.Tb_Android_ThirtyClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)

insert into ODS_TD.Tb_Android_ThirtyClick_Temp
select *
from ODS_TD.Tb_Android_SixtyClick_Temp
where clicktime >= @ThirtyStart
and clicktime < @End


--OMS
select *
into #oms
from [ODS_TD].Tb_OMS_Order
where channel_cd='APP(ANDROID)'
and order_time >= @Start
and order_time < @End


----------------------------------------------------------------------------------------------------
/*30 Click*/
----------------------------------------------------------------------------------------------------
--排序
--降序排列，取序号为1的数据
select *
into #thday
from (
	select *,ROW_NUMBER()over(partition by androidid,spreadname,channel_name order by clicktime desc) Num 
	from(
		select a.androidid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_ThirtyClick_Temp a
		where isnull(a.androidid,'')<>''
		and a.androidid<>'NULL'
		)a
	)b
where Num=1


--能与oms关联的androidid
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
into #thandoms
from #oms a,#thday b
where a.android_id=b.androidid
and isnull(a.android_id,'')<>''
and a.android_id <> 'NULL'



--排序
--oaid
select *
into #thdayoaid
from (
	select *,ROW_NUMBER()over(partition by oaid,spreadname,channel_name order by clicktime desc) Num
	from(
		select a.oaid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_ThirtyClick_Temp a
		where a.androidid not in (select androidid from #thandoms)
		and a.oaid not in ('00000000-0000-0000-0000-000000000000','00000000000000000000000000000000')
		and len(a.oaid)<>1
		and isnull(a.oaid,'')<>''
		)a
	)b
where Num=1


--用oaid关联到的oms
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
into #thoaidoms
from #oms a,#thdayoaid b
where a.oaid=b.oaid
and isnull(a.oaid,'')<>''
and a.oaid <> 'NULL'


--------------------------------------------------------------------------------------------------------
/*60 Day Click*/
---------------------------------------------------------------------------------------------------------
--排序
select *
into #SixData
from (
	select *,ROW_NUMBER()over(partition by [androidid],spreadname,channel_name order by clicktime desc) Num
	from(
		select a.androidid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_SixtyClick_Temp a
		where isnull(a.androidid,'')<>''
		and a.androidid <> 'NULL'
		)a
	)b
where Num=1


--能与oms关联的androidid
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
into #sixandoms
from #oms a,#SixData b
where a.android_id=b.androidid
and isnull(a.android_id,'')<>''
and a.android_id <> 'NULL'


--排序
--oaid
select *
into #SixDataoaid
from (
	select *,ROW_NUMBER()over(partition by oaid,spreadname,channel_name order by clicktime desc) Num
	from(
		select a.oaid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_SixtyClick_Temp a
		where androidid not in (select androidid from #sixandoms)
		and a.oaid not in ('00000000-0000-0000-0000-000000000000','00000000000000000000000000000000')
		and len(a.oaid)<>1
		and isnull(a.oaid,'')<>''
		)a
	)b
where Num=1



--能与oms关联的oaid
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
into #sixoaidoms
from #oms a,#SixDataoaid b
where a.oaid=b.oaid
and isnull(a.oaid,'')<>''
and a.oaid <> 'NULL'



----------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------------
---合并结果集
delete from [DW_TD].[Tb_Fact_Android_Ascribe_MoreThanThirty]
where DateKey = convert(varchar(8),@Date,112)



insert into [DW_TD].[Tb_Fact_Android_Ascribe_MoreThanThirty]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
spreadname CampaignName,channel_name ChannelName,androidid AndroidId,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 ThirtyClick,1 SixtyClick
from #thandoms


--删除 60天点击出现在30天中的数据
delete a
from #sixandoms a,#thandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的60天点击数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe_MoreThanThirty]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
a.sales_order_number OrderID,a.is_placed_flag IsPlacedFlag,a.payed_amount PayedAmount,
0 ThirtyClick,1 SixtyClick
from #sixandoms a



--oaid 
--1Day
insert into [DW_TD].[Tb_Fact_Android_Ascribe_MoreThanThirty]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 ThirtyClick,1 SixtyClick
from #thoaidoms


--删除 60天在30天中存在的数据
delete a
from #sixoaidoms a,#thoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余60天数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe_MoreThanThirty]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 ThirtyClick,1 SixtyClick
from #sixoaidoms




drop table #oms
drop table #thday
drop table #thandoms
drop table #thdayoaid
drop table #thoaidoms
drop table #SixData
drop table #sixandoms
drop table #SixDataoaid
drop table #sixoaidoms



GO
