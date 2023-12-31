/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_PDP_Pre_Page]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_PDP_Pre_Page] @dt [VARCHAR](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-14       wangzhichun        Initial Version
-- ========================================================================================
delete from [DW_Sensor].[RPT_Sensor_PDP_Pre_Page] where left(date,7) = left(@dt,7)
Insert into [DW_Sensor].[RPT_Sensor_PDP_Pre_Page]
SELECT 
	date as DATE,
	case when upper(a.platform_type) = 'MINIPROGRAM' then 'MNP'
        else upper(a.platform_Type)
        end as PLATFORM_TYPE,
	event,
	op_code,
	pre_page,
	isnull(c.description, '') as description,
	CASE WHEN isnull(a.pre_page, '') <> ''
		THEN isnull(c.page_type, 'Campaign')
		ELSE ''END as page_type,
	count(1) AS PV,
	count(DISTINCT user_id) AS UV,
    current_timestamp as insert_timestamp
FROM 
(
	 SELECT 
		DATE,
		platform_type,
		system_type,
		event,
		op_code,
		user_id,
		ROW_NUM,
		CASE WHEN len( pageid_wo_prefix) >= 5 THEN pageid_wo_prefix COLLATE SQL_Latin1_General_CP1_CI_AS
			WHEN PATINDEX('%[0-9]%', H5_page_id) > PATINDEX('%[^0-9]%', H5_page_id) THEN H5_page_id
			ELSE '' END page_id,
		lag (CASE WHEN len( pageid_wo_prefix) >= 5 THEN pageid_wo_prefix COLLATE SQL_Latin1_General_CP1_CI_AS
				WHEN PATINDEX('%[0-9]%', H5_page_id) > PATINDEX('%[^0-9]%', H5_page_id)
				THEN H5_page_id ELSE '' END ,1)
             OVER (PARTITION BY date,platform_type,--system_type,
			 user_id ORDER BY time) AS pre_page,
		lag(op_code, 1) OVER ( PARTITION BY date, platform_type,--system_type,
		user_id ORDER BY time) AS pre_sku
	from 
	(
	select * FROM [DW_Sensor].[DWS_Events_Session_Cutby30m]
		WHERE left(date,7)= left(@dt,7) 
 and event in ('$MPViewScreen','$pageview','$AppViewScreen','viewCommodityDetail')
	and not (event in ('$MPViewScreen','$AppViewScreen') and isnull(pageid_wo_prefix,'') in ('', '1000401'))
	--and distinct_id ='2030340054'
	 --order by date, platform_type,system_type,user_id ,ROW_NUM
	) temp
) a
left join
    [DW_Sensor].[V_Sensor_PageType_Categorization] c 
ON isnull(a.pre_page, '') = isnull(c.page_id, '')
WHERE event = 'viewCommodityDetail' --AND isnull(op_code,'') <> isnull(pre_sku,'')
GROUP BY 
    date,
	case when upper(a.platform_type) = 'MINIPROGRAM' then 'MNP'
      else upper(a.platform_Type)
        end,
	event,
	op_code,
	pre_page,
	isnull(c.description, ''), 
	CASE WHEN isnull(a.pre_page, '') <> '' THEN isnull(c.page_type, 'Campaign') ELSE '' END
End
GO
