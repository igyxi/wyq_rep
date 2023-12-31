/****** Object:  StoredProcedure [TEST].[SP_V_PC_MNP_Attr_Detail]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_V_PC_MNP_Attr_Detail] AS
BEGIN
	TRUNCATE TABLE [TEST].[PC_MNP_Attr_Detail]

	INSERT INTO [TEST].[PC_MNP_Attr_Detail]
	SELECT *
	FROM (
        SELECT
            [Month],
            [statics_date],
            '' AS [member_new_status],
            [platform_type],
            [attribution_type],
            [ss_utm_source],
            [ss_utm_medium],
			[ss_utm_content],
            0 AS [payed_amount],
            0 AS [payed_order],
            [uv],
            [Channel],
            [ss_utm_term] AS [Audience]-----添加字段
        FROM (
            SELECT
                [Month],
                [statics_date],
                [platform_type],
                [attribution_type],
                [ss_utm_source],
                [ss_utm_medium],
				[ss_utm_content],
                [Channel],
                sum(uv)/count(1) AS uv,
                [ss_utm_term] -----添加字段
            FROM (
                SELECT
                    concat(month(attr.[statics_date]), '-', year(attr.[statics_date])) AS [Month],
                    attr.[statics_date],
                    attr.[member_new_status],
                    attr.[platform_type],
                    attr.[attribution_type],
                    upper(attr.[ss_utm_source]) AS [ss_utm_source],
                    upper(attr.[ss_utm_medium]) AS [ss_utm_medium],
					upper(attr.[ss_utm_content]) AS [ss_utm_content],
                    CASE 
                        WHEN mnp_medium.Channel IS NOT NULL THEN mnp_medium.Channel
                        WHEN mnp_source.Channel IS NOT NULL THEN mnp_source.Channel
                        WHEN pc_mob.mapped_medium IS NOT NULL THEN pc_mob.mapped_medium
                        ELSE pc_web.mapped_medium
                    END AS [Channel],
                    attr.[payed_amount],
                    attr.[payed_order],
                    ISNULL(attr.[uv], 0) AS uv,
                     UPPER(
					case 
						when audience.[audience] is null then 'non' else audience.[audience]
					end 
					) AS [ss_utm_term]  ----------添加字段
                FROM [TEST].[RPT_Sensor_Order_Attribution] AS attr
                LEFT JOIN DATA_OPS.PC_Attr_MNP_Source_Mapping AS mnp_source ON attr.platform_type = mnp_source.Platform_Type AND attr.ss_utm_source = mnp_source.Source_new
                LEFT JOIN DATA_OPS.PC_Attr_MNP_Medium_Mapping AS mnp_medium ON attr.platform_type = mnp_medium.Platform_Type AND attr.ss_utm_medium = mnp_medium.Medium_new
                LEFT JOIN DATA_OPS.PC_Attr_PC_H5_Mapping_Mobile AS pc_mob ON attr.platform_type = pc_mob.platform AND attr.ss_utm_medium = pc_mob.medium_new
                LEFT JOIN DATA_OPS.PC_Attr_PC_H5_Mapping_Web AS pc_web ON attr.platform_type = pc_web.platform AND attr.ss_utm_medium = pc_web.medium_new
				LEFT JOIN [DATA_OPS].[PC_Attr_MNP_Audience_Mapping] AS audience ON attr.platform_type=audience.channel and concat_ws('-',attr.[ss_utm_medium], attr.[ss_utm_term])=audience.[utm_medium]
                WHERE attr.[attribution_type] = '1D'
                    AND attr.[uv] IS NOT NULL
            ) t
            GROUP BY
                [Month],
                [statics_date],
                [platform_type],
                [attribution_type],
                [ss_utm_source],
                [ss_utm_medium],
				[ss_utm_content],
                [ss_utm_term],
                [Channel]
            HAVING sum(uv)/count(1) <> 0
        ) tt
        UNION ALL
        SELECT
            concat(month(attr.[statics_date]), '-', year(attr.[statics_date])) as [Month],
            attr.[statics_date],
            attr.[member_new_status],
            attr.[platform_type],
            attr.[attribution_type],
            upper(attr.[ss_utm_source]) as [ss_utm_source],
            upper(attr.[ss_utm_medium]) as [ss_utm_medium],
			upper(attr.[ss_utm_content]) AS [ss_utm_content],
            isnull(attr.[payed_amount], 0) as [payed_amount],
            isnull(attr.[payed_order], 0) as [payed_order],
            0 as [uv],
            case 
                when mnp_medium.Channel is not null then mnp_medium.Channel
                when mnp_source.Channel is not null then mnp_source.Channel
                when pc_mob.mapped_medium is not null then pc_mob.mapped_medium
                else pc_web.mapped_medium
            end as [Channel],
             UPPER(
					case 
						when audience.[audience] is null then 'non' else audience.[audience]
					end 
					) AS [ss_utm_term]   -----添加字段
        FROM [TEST].[RPT_Sensor_Order_Attribution] attr
        LEFT JOIN DATA_OPS.PC_Attr_MNP_Source_Mapping mnp_source on attr.platform_type = mnp_source.Platform_Type and attr.ss_utm_source = mnp_source.Source_new
        LEFT JOIN DATA_OPS.PC_Attr_MNP_Medium_Mapping mnp_medium on attr.platform_type = mnp_medium.Platform_Type and attr.ss_utm_medium = mnp_medium.Medium_new
        LEFT JOIN DATA_OPS.PC_Attr_PC_H5_Mapping_Mobile pc_mob on attr.platform_type = pc_mob.platform and attr.ss_utm_medium = pc_mob.medium_new
        LEFT JOIN DATA_OPS.PC_Attr_PC_H5_Mapping_Web pc_web on attr.platform_type = pc_web.platform and attr.ss_utm_medium = pc_web.medium_new
		LEFT JOIN [DATA_OPS].[PC_Attr_MNP_Audience_Mapping] AS audience ON attr.platform_type=audience.channel and concat_ws('-',attr.[ss_utm_medium], attr.[ss_utm_term])=audience.[utm_medium]
	) ttt
	WHERE [uv]+[payed_amount]+[payed_order] <> 0
	
END;
GO
