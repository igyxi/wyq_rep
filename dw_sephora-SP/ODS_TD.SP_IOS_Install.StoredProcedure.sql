/****** Object:  StoredProcedure [ODS_TD].[SP_IOS_Install]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_IOS_Install] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date, @ThirtyStart date,@NinetyStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @SevenStart=dateadd(dd,-6,@Date)
set @FourteenStart=dateadd(dd,-13,@Date)
set @ThirtyStart=dateadd(dd,-29,@Date)
set @NinetyStart=dateadd(dd,-89,@Date)


--90天点击、激活、唤醒事件数据
--使用物理临时表，先删除后创建
if object_id(N'ODS_TD.Tb_IOS_NinetyInstall_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_NinetyInstall_Temp
end

create table ODS_TD.Tb_IOS_NinetyInstall_Temp
(
	Installtime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_NinetyInstall_Temp

--激活事件
select distinct [active_time],'install',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Install
where [active_time] >= @NinetyStart
and [active_time] < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')



--LastInstall
if object_id(N'ODS_TD.Tb_IOS_OneInstall_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_OneInstall_Temp
end

create table ODS_TD.Tb_IOS_OneInstall_Temp
(
	Installtime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_OneInstall_Temp
select *
from ODS_TD.Tb_IOS_NinetyInstall_Temp
where Installtime >= @Start
and Installtime < @End


--SevenInstall
if object_id(N'ODS_TD.Tb_IOS_SevenInstall_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_SevenInstall_Temp
end

create table ODS_TD.Tb_IOS_SevenInstall_Temp
(
	Installtime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_SevenInstall_Temp
select *
from ODS_TD.Tb_IOS_NinetyInstall_Temp
where Installtime >= @SevenStart
and Installtime < @End

--14
if object_id(N'ODS_TD.Tb_IOS_FourteenInstall_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_FourteenInstall_Temp
end

create table ODS_TD.Tb_IOS_FourteenInstall_Temp
(
	Installtime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)


insert into ODS_TD.Tb_IOS_FourteenInstall_Temp
select *
from ODS_TD.Tb_IOS_NinetyInstall_Temp
where Installtime >= @FourteenStart
and Installtime < @End


--30Install
if object_id(N'ODS_TD.Tb_IOS_ThirtyInstall_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_ThirtyInstall_Temp
end

create table ODS_TD.Tb_IOS_ThirtyInstall_Temp
(
	Installtime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_ThirtyInstall_Temp
select *
from ODS_TD.Tb_IOS_NinetyInstall_Temp
where Installtime >= @ThirtyStart
and Installtime < @End





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
into #oms1
from [ODS_TD].Tb_OMS_Order
where channel_cd='APP(IOS)'
and order_time>= @Start
and order_time< @End


----------------------------------------------------------------------------------------------------
--OneDay
--排序
select *
into #oneday1
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by Installtime desc) Num
	from ODS_TD.Tb_IOS_OneInstall_Temp
)a
where Num=1


select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #one1
from #oms1 a,#oneday1 b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''


--------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--7Day
--排序
select *
into #SevenData1
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by Installtime desc) Num
	from ODS_TD.Tb_IOS_SevenInstall_Temp
	)a
where Num=1



select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #seven1
from #oms1 a,#SevenData1 b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''

----------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--14Day
--排序
select *
into #ForteenData1
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by Installtime desc) Num
	from ODS_TD.Tb_IOS_FourteenInstall_Temp
	)a
where Num=1




select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #fourteen1
from #oms1 a,#ForteenData1 b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''



--30

--排序
select *
into #ThirtyData1
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by Installtime desc) Num
	from ODS_TD.Tb_IOS_ThirtyInstall_Temp
	)a
where Num=1




select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #Thirty1
from #oms1 a,#ThirtyData1 b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''


--90

--排序
select *
into #NinetyData1
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by Installtime desc) Num
	from ODS_TD.Tb_IOS_NinetyInstall_Temp
	)a
where Num=1




select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,a.member_new_status,a.member_daily_new_status,a.member_monthly_new_status,b.channel_name,b.spreadname
into #Ninety1
from #oms1 a,#NinetyData1 b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''

----------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--合并结果集
--删除该天的非谷歌数据的归因数据，防止重复
delete from [DW_TD].Tb_Fact_IOS_Install_Ascribe
where DateKey = convert(varchar(8),@Date,112)
and ChannelName<>N'Google Adwords'


--UV
insert into [DW_TD].Tb_Fact_IOS_Install_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
a.spreadname CampaignName,a.channel_name ChannelName,a.idfa IDFA,
null OrderID,null MemberNewStatus,null MemberDailyNewStatus,null MemberMonthlyNewStatus,null IsPlacedFlag,null PayedAmount,
1 LastInstall,0 SevenInstall,0 FourteenInstall,0 ThirtyDayInstall,0 NinetyDayInstall,1 UVFlag
from #oneday1 a,[ODS_TD].[Tb_DeviceID] c
where c.[Date] >=@Start
and c.[Date] < @End
and c.OS='iOS'
and a.idfa=c.DeviceId


--LastInstall
insert into [DW_TD].Tb_Fact_IOS_Install_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 LastInstall,1 SevenInstall,1 FourteenInstall,1 ThirtyDayInstall,1 NinetyDayInstall,0 UVFlag
from #one1


--删除 7天点击出现在1天中的数据
delete a
from #seven1 a,#one1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 14天点击出现在1天中的数据
delete a
from #fourteen1 a,#one1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 30天点击出现在1天中的数据
delete a
from #Thirty1 a,#one1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 90天点击出现在1天中的数据
delete a
from #Ninety1 a,#one1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的7天点击数据
insert into [DW_TD].Tb_Fact_IOS_Install_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastInstall,1 SevenInstall,1 FourteenInstall,1 ThirtyDayInstall,1 NinetyDayInstall,0 UVFlag
from #seven1

--删除 14天点击出现在7天中的数据
delete a
from #fourteen1 a,#seven1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--删除 30天点击出现在7天中的数据
delete a
from #Thirty1 a,#seven1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 90天点击出现在7天中的数据
delete a
from #Ninety1 a,#seven1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的14天点击数据
insert into [DW_TD].Tb_Fact_IOS_Install_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastInstall,0 SevenInstall,1 FourteenInstall,1 ThirtyDayInstall,1 NinetyDayInstall,0 UVFlag
from #fourteen1

--删除 30天点击出现在14天中的数据
delete a
from #Thirty1 a,#fourteen1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 90天点击出现在14天中的数据
delete a
from #Ninety1 a,#fourteen1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name


--插入剩余的30天点击数据
insert into [DW_TD].Tb_Fact_IOS_Install_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastInstall,0 SevenInstall,0 FourteenInstall,1 ThirtyDayInstall,1 NinetyDayInstall,0 UVFlag
from #Thirty1
--删除 90天点击出现在30天中的数据
delete a
from #Ninety1 a,#Thirty1 b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的90天点击数据
insert into [DW_TD].Tb_Fact_IOS_Install_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,member_new_status MenberNewStatus,member_daily_new_status MemberDailyNewStatus,member_monthly_new_status MemberMonthlyNewStatus,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastInstall,0 SevenInstall,0 FourteenInstall,0 ThirtyDayInstall,1 NinetyDayInstall,0 UVFlag
from #Ninety1


drop table #oms1
drop table #oneday1
drop table #one1
drop table #SevenData1
drop table #seven1
drop table #ForteenData1
drop table #fourteen1
drop table #ThirtyData1
drop table #Thirty1
drop table #NinetyData1
drop table #Ninety1
GO
