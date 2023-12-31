/****** Object:  StoredProcedure [DATA_OPS].[SP_App_Attr_Detail_Bak_220725]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_App_Attr_Detail_Bak_220725] AS
BEGIN

	TRUNCATE TABLE DATA_OPS.APP_Attr_Detail

	;with auto_ration as (
	select 
		year([Date]) as [Year],
		month([Date]) as [Month],
		[OS],
		[channel_name] as [Channel],
		sum([TotalClick]) as [Click],
		sum([TotalClickWithDeviceID]) as [ClickWithDevice],
		case when sum([TotalClickWithDeviceID]) <> 0 then cast(
				1 /(sum([TotalClickWithDeviceID]) * 1./ NULLIF(sum([TotalClick]), 0)
				) as decimal(10, 2)) else 1
		end as [Ratio],
		concat(year([Date]), month([Date]), [channel_name], [OS]) as [Index]
	from (
			SELECT [OS],
				[channel_name],
				[Date],
				[Source],
				[TotalClick],
				[TotalClickWithDeviceID]
			FROM [DW_TD].[Tb_Android_Click_RowComp]
			union ALL
			SELECT [OS],
				[channel_name],
				[Date],
				[Source],
				[TotalClick],
				[TotalClickWithDeviceID]
			FROM [DW_TD].[Tb_IOS_Click_RowComp]
		) a
	where [channel_name] <> N'幽�_�__'
	group by year([Date]),
		month([Date]),
		[OS],
		[channel_name]
	),

	ReportComp as (
	SELECT [Year]
		  ,[Month]
		  ,[Date]
		  ,[OS]
		  ,[Channel_CH]
		  ,[CampaignGroupName]
		  ,[Agency]
		  ,[Channel_EN]
		  ,[Media]
		  ,[CampaignName]
		  ,[MemberStatus]
		  ,[Paid Order]
		  ,[Paid Sales]
		  ,[Attribution Type]
		  ,[UV]
	  FROM [DW_TD].[Tb_PKG_ReportComp_New]
	where [Media] in ('huawei1', 'huaweiapp', 'miapp', 'oppoapp', 'qqapp', 'qqapp2', 'qqapp3', 'vivoapp')
	union all
	SELECT [Year]
		,[Month]
		,[Date]
		,[OS]
		,[Channel_CH]
		,[CampaignGroupName]
		,[Agency]
		,[Channel_EN]
		,[Media]
		,[CampaignName]
		,[MemberStatus]
		,[Paid Order]
		,[Paid Sales]
		,[Attribution Type]
		,[UV]
	FROM [DW_TD].[Tb_Android_ReportComp_New]
	union all
	SELECT [Year]
		,[Month]
		,[Date]
		,[OS]
		,[Channel_CH]
		,[CampaignGroupName]
		,[Agency]
		,[Channel_EN]
		,[Media]
		,[CampaignName]
		,[MemberStatus]
		,[Paid Order]
		,[Paid Sales]
		,[Attribution Type]
		,[UV]
	FROM [DW_TD].[Tb_IOS_ReportComp_New]
	)

	-- calculate paid sales and order with corelation

	INSERT INTO DATA_OPS.APP_Attr_Detail
	SELECT 
		   t.[Year]
		  ,t.[Month]
		  ,t.[Date]
		  ,t.[OS]
		  ,t.[Channel_CH]
		  ,concat(t.[Year], t.[Month], t.[Channel_CH], t.[OS]) as [Index]
		  ,t.[CampaignGroupName]
		  ,isnull(t.[Agency], 'NoGroup') as [Agency]
		  ,isnull(t.[Channel_EN], 'NoGroup') as [Channel_EN]
		  ,t.[Media]
		  ,t.[MemberStatus]
		  ,t.[CampaignName]
		  ,t.[Attribution Type]
		  ,0 as Corelation_UV
		  ,case when t.[Attribution Type] in ('TD Placed', 'TD Payment') then t.[Paid Order]
		  else t.[Paid Order] * isnull(b.[Ratio], 1)
		  end as [Corelation_Paid Order]
		  ,case when t.[Attribution Type] in ('TD Placed', 'TD Payment') then t.[Paid Sales]
		  else t.[Paid Sales] * isnull(b.[Ratio], 1)
		  end as [Corelation_Paid Sales]
		  ,isnull(b.[Ratio], 1) as Corelation
		  ,0 as [UV]
		  ,t.[Paid Order]
		  ,t.[Paid Sales]
		  ,t.[Paid Order] + t.[Paid Sales] AS Valid
	from ReportComp t
	left join auto_ration b
		  on concat(t.[Year], t.[Month], t.[Channel_CH], t.[OS]) = b.[Index]
	where --t.[Attribution Type] <> '90D Attribution' and
	t.[Paid Order]+t.[Paid Sales] <> 0

	union all 

	-- 1D non PKG UV with corelation

	SELECT 
		   t.[Year]
		  ,t.[Month]
		  ,t.[Date]
		  ,t.[OS]
		  ,t.[Channel_CH]
		  ,'' as [Index]
		  ,t.[CampaignGroupName]
		  ,isnull(t.[Agency], 'NoGroup') as [Agency]
		  ,isnull(t.[Channel_EN], 'NoGroup') as [Channel_EN]
		  ,t.[Media]
		  ,'' as [MemberStatus]
		  ,t.[CampaignName]
		  ,t.[Attribution Type]
		  ,sum(t.[UV]*isnull(b.[Ratio], 1))/count(1) as [Corelation_UV]
		  ,0 as [Corelation_Paid Order]
		  ,0 as [Corelation_Paid Sales]
		  ,0 as Corelation
		  ,sum(t.[UV])/count(1) as [UV]
		  ,0 as [Paid Order]
		  ,0 as [Paid Sales]
		  ,0 AS Valid
	from ReportComp t
	left join auto_ration b
		  on concat(t.[Year], t.[Month], t.[Channel_CH], t.[OS]) = b.[Index]
	where t.[Attribution Type] = '1D Attribution'
	and t.[Channel_CH] <> 'PKG'
	group by t.[Year]
		  ,t.[Month]
		  ,t.[Date]
		  ,t.[OS]
		  ,t.[Channel_CH]
		  ,t.[CampaignGroupName]
		  ,isnull(t.[Agency], 'NoGroup')
		  ,isnull(t.[Channel_EN], 'NoGroup')
		  ,t.[Media]
		  ,t.[CampaignName]
		  ,t.[Attribution Type]

	union all 

	-- 1D PKG UV with corelation

	SELECT 
		   t.[Year]
		  ,t.[Month]
		  ,t.[Date]
		  ,t.[OS]
		  ,t.[Channel_CH]
		  ,'' as [Index]
		  ,t.[CampaignGroupName]
		  ,isnull(t.[Agency], 'NoGroup') as [Agency]
		  ,isnull(t.[Channel_EN], 'NoGroup') as [Channel_EN]
		  ,t.[Media]
		  ,'' as [MemberStatus]
		  ,t.[CampaignName]
		  ,t.[Attribution Type]
		  ,sum(t.[UV]*isnull(b.[Ratio], 1))/1 as [Corelation_UV]
		  ,0 as [Corelation_Paid Order]
		  ,0 as [Corelation_Paid Sales]
		  ,0 as Corelation
		  ,sum(t.[UV])/1 as [UV]
		  ,0 as [Paid Order]
		  ,0 as [Paid Sales]
		  ,0 AS Valid
	from ReportComp t
	left join auto_ration b
		  on concat(t.[Year], t.[Month], t.[Channel_CH], t.[OS]) = b.[Index]
	where t.[Attribution Type] = '1D Attribution'
	and t.[Channel_CH] = 'PKG'
	group by t.[Year]
		  ,t.[Month]
		  ,t.[Date]
		  ,t.[OS]
		  ,t.[Channel_CH]
		  ,t.[CampaignGroupName]
		  ,isnull(t.[Agency], 'NoGroup')
		  ,isnull(t.[Channel_EN], 'NoGroup')
		  ,t.[Media]
		  ,t.[CampaignName]
		  ,t.[Attribution Type];
	
END;
GO
