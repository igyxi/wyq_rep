/****** Object:  StoredProcedure [DATA_OPS].[SP_V_PC_MNP_Attr_Detail_Bak_220725]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_V_PC_MNP_Attr_Detail_Bak_220725] AS
BEGIN
	TRUNCATE TABLE [DATA_OPS].[PC_MNP_Attr_Detail]

	INSERT INTO [DATA_OPS].[PC_MNP_Attr_Detail]
	select *
	from (
	SELECT
		[Month],
		[statics_date],
		'' as [member_new_status],
		[platform_type],
		[attribution_type],
		[ss_utm_source],
		[ss_utm_medium],
		0 as [payed_amount],
		0 as [payed_order],
		[uv],
		[Channel]
	from (
	select
		[Month],
		[statics_date],
		[platform_type],
		[attribution_type],
		[ss_utm_source],
		[ss_utm_medium],
		[Channel],
		sum(uv)/count(1) as uv
	from (
	SELECT
		concat(month(attr.[statics_date]), '-', year(attr.[statics_date])) as [Month],
		attr.[statics_date],
		attr.[member_new_status],
		attr.[platform_type],
		attr.[attribution_type],
		upper(attr.[ss_utm_source]) as [ss_utm_source],
		upper(attr.[ss_utm_medium]) as [ss_utm_medium],
		case 
			when mnp_medium.Channel is not null then mnp_medium.Channel
			when mnp_source.Channel is not null then mnp_source.Channel
			when pc_mob.mapped_medium is not null then pc_mob.mapped_medium
			else pc_web.mapped_medium
		end as [Channel],
		attr.[payed_amount],
		attr.[payed_order],
		isnull(attr.[uv], 0) as uv
	FROM [DW_Sensor].[RPT_Sensor_Order_Attribution] attr
	LEFT JOIN DATA_OPS.PC_Attr_MNP_Source_Mapping mnp_source
		on attr.platform_type = mnp_source.Platform_Type
		and attr.ss_utm_source = mnp_source.Source_new
	LEFT JOIN DATA_OPS.PC_Attr_MNP_Medium_Mapping mnp_medium
		on attr.platform_type = mnp_medium.Platform_Type
		and attr.ss_utm_medium = mnp_medium.Medium_new
	LEFT JOIN DATA_OPS.PC_Attr_PC_H5_Mapping_Mobile pc_mob
		on attr.platform_type = pc_mob.platform
		and attr.ss_utm_medium = pc_mob.medium_new
	LEFT JOIN DATA_OPS.PC_Attr_PC_H5_Mapping_Web pc_web
		on attr.platform_type = pc_web.platform
		and attr.ss_utm_medium = pc_web.medium_new
	where attr.[attribution_type] = '1D'
	and attr.[uv] is not null
	) t
	group by 
		[Month],
		[statics_date],
		[platform_type],
		[attribution_type],
		[ss_utm_source],
		[ss_utm_medium],
		[Channel]
	having sum(uv)/count(1) <> 0
	) tt
	union all
	SELECT
		concat(month(attr.[statics_date]), '-', year(attr.[statics_date])) as [Month],
		attr.[statics_date],
		attr.[member_new_status],
		attr.[platform_type],
		attr.[attribution_type],
		upper(attr.[ss_utm_source]) as [ss_utm_source],
		upper(attr.[ss_utm_medium]) as [ss_utm_medium],
		isnull(attr.[payed_amount], 0) as [payed_amount],
		isnull(attr.[payed_order], 0) as [payed_order],
		0 as [uv],
		case 
			when mnp_medium.Channel is not null then mnp_medium.Channel
			when mnp_source.Channel is not null then mnp_source.Channel
			when pc_mob.mapped_medium is not null then pc_mob.mapped_medium
			else pc_web.mapped_medium
		end as [Channel]
	FROM [DW_Sensor].[RPT_Sensor_Order_Attribution] attr
	LEFT JOIN DATA_OPS.PC_Attr_MNP_Source_Mapping mnp_source
		on attr.platform_type = mnp_source.Platform_Type
		and attr.ss_utm_source = mnp_source.Source_new
	LEFT JOIN DATA_OPS.PC_Attr_MNP_Medium_Mapping mnp_medium
		on attr.platform_type = mnp_medium.Platform_Type
		and attr.ss_utm_medium = mnp_medium.Medium_new
	LEFT JOIN DATA_OPS.PC_Attr_PC_H5_Mapping_Mobile pc_mob
		on attr.platform_type = pc_mob.platform
		and attr.ss_utm_medium = pc_mob.medium_new
	LEFT JOIN DATA_OPS.PC_Attr_PC_H5_Mapping_Web pc_web
		on attr.platform_type = pc_web.platform
		and attr.ss_utm_medium = pc_web.medium_new
	) ttt
	where [uv]+[payed_amount]+[payed_order] <> 0;
	
END;
GO
