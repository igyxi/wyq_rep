/****** Object:  StoredProcedure [TEMP].[SP_Android_Click_bak20210602]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Android_Click_bak20210602] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @SevenStart=dateadd(dd,-6,@Date)
set @FourteenStart=dateadd(dd,-13,@Date)


--获取14天的点击、激活、唤醒事件的数据
--ODS_TD.Tb_Android_FourteenClick_Temp属于临时物理表，先判断是否存在，存在则先删除，再创建
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
--点击事件
select *
from [ODS_TD].[Tb_Android_Click_Arrange]
where clicktime >= @FourteenStart
and clicktime < @End

union all
--激活事件
select distinct [active_time],'install',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].[Tb_Android_Install]
where [active_time] >= @FourteenStart
and [active_time] < @End

union all
--唤醒事件
select distinct deeplink_time,'wakeup',[campaign_name],[channel_name],[android_id],'' oaid
from [ODS_TD].Tb_Android_Wakeup
where deeplink_time >= @FourteenStart
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
from ODS_TD.Tb_Android_FourteenClick_Temp
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
from ODS_TD.Tb_Android_FourteenClick_Temp
where clicktime >= @SevenStart
and clicktime < @End

--OMS
select *
into #oms
from [ODS_TD].Tb_OMS_Order
where channel_cd='APP(ANDROID)'
and order_time >= @Start
and order_time < @End


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
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
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
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
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
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
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
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
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
select distinct b.androidid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
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
select distinct b.oaid,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
into #fourteenoaidoms
from #oms a,#ForteenDataoaid b
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
null OrderID,null IsPlacedFlag,null PayedAmount,
1 LastClick,0 SevenClick,0 FourteenClick,1 UVFlag
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
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 LastClick,1 SevenClick,1 FourteenClick,0 UVFlag
from #oneandoms



--删除 7天点击出现在1天中的数据
delete a
from #sevenandoms a,#oneandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 14天点击出现在1天中的数据
delete a
from #fourteenandoms a,#oneandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的7天点击数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
a.sales_order_number OrderID,a.is_placed_flag IsPlacedFlag,a.payed_amount PayedAmount,
0 LastClick,1 SevenClick,1 FourteenClick,0 UVFlag
from #sevenandoms a


--删除 14天点击出现在7天中的数据
delete a
from #fourteenandoms a,#sevenandoms b
where a.androidid=b.androidid and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的14天点击数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.androidid AndroidId,
a.sales_order_number OrderID,a.is_placed_flag IsPlacedFlag,a.payed_amount PayedAmount,
0 LastClick,0 SevenClick,1 FourteenClick,0 UVFlag
from #fourteenandoms a



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
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 LastClick,1 SevenClick,1 FourteenClick,0 UVFlag
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

--插入7天剩余数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,1 SevenClick,1 FourteenClick,0 UVFlag
from #sevenoaidoms


--删除 14天在7天中存在的数据
delete a
from #fourteenoaidoms a,#sevenoaidoms b
where a.oaid=b.oaid and a.sales_order_number=b.sales_order_number
and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余14天数据
insert into [DW_TD].[Tb_Fact_Android_Ascribe]
select convert(varchar(8),@Date,112) DateKey,'A85FD453F75846BC8A8CA5046537EB5C' appkey,spreadname,channel_name,oaid,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,0 SevenClick,1 FourteenClick,0 UVFlag
from #sevenoaidoms



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
GO
