/****** Object:  StoredProcedure [ODS_TD].[SP_IOS_Click_copy1]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_IOS_Click_copy1] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date, @ThirtyStart date,@NinetyStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @SevenStart=dateadd(dd,-6,@Date)
set @FourteenStart=dateadd(dd,-13,@Date)
set @ThirtyStart=dateadd(dd,-29,@Date)
set @NinetyStart=dateadd(dd,-89,@Date)


--90天点击、激活、唤醒事件数据
--使用物理临时表，先删除后创建
if object_id(N'ODS_TD.Tb_IOS_NinetyClick_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_NinetyClick_Temp
end

create table ODS_TD.Tb_IOS_NinetyClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_NinetyClick_Temp
--点击事件
select *
from [ODS_TD].Tb_IOS_Click_Arrange
where clicktime >= @NinetyStart
and clicktime < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')

union all
--激活事件
select distinct [active_time],'install',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Install
where [active_time] >= @NinetyStart
and [active_time] < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')

union all
--唤醒事件
select distinct deeplink_time,'wakeup',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Wakeup
where deeplink_time >= @NinetyStart
and deeplink_time < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')


--Lastclick
if object_id(N'ODS_TD.Tb_IOS_OneClick_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_OneClick_Temp
end

create table ODS_TD.Tb_IOS_OneClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_OneClick_Temp
select *
from ODS_TD.Tb_IOS_NinetyClick_Temp
where clicktime >= @Start
and clicktime < @End


--Sevenclick
if object_id(N'ODS_TD.Tb_IOS_SevenClick_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_SevenClick_Temp
end

create table ODS_TD.Tb_IOS_SevenClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_SevenClick_Temp
select *
from ODS_TD.Tb_IOS_NinetyClick_Temp
where clicktime >= @SevenStart
and clicktime < @End

--14
if object_id(N'ODS_TD.Tb_IOS_FourteenClick_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_FourteenClick_Temp
end

create table ODS_TD.Tb_IOS_FourteenClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)


insert into ODS_TD.Tb_IOS_FourteenClick_Temp
select *
from ODS_TD.Tb_IOS_NinetyClick_Temp
where clicktime >= @FourteenStart
and clicktime < @End


--30click
if object_id(N'ODS_TD.Tb_IOS_ThirtyClick_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_ThirtyClick_Temp
end

create table ODS_TD.Tb_IOS_ThirtyClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_ThirtyClick_Temp
select *
from ODS_TD.Tb_IOS_NinetyClick_Temp
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
where channel_cd='APP(IOS)'
and order_time>= @Start
and order_time< @End


----------------------------------------------------------------------------------------------------
--OneDay
--排序
select *
into #oneday
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by clicktime desc) Num
	from ODS_TD.Tb_IOS_OneClick_Temp
)a
where Num=1


select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #one
from #oms a,#oneday b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''


--------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--7Day
--排序
select *
into #SevenData
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by clicktime desc) Num
	from ODS_TD.Tb_IOS_SevenClick_Temp
	)a
where Num=1



select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #seven
from #oms a,#SevenData b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''

----------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--14Day
--排序
select *
into #ForteenData
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by clicktime desc) Num
	from ODS_TD.Tb_IOS_FourteenClick_Temp
	)a
where Num=1




select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #fourteen
from #oms a,#ForteenData b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''



--30

--排序
select *
into #ThirtyData
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by clicktime desc) Num
	from ODS_TD.Tb_IOS_ThirtyClick_Temp
	)a
where Num=1




select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #Thirty
from #oms a,#ThirtyData b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''


--90

--排序
select *
into #NinetyData
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by clicktime desc) Num
	from ODS_TD.Tb_IOS_NinetyClick_Temp
	)a
where Num=1




select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #Ninety
from #oms a,#NinetyData b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''

----------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--合并结果集
--删除该天的非谷歌数据的归因数据，防止重复
delete from [DW_TD].Tb_Fact_IOS_Ascribe
where DateKey = convert(varchar(8),@Date,112)
and ChannelName<>N'Google Adwords'


--UV
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.idfa IDFA,
null OrderID,null MemberNewStatus,null MemberDailyNewStatus,null MemberMonthlyNewStatus,null IsPlacedFlag,null PayedAmount,
1 LastClick,0 SevenClick,0 FourteenClick,0 ThirtyDayClick,0 NinetyDayClick,1 UVFlag
from #oneday a,[ODS_TD].[Tb_DeviceID] c
where c.[Date] >=@Start
and c.[Date] < @End
and c.OS='iOS'
and a.idfa=c.DeviceId


--LastClick
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 LastClick,1 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #one


--删除 7天点击出现在1天中的数据
delete a
from #seven a,#one b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 14天点击出现在1天中的数据
delete a
from #fourteen a,#one b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 30天点击出现在1天中的数据
delete a
from #Thirty a,#one b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 90天点击出现在1天中的数据
delete a
from #Ninety a,#one b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的7天点击数据
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,1 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #seven

--删除 14天点击出现在7天中的数据
delete a
from #fourteen a,#seven b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 30天点击出现在7天中的数据
delete a
from #Thirty a,#seven b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 90天点击出现在7天中的数据
delete a
from #Ninety a,#seven b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的14天点击数据
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,0 SevenClick,1 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #fourteen

--删除 30天点击出现在14天中的数据
delete a
from #Thirty a,#fourteen b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 90天点击出现在14天中的数据
delete a
from #Ninety a,#fourteen b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name


--插入剩余的30天点击数据
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,0 SevenClick,0 FourteenClick,1 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #Thirty
--删除 90天点击出现在30天中的数据
delete a
from #Ninety a,#Thirty b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的90天点击数据
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,0 SevenClick,0 FourteenClick,0 ThirtyDayClick,1 NinetyDayClick,0 UVFlag
from #Ninety


drop table #oms
drop table #oneday
drop table #one
drop table #SevenData
drop table #seven
drop table #ForteenData
drop table #fourteen
drop table #ThirtyData
drop table #Thirty
drop table #NinetyData
drop table #Ninety
GO
