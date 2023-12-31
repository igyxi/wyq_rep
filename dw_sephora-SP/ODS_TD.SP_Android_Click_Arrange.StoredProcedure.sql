/****** Object:  StoredProcedure [ODS_TD].[SP_Android_Click_Arrange]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_TD].[SP_Android_Click_Arrange] @Date [date],@Flag [int] AS

declare @Start date,@End date
set @Start=@Date
set @End=dateadd(dd,1,@Date)

if @Flag = 0
begin

	
	if (select count(*) from [ODS_TD].[Tb_Android_Click_Arrange]
	where clicktime >= @Start
	and clicktime < @End
	and appkey is not null) > 0
	begin
		delete from [ODS_TD].[Tb_Android_Click_Arrange]
		where clicktime >= @Start
		and clicktime < @End
		and appkey is not null
	end


	insert into [ODS_TD].[Tb_Android_Click_Arrange]
	select distinct *
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
	--SUBSTRING(androidid,1,case when charindex('"',androidid)-1<0 then 0 else charindex('"',androidid)-1 end ) androidid,
	--SUBSTRING(oaid,1,case when charindex('"',oaid)-1<0 then 0 else charindex('"',oaid)-1 end ) oaid
	androidid,
	oaid
	from (
		select 
			clicktime,appkey,spreadname,channel_name,
			--case when charindex('androidid',remark)=0 then '' else
			--	case when SUBSTRING(remark,charindex('androidid',remark)+9,2)='""' 
			--			then SUBSTRING(remark,charindex('androidid',remark)+15,60)
			--	else SUBSTRING(remark,charindex('androidid',remark)+13,30)
			--	end 
			--end androidid,
			--case when charindex('oaid',remark)=0 then '' else
			--	case when SUBSTRING(remark,charindex('oaid',remark)+4,2)='""' 
			--			then SUBSTRING(remark,charindex('oaid',remark)+10,200)
			--	else SUBSTRING(remark,charindex('oaid',remark)+8,200)
			--	end 
			--end oaid
			isnull(replace(replace(JSON_QUERY([remark],'$.androidid_md5_1'),'["',''),'"]',''), replace(replace(JSON_QUERY([remark],'$.androidid'),'["',''),'"]',''))as androidid
			,replace(replace(JSON_QUERY([remark],'$.oaid'),'["',''),'"]','') as oaid
		from [ODS_TD].[Tb_Android_Click] a
		where clicktime >= @Start
		and clicktime < @End
		and ISJSON([remark]) > 0
		--and channel_name in (N'巨量引擎',N'224',N'百度oCPX',N'522',N'超级粉丝通（原新浪应用家）',N'243',N'百度原生信息流常规投放',N'530',N'广点通',N'222',N'幽蓝互动',N'419',N'北京易彩',N'465',N'语斐',N'45108',N'Google Adwords',N'533')
		)a
	)a




	--删除
	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid='unknown'
	and oaid='__OAID__'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid=''
	and oaid=''


	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid='NULL'
	and oaid='NULL'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid='NULL'
	and oaid=''


	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid=''
	and oaid='NULL'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid='{androidid}'
	and oaid=''

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid=''
	and oaid='0'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid=''
	and oaid='{oaid}'


	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid='__ANDROIDID1__'
	and oaid='__OAID__'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where isnull(androidid,'')=''
	and oaid='__OAID__'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where isnull(androidid,'')=''
	and oaid='__oaid__'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where isnull(androidid,'')=''
	and oaid='undefined'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where androidid='NULL'
	and oaid='00000000000000000000000000000000'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where isnull(androidid,'')=''
	and oaid='00000000000000000000000000000000'

	delete from [ODS_TD].[Tb_Android_Click_Arrange]
	where len(oaid)=1
	and androidid=N'None'

end


if @Flag = 1
begin

	if (select count(*) from [ODS_TD].[Tb_Android_Click_Arrange]
	where clicktime >= @Start
	and clicktime < @End
	and appkey is null) > 0
	begin 
		delete from [ODS_TD].[Tb_Android_Click_Arrange]
		where clicktime >= @Start
		and clicktime < @End
		and appkey is null
	end

	insert into [ODS_TD].[Tb_Android_Click_Arrange]
	select [Date],null,[Campaign Name],[Channel Name],[Android ID],'' oaid
	from [ODS_TD].[Tb_Android_AdditionalClick]
	where [Date] >= @Start
	and [Date] < @End

end

GO
