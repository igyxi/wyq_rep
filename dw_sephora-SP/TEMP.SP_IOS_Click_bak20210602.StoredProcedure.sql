/****** Object:  StoredProcedure [TEMP].[SP_IOS_Click_bak20210602]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_IOS_Click_bak20210602] @Date [date] AS

declare @Start date,@End date,@SevenStart date,@FourteenStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @SevenStart=dateadd(dd,-6,@Date)
set @FourteenStart=dateadd(dd,-13,@Date)


--14天点击、激活、唤醒事件数据
--使用物理临时表，先删除后创建
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
--点击事件
select *
from [ODS_TD].Tb_IOS_Click_Arrange
where clicktime >= @FourteenStart
and clicktime < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')

union all
--激活事件
select distinct [active_time],'install',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Install
where [active_time] >= @FourteenStart
and [active_time] < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')

union all
--唤醒事件
select distinct deeplink_time,'wakeup',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Wakeup
where deeplink_time >= @FourteenStart
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
from ODS_TD.Tb_IOS_FourteenClick_Temp
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
from ODS_TD.Tb_IOS_FourteenClick_Temp
where clicktime >= @SevenStart
and clicktime < @End


--OMS
select *
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


select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
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



select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
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




select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
into #fourteen
from #oms a,#ForteenData b
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
null OrderID,null IsPlacedFlag,null PayedAmount,
1 LastClick,0 SevenClick,0 FourteenClick,1 UVFlag
from #oneday a,[ODS_TD].[Tb_DeviceID] c
where c.[Date] >=@Start
and c.[Date] < @End
and c.OS='iOS'
and a.idfa=c.DeviceId


--LastClick
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 LastClick,1 SevenClick,1 FourteenClick,0 UVFlag
from #one


--删除 7天点击出现在1天中的数据
delete a
from #seven a,#one b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name
--删除 14天点击出现在1天中的数据
delete a
from #fourteen a,#one b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的7天点击数据
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,1 SevenClick,1 FourteenClick,0 UVFlag
from #seven

--删除 14天点击出现在7天中的数据
delete a
from #fourteen a,#seven b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的14天点击数据
insert into [DW_TD].Tb_Fact_IOS_Ascribe
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 LastClick,0 SevenClick,1 FourteenClick,0 UVFlag
from #fourteen



drop table #oms
drop table #oneday
drop table #one
drop table #SevenData
drop table #seven
drop table #ForteenData
drop table #fourteen
GO
