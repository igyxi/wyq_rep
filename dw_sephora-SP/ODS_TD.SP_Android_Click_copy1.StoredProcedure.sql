/****** Object:  StoredProcedure [ODS_TD].[SP_Android_Click_copy1]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_Android_Click_copy1] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date, @ThirtyStart date,@NinetyStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @SevenStart=dateadd(dd,-6,@Date)
set @FourteenStart=dateadd(dd,-13,@Date)
set @ThirtyStart=dateadd(dd,-29,@Date)
set @NinetyStart=dateadd(dd,-89,@Date)


--获取14天的点击、激活、唤醒事件的数据
--ODS_TD.Tb_Android_FourteenClick_Temp属于临时物理表，先判断是否存在，存在则先删除，再创建
if object_id(N'ODS_TD.Tb_Android_NinetyClick_Temp',N'U') is not null
begin
	drop table ODS_TD.Tb_Android_NinetyClick_Temp
end

create table ODS_TD.Tb_Android_NinetyClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)


insert into ODS_TD.Tb_Android_NinetyClick_Temp
--点击事件
select *
from [ODS_TD].[Tb_Android_Click_Arrange]
where clicktime >= @NinetyStart
and clicktime < @End

union all
--激活事件
select distinct [active_time],'install',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].[Tb_Android_Install]
where [active_time] >= @NinetyStart
and [active_time] < @End

union all
--唤醒事件
select distinct deeplink_time,'wakeup',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].Tb_Android_Wakeup
where deeplink_time >= @NinetyStart
and deeplink_time < @End



--1Day
--ODS_TD.Tb_Android_OneClick_Temp属于临时物理表，先判断是否存在，存在则先删除，再创建
if object_id(N'ODS_TD.Tb_Android_OneClick_Temp',N'U') is not null
begin
	drop table ODS_TD.Tb_Android_OneClick_Temp
end

create table ODS_TD.Tb_Android_OneClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)

insert into ODS_TD.Tb_Android_OneClick_Temp
select *
from ODS_TD.Tb_Android_NinetyClick_Temp
where clicktime >= @Start
and clicktime < @End

--7Day
--ODS_TD.Tb_Android_SevenClick_Temp属于临时物理表，先判断是否存在，存在则先删除，再创建
if object_id(N'ODS_TD.Tb_Android_SevenClick_Temp',N'U') is not null
begin
	drop table ODS_TD.Tb_Android_SevenClick_Temp
end

create table ODS_TD.Tb_Android_SevenClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)


insert into ODS_TD.Tb_Android_SevenClick_Temp
select *
from ODS_TD.Tb_Android_NinetyClick_Temp
where clicktime >= @SevenStart
and clicktime < @End




--14
if object_id(N'ODS_TD.Tb_Android_FourteenClick_Temp',N'U') is not null
begin
	drop table ODS_TD.Tb_Android_FourteenClick_Temp
end

create table ODS_TD.Tb_Android_FourteenClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	androidid nvarchar(255),
	oaid nvarchar(255)
)


insert into ODS_TD.Tb_Android_FourteenClick_Temp
select *
from ODS_TD.Tb_Android_NinetyClick_Temp
where clicktime >= @FourteenStart
and clicktime < @End



--30

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
from ODS_TD.Tb_Android_NinetyClick_Temp
where clicktime >= @ThirtyStart
and clicktime < @End


--OMS
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
from [ODS_TD].Tb_OMS_Order
where channel_cd='APP(ANDROID)'
and 
(
 (type_cd <> 7 and order_time >= @Start and order_time < @End)
or
 (type_cd = 7 and place_time >= @Start and place_time < @End)
)


----------------------------------------------------------------------------------------------------
/*Last Click*/
----------------------------------------------------------------------------------------------------
--OneDay
--排序
--降序排列，取序号为1的数据
select *
into #oneday
from (
	select *,ROW_NUMBER()over(partition by androidid,spreadname,channel_name order by clicktime desc) Num 
	from(
		select a.androidid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_OneClick_Temp a
		where isnull(a.androidid,'')<>''
		and a.androidid<>'NULL'
		)a
	)b
where Num=1


--能与oms关联的androidid
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #oneandoms
from #oms a,#oneday b
where a.android_id=b.androidid
and isnull(a.android_id,'')<>''
and a.android_id <> 'NULL'



--排序
--oaid
select *
into #onedayoaid
from (
	select *,ROW_NUMBER()over(partition by oaid,spreadname,channel_name order by clicktime desc) Num
	from(
		select a.oaid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_OneClick_Temp a
		where a.androidid not in (select androidid from #oneandoms)
		and a.oaid not in ('00000000-0000-0000-0000-000000000000','00000000000000000000000000000000')
		and len(a.oaid)<>1
		and isnull(a.oaid,'')<>''
		)a
	)b
where Num=1


--用oaid关联到的oms
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #oneoaidoms
from #oms a,#onedayoaid b
where a.oaid=b.oaid
and isnull(a.oaid,'')<>''
and a.oaid <> 'NULL'


--------------------------------------------------------------------------------------------------------
/*7 Day Click*/
---------------------------------------------------------------------------------------------------------
--7Day
--排序
select *
into #SevenData
from (
	select *,ROW_NUMBER()over(partition by [androidid],spreadname,channel_name order by clicktime desc) Num
	from(
		select a.androidid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_SevenClick_Temp a
		where isnull(a.androidid,'')<>''
		and a.androidid <> 'NULL'
		)a
	)b
where Num=1


--能与oms关联的androidid
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #sevenandoms
from #oms a,#SevenData b
where a.android_id=b.androidid
and isnull(a.android_id,'')<>''
and a.android_id <> 'NULL'


--排序
--oaid
select *
into #SevenDataoaid
from (
	select *,ROW_NUMBER()over(partition by oaid,spreadname,channel_name order by clicktime desc) Num
	from(
		select a.oaid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_SevenClick_Temp a
		where androidid not in (select androidid from #sevenandoms)
		and a.oaid not in ('00000000-0000-0000-0000-000000000000','00000000000000000000000000000000')
		and len(a.oaid)<>1
		and isnull(a.oaid,'')<>''
		)a
	)b
where Num=1



--能与oms关联的oaid
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #sevenoaidoms
from #oms a,#SevenDataoaid b
where a.oaid=b.oaid
and isnull(a.oaid,'')<>''
and a.oaid <> 'NULL'


----------------------------------------------------------------------------------------------------------------
/*14 Day Click*/
----------------------------------------------------------------------------------------------------------------
--14Day
--排序
select *
into #ForteenData
from (
	select *,ROW_NUMBER()over(partition by [androidid],spreadname,channel_name order by clicktime desc) Num
	from(
		select a.androidid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_FourteenClick_Temp a
		where isnull(a.androidid,'')<>''
		and a.androidid <> 'NULL'
		)a
	)b
where Num=1


--能与oms关联的androidid
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #fourteenandoms
from #oms a,#ForteenData b
where a.android_id=b.androidid
and isnull(a.android_id,'')<>''
and a.android_id <> 'NULL'



--排序
--oaid
select *
into #ForteenDataoaid
from (
	select *,ROW_NUMBER()over(partition by oaid,spreadname,channel_name order by clicktime desc) Num
	from(
		select a.oaid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_FourteenClick_Temp a
		where androidid not in (select androidid from #fourteenandoms)
		and a.oaid not in ('00000000-0000-0000-0000-000000000000','00000000000000000000000000000000')
		and len(a.oaid)<>1
		and isnull(a.oaid,'')<>''
		)a
	)b
where Num=1


--能与oms关联的oaid
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #fourteenoaidoms
from #oms a,#ForteenDataoaid b
where a.oaid=b.oaid
and isnull(a.oaid,'')<>''
and a.oaid <> 'NULL'


----------------------------------------------------------------------------------------------------------------
/*30 Day Click*/
----------------------------------------------------------------------------------------------------------------
--30Day
--排序
select *
into #ThirtyData
from (
	select *,ROW_NUMBER()over(partition by [androidid],spreadname,channel_name order by clicktime desc) Num
	from(
		select a.androidid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_ThirtyClick_Temp a
		where isnull(a.androidid,'')<>''
		and a.androidid <> 'NULL'
		)a
	)b
where Num=1


--能与oms关联的androidid
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #Thirtyandoms
from #oms a,#ThirtyData b
where a.android_id=b.androidid
and isnull(a.android_id,'')<>''
and a.android_id <> 'NULL'



--排序
--oaid
select *
into #ThirtyDataoaid
from (
	select *,ROW_NUMBER()over(partition by oaid,spreadname,channel_name order by clicktime desc) Num
	from(
		select a.oaid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_ThirtyClick_Temp a
		where androidid not in (select androidid from #Thirtyandoms)
		and a.oaid not in ('00000000-0000-0000-0000-000000000000','00000000000000000000000000000000')
		and len(a.oaid)<>1
		and isnull(a.oaid,'')<>''
		)a
	)b
where Num=1


--能与oms关联的oaid
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #Thirtyoaidoms
from #oms a,#ThirtyDataoaid b
where a.oaid=b.oaid
and isnull(a.oaid,'')<>''
and a.oaid <> 'NULL'


----------------------------------------------------------------------------------------------------------------
/*90 Day Click*/
----------------------------------------------------------------------------------------------------------------
--90Day
--排序
select *
into #NinetyData
from (
	select *,ROW_NUMBER()over(partition by [androidid],spreadname,channel_name order by clicktime desc) Num
	from(
		select a.androidid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_NinetyClick_Temp a
		where isnull(a.androidid,'')<>''
		and a.androidid <> 'NULL'
		)a
	)b
where Num=1


--能与oms关联的androidid
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #Ninetyandoms
from #oms a,#NinetyData b
where a.android_id=b.androidid
and isnull(a.android_id,'')<>''
and a.android_id <> 'NULL'



--排序
--oaid
select *
into #NinetyDataoaid
from (
	select *,ROW_NUMBER()over(partition by oaid,spreadname,channel_name order by clicktime desc) Num
	from(
		select a.oaid,a.spreadname,a.channel_name,a.clicktime
		from ODS_TD.Tb_Android_NinetyClick_Temp a
		where androidid not in (select androidid from #Ninetyandoms)
		and a.oaid not in ('00000000-0000-0000-0000-000000000000','00000000000000000000000000000000')
		and len(a.oaid)<>1
		and isnull(a.oaid,'')<>''
		)a
	)b
where Num=1


--能与oms关联的oaid
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #Ninetyoaidoms
from #oms a,#NinetyDataoaid b
where a.oaid=b.oaid
and isnull(a.oaid,'')<>''
and a.oaid <> 'NULL'

----------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------------
---合并结果集
delete from [DW_TD].[Tb_Fact_Android_Ascribe]
where DateKey = convert(varchar(8),@Date,112)


insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
null OrderID,null member_new_status,null  member_daily_new_status, null member_monthly_new_status,null IsPlacedFlag,null PayedAmount,
1 LastClick,0 SevenClick,0 FourteenClick,0 ThirtyDayClick,0 NinetyDayClick,1 UVFlag
from #oneday a,[ODS_TD].[Tb_DeviceID] c
where c.[Date] >=@Start
and c.[Date] < @End
and c.OS='Android'
and a.[androidid]=c.DeviceId



--insert into [DW_TD].[Tb_Fact_Android_Ascribe]
--select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
--a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
--b.sales_order_number OrderID,b.is_placed_flag IsPlacedFlag,b.payed_amount PayedAmount,
--1 LastClick,1 SevenClick,1 FourteenClick,1 UVFlag
--from #oneday a
--left join #oms b on a.androidid=b.android_id and isnull(b.android_id,'')<>'' and b.android_id <> 'NULL'

insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
spreadname CampaignName,channel_name ChannelName,androidid AndroidId,
sales_order_number OrderID,member_new_status,member_daily_new_status,member_monthly_new_status,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 LastClick,1 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #oneandoms



--删除 7天点击出现在1天中的数据
delete a
from #sevenandoms a,#oneandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 14天点击出现在1天中的数据
delete a
from #fourteenandoms a,#oneandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 30天点击出现在1天中的数据
delete a
from #Thirtyandoms a,#oneandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 89天点击出现在1天中的数据
delete a
from #Ninetyandoms a,#oneandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name 

--插入剩余的7天点击数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
a.sales_order_number OrderID,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,a.is_placed_flag IsPlacedFlag,a.payed_amount PayedAmount,
0 LastClick,1 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #sevenandoms a


--删除 14天点击出现在7天中的数据
delete a
from #fourteenandoms a,#sevenandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 30天点击出现在1天中的数据
delete a
from #Thirtyandoms a,#sevenandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 89天点击出现在1天中的数据
delete a
from #Ninetyandoms a,#sevenandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name 

--插入剩余的14天点击数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
a.sales_order_number OrderID,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,a.is_placed_flag IsPlacedFlag,a.payed_amount PayedAmount,
0 LastClick,0 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #fourteenandoms a

--删除 30天点击出现在1天中的数据
delete a
from #Thirtyandoms a,#fourteenandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 89天点击出现在1天中的数据
delete a
from #Ninetyandoms a,#fourteenandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name 


--插入剩余的30天点击数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
a.sales_order_number OrderID,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,a.is_placed_flag IsPlacedFlag,a.payed_amount PayedAmount,
0 LastClick,0 SevenClick,0 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #Thirtyandoms a


--删除 89天点击出现在30天中的数据
delete a
from #Ninetyandoms a,#Thirtyandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name 

--插入剩余的90天点击数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
a.sales_order_number OrderID,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,a.is_placed_flag IsPlacedFlag,a.payed_amount PayedAmount,
0 LastClick,0 SevenClick,0 FourteenClick,0 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #Ninetyandoms a




--------UV
----排序
----oaid
--select *,ROW_NUMBER()over(partition by oaid,spreadname,channel_name order by clicktime) Num
--into #UVNumoaid
--from(
--select a.oaid,a.spreadname,a.channel_name,a.clicktime
--from #oneclick a
--where isnull(a.androidid,'')='' or a.androidid='NULL'
--and len(a.oaid)<>1
--and appkey<>'install'

--)a

----唯一
--select a.*
--into #UVoaid
--from #UVNumoaid a,
--(select oaid,spreadname,channel_name,max(Num)Num from #UVNumoaid 
--group by oaid,spreadname,channel_name)b
--where a.oaid=b.oaid
--and a.Num=b.Num
--and a.spreadname=b.spreadname
--and a.channel_name=b.channel_name


--insert into [DW_TD].[Tb_Fact_Android_Ascribe]
--select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
--a.spreadname CampaignName,a.channel_name ChannelName,a.oaid AndroidId,
--null OrderID,null IsPlacedFlag,null PayedAmount,
--1 LastClick,0 SevenClick,0 FourteenClick,1 UVFlag
--from #UVoaid a



--oaid 
--1Day
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,member_new_status,member_daily_new_status,member_monthly_new_status,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 LastClick,1 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #oneoaidoms



--删除 7天在1天中存在的数据
delete a
from #sevenoaidoms a,#oneoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 14天在1天中存在的数据
delete a
from #fourteenoaidoms a,#oneoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name


--删除30天在1天中存在的数据
delete a
from #Thirtyoaidoms a,#oneoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name


--删除 90天在1天中存在的数据
delete a
from #Ninetyoaidoms a,#oneoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name



--插入7天剩余数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,member_new_status,member_daily_new_status,member_monthly_new_status,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,1 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #sevenoaidoms


--删除 14天在7天中存在的数据
delete a
from #fourteenoaidoms a,#sevenoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 30天在7天中存在的数据
delete a
from #Thirtyoaidoms a,#sevenoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 90天在7天中存在的数据
delete a
from #Ninetyoaidoms a,#sevenoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name


--插入剩余14天数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,member_new_status,member_daily_new_status,member_monthly_new_status,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,0 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #Fourteenoaidoms

--删除 30天在14天中存在的数据
delete a
from #Thirtyoaidoms a,#Fourteenoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 90天在14天中存在的数据
delete a
from #Ninetyoaidoms a,#Fourteenoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name


--插入剩余30天数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,member_new_status,member_daily_new_status,member_monthly_new_status,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,0 SevenClick,0 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #Thirtyoaidoms
--删除 90天在14天中存在的数据
delete a
from #Ninetyoaidoms a,#Thirtyoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name


--插入剩余90天数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,member_new_status,member_daily_new_status,member_monthly_new_status,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,0 SevenClick,0 FourteenClick,0 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #Ninetyoaidoms


drop table #oms
drop table #oneday
drop table #oneandoms
drop table #onedayoaid
drop table #oneoaidoms
drop table #SevenData
drop table #sevenandoms
drop table #SevenDataoaid
drop table #sevenoaidoms
drop table #ForteenData
drop table #fourteenandoms
drop table #ForteenDataoaid
drop table #fourteenoaidoms
drop table #ThirtyData
drop table #Thirtyandoms
drop table #ThirtyDataoaid
drop table #Thirtyoaidoms
drop table #NinetyData
drop table #Ninetyandoms
drop table #NinetyDataoaid
drop table #Ninetyoaidoms
GO
