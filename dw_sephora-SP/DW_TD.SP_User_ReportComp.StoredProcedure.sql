/****** Object:  StoredProcedure [DW_TD].[SP_User_ReportComp]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_TD].[SP_User_ReportComp] @StartDate [datetime] AS

delete from DW_TD.Tb_User_ReportComp
where [Date]  = @StartDate
 

 create table #comp(
	YEAR nvarchar(4),
MONTH nvarchar(2),
Date Date,
OS nvarchar(20),
ChannelName nvarchar(500) ,
CampaignGroupName nvarchar(500) , 
MemberStatus nvarchar(20),
PaidSales numeric(16,2),
PaidOrder int,
UV int,
AttributionType  nvarchar(20) ,
UserCount int
)


insert into #comp
select aa.[YEAR],aa.[MONTH],aa.[Date], aa.OS, aa.Channel_CH, aa.CampaignGroupName, aa.MemberStatus,aa.PaidSales,aa.PaidOrder,aa.UV,aa.AttributionType,bb.UserCount
from 
(
SELECT [YEAR],[MONTH],[Date], OS, Channel_CH, CampaignGroupName, MemberStatus,sum([Paid Sales]) PaidSales,sum([Paid ORDER]) PaidOrder,sum(UV) UV,[Attribution Type]  AttributionType
FROM
	DW_TD.Tb_Android_ReportComp_New 
WHERE
	[Date]= @StartDate 
	AND [Attribution Type] IN ( '1D Attribution', 'TD Payment' )
	GROUP BY
	[YEAR],[MONTH],[Date], OS, Channel_CH, CampaignGroupName, MemberStatus,[Attribution Type] )aa 
	left join 
	(
SELECT 
 ActiveDate,
	  OS,
	ChannelName,
	 CampaignGroupName,
	 MemberStatus,
	SUM(UserCount) UserCount
from DW_TD.Tb_Fact_Android_User_Report  
GROUP BY
 ActiveDate,
	  OS,
	ChannelName,
	 CampaignGroupName,
	 MemberStatus ) bb
	 on  aa.[Date]=bb.ActiveDate
 and aa.OS=bb.OS
  and isnull(aa.Channel_CH,'')=isnull(bb.ChannelName,'')
and aa.CampaignGroupName=bb.CampaignGroupName
and isnull(aa.MemberStatus,'')=isnull(bb.MemberStatus,'')
UNION all
select aa.[YEAR],aa.[MONTH],aa.[Date], aa.OS, aa.Channel_CH, aa.CampaignGroupName, aa.MemberStatus,aa.PaidSales,aa.PaidOrder,aa.UV,aa.AttributionType,bb.UserCount
from 
(
SELECT [YEAR],[MONTH],[Date], OS, Channel_CH, CampaignGroupName, MemberStatus,sum([Paid Sales]) PaidSales,sum([Paid ORDER]) PaidOrder,sum(UV) UV,[Attribution Type]  AttributionType
FROM
	DW_TD.Tb_IOS_ReportComp_New 
WHERE
	[Date]= @StartDate
	AND [Attribution Type] IN ( '1D Attribution', 'TD Payment' )
	GROUP BY
	[YEAR],[MONTH],[Date], OS, Channel_CH, CampaignGroupName, MemberStatus,[Attribution Type] )aa 
	left join 
	(
SELECT 
 ActiveDate,
	  OS,
	ChannelName,
	 CampaignGroupName,
	 MemberStatus,
	SUM(UserCount) UserCount
from DW_TD.Tb_Fact_IOS_User_Report 
WHERE 
ActiveDate= @StartDate 
GROUP BY
 ActiveDate,
	  OS,
	ChannelName,
	 CampaignGroupName,
	 MemberStatus ) bb
	 on  aa.[Date]=bb.ActiveDate
 and aa.OS=bb.OS
  and isnull(aa.Channel_CH,'')=isnull(bb.ChannelName,'')
and aa.CampaignGroupName=bb.CampaignGroupName
and isnull(aa.MemberStatus,'')=isnull(bb.MemberStatus,'')


insert into DW_TD.Tb_User_ReportComp
SELECT
	aa.[Date],
	aa.ChannelName,
	aa.CampaignGroupName,
	aa.AttributionType ,
  sum(aa.[RETURN]) 'RETURN',
 sum(aa.[BRAND_NEW]) 'BRAND_NEW',
 sum(aa.[CONVERT_NEW]) 'CONVERT_NEW'
	  
FROM(

SELECT
	[Date],
	ChannelName,
	CampaignGroupName,
CASE
	
	WHEN MemberStatus = 'RETURN' THEN
	UserCount 
	END AS 'RETURN',
CASE
		
		WHEN MemberStatus = 'BRAND_NEW' THEN
		UserCount 
	END AS 'BRAND_NEW',
CASE
		
		WHEN MemberStatus = 'CONVERT_NEW' THEN
		UserCount 
	END AS 'CONVERT_NEW',
	AttributionType,
	UserCount 
FROM
#comp)aa   
GROUP BY 
[Date],
	ChannelName,
	CampaignGroupName,
	AttributionType 
	 

drop table #comp
GO
