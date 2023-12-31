/****** Object:  StoredProcedure [ODS_TD].[SP_IOS_Click_Arrange_byday]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_IOS_Click_Arrange_byday] @startDate [date],@endDate [date],@Flag [int] AS

declare @Start date,@End date
set @Start=@startDate
set @End=@endDate

if @Flag=0
begin

	if (select count(*) from [ODS_TD].[Tb_IOS_Click_Arrange]
	where clicktime >= @Start
	and clicktime < @End
	and appkey is not null) > 0
	begin
		delete from [ODS_TD].[Tb_IOS_Click_Arrange]
		where clicktime >= @Start
		and clicktime < @End
		and appkey is not null
	end


	insert into [ODS_TD].[Tb_IOS_Click_Arrange]
	select  distinct *
	from (
	select clicktime,appkey,spreadname,
	case when channel_name='224' then N'巨量引擎' 
		 when channel_name='522' then N'百度oCPX' 
		 when channel_name='243' then N'超级粉丝通（原新浪应用家）'
		 when channel_name='530' then N'百度原生信息流常规投放'
		 when channel_name='222' then N'广点通'
		 when channel_name='465' then N'北京易彩'
		 when channel_name='419' then N'幽蓝互动'
		 when channel_name='45108' then N'语斐'
		 else channel_name 
	end channel_name,
	SUBSTRING(idfa,1,case when charindex('"',idfa)-1<0 then 0 else charindex('"',idfa)-1 end ) idfa
	from (
		select 
			clicktime,appkey,spreadname,channel_name,
			case when charindex('idfa',remark)=0 then '' else
				 case when SUBSTRING(remark,charindex('idfa',remark)+4,2)='""' then SUBSTRING(remark,charindex('idfa',remark)+10,100)
					  else SUBSTRING(remark,charindex('idfa',remark)+8,100) 
				 end 
			end [idfa]
		from [ODS_TD].[Tb_IOS_Click] a
		where clicktime >= @Start
		and clicktime < @End
		--and channel_name in (N'巨量引擎',N'224',N'百度oCPX',N'522',N'超级粉丝通（原新浪应用家）',N'243',N'百度原生信息流常规投放',N'530',N'广点通',N'222',N'幽蓝互动',N'419',N'北京易彩',N'465',N'语斐',N'533',N'Google Adwords')
		)a
	)a


	


	delete from [ODS_TD].[Tb_IOS_Click_Arrange]
	where idfa = 'NULL'

	delete from [ODS_TD].[Tb_IOS_Click_Arrange]
	where isnull(idfa,'') = ''

	delete from [ODS_TD].[Tb_IOS_Click_Arrange]
	where idfa = '00000000-0000-0000-0000-000000000000'

end

if @Flag=1
begin

	if (select count(*) from [ODS_TD].[Tb_IOS_Click_Arrange]
	where clicktime >= @Start
	and clicktime < @End
	and appkey is null) > 0
	begin
		delete from [ODS_TD].[Tb_IOS_Click_Arrange]
		where clicktime >= @Start
		and clicktime < @End
		and appkey is null
	end

	insert into [ODS_TD].[Tb_IOS_Click_Arrange]
	select [Date],null,[Campaign Name],[Channel Name],IDFA
	from [ODS_TD].[Tb_IOS_AdditionalClick]
	where [Date] >= @Start
	and [Date] < @End
	

end
GO
