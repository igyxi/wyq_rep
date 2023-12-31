/****** Object:  StoredProcedure [ODS_TD].[SP_IOS_Click_MoreThanThirty]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_IOS_Click_MoreThanThirty] @Date [date] AS

declare @Start date,@End date,@ThirtyStart date,@SixtyStart date
set @Start=@Date
set @End=dateadd(dd,1,@Date)
set @ThirtyStart=dateadd(dd,-29,@Date)
set @SixtyStart=dateadd(dd,-59,@Date)


--60天点击、激活、唤醒事件数据
--使用物理临时表，先删除后创建
if object_id(N'ODS_TD.Tb_IOS_SixtyClick_Temp') is not null
begin
	drop table ODS_TD.Tb_IOS_SixtyClick_Temp
end

create table ODS_TD.Tb_IOS_SixtyClick_Temp
(
	clicktime datetime,
	appkey nvarchar(255),
	spreadname nvarchar(255),
	channel_name nvarchar(255),
	idfa nvarchar(255)
)

insert into ODS_TD.Tb_IOS_SixtyClick_Temp
--点击事件
select *
from [ODS_TD].Tb_IOS_Click_Arrange
where clicktime >= @SixtyStart
and clicktime < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')

union all
--激活事件
select distinct [active_time],'install',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Install
where [active_time] >= @SixtyStart
and [active_time] < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')

union all
--唤醒事件
select distinct deeplink_time,'wakeup',[campaign_name],[channel_name],idfa
from [ODS_TD].Tb_IOS_Wakeup
where deeplink_time >= @SixtyStart
and deeplink_time < @End
and [channel_name] not in ('Google Adwords','GoogleAdwords')


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
from ODS_TD.Tb_IOS_SixtyClick_Temp
where clicktime >= @ThirtyStart
and clicktime < @End




--OMS
select *
into #oms
from [ODS_TD].Tb_OMS_Order
where channel_cd='APP(IOS)'
and order_time>= @Start
and order_time< @End


----------------------------------------------------------------------------------------------------
--30Day
--排序
select *
into #thday
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by clicktime desc) Num
	from ODS_TD.Tb_IOS_ThirtyClick_Temp
)a
where Num=1


select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
into #th
from #oms a,#thday b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''


--------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--60Day
--排序
select *
into #SixData
from (
	select *,ROW_NUMBER()over(partition by [idfa],spreadname,channel_name order by clicktime desc) Num
	from ODS_TD.Tb_IOS_SixtyClick_Temp
	)a
where Num=1



select distinct a.idfa,a.sales_order_number,is_placed_flag,a.payed_amount,b.channel_name,b.spreadname
into #six
from #oms a,#SixData b
where a.idfa=b.idfa
and isnull(a.idfa,'')<>''


----------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
--合并结果集
--删除该天的非谷歌数据的归因数据，防止重复
delete from [DW_TD].[Tb_Fact_IOS_Ascribe_MoreThanThirty]
where DateKey = convert(varchar(8),@Date,112)
and ChannelName<>N'Google Adwords'


--30Click
insert into [DW_TD].[Tb_Fact_IOS_Ascribe_MoreThanThirty]
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
1 ThirtyClick,1 SixtyClick
from #th


--删除 60天点击出现在30天中的数据
delete a
from #six a,#th b
where a.idfa=b.idfa and a.sales_order_number=b.sales_order_number and a.spreadname=b.spreadname and a.channel_name=b.channel_name

--插入剩余的60天点击数据
insert into [DW_TD].[Tb_Fact_IOS_Ascribe_MoreThanThirty]
select convert(varchar(8),@Date,112) DateKey,'8DD42261C4214813A642A9796F8AD664' appkey,
spreadname CampaignName,channel_name ChannelName,idfa IDFA,
sales_order_number OrderID,is_placed_flag IsPlacedFlag,payed_amount PayedAmount,
0 ThirtyClick,1 SixtyClick
from #six



drop table #oms
drop table #thday
drop table #th
drop table #SixData
drop table #six

GO
