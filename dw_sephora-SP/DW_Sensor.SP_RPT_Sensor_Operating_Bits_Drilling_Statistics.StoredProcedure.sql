/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_Operating_Bits_Drilling_Statistics]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_Operating_Bits_Drilling_Statistics] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.RPT_Sensor_Operating_Bits_Drilling_Statistics where [date] = @dt;
insert into DW_Sensor.RPT_Sensor_Operating_Bits_Drilling_Statistics
select 
	a.date,
	a.banner_belong_area,
	a.area_uv,
	a.area_pv,
	b.banner_ranking,
	b.banner_uv,
	b.banner_pv,
	c.campaign_code,
	c.campaign_uv,
	c.campaign_pv,
	current_timestamp as insert_timestamp
from 
(
	select 
		a.date,
		a.banner_belong_area,
		count(DISTINCT a.user_id) as area_uv,
		count(1) as area_pv
	from 
		STG_Sensor.Events a
	where a.platform_type in ('app','App')
	--and banner_belong_area= 'Select_Hero'
	and a.event = 'clickBanner_App_Mob'
	and a.date = @dt
	AND a.banner_belong_area IS NOT NULL
	group by a.date,a.banner_belong_area
) a
left join 
(
	select 
		date,
		banner_belong_area,
		banner_ranking,
		count(DISTINCT user_id) as banner_uv,
		count(1) as banner_pv
	from 
		STG_Sensor.Events
	where platform_type in ('app','App')
	--and banner_belong_area= 'Select_Hero'
	and event = 'clickBanner_App_Mob'
	and date = @dt
	AND banner_belong_area IS NOT NULL
	group by date,banner_belong_area,banner_ranking
) b
on b.banner_belong_area = a.banner_belong_area
and b.date = a.date
left join 
(
	select 
		date,
		banner_belong_area,
		banner_ranking,
		campaign_code,
		count(DISTINCT user_id) as campaign_uv,
		count(1) as campaign_pv
	from 
		STG_Sensor.Events
	where platform_type in ('app','App')
	--and banner_belong_area= 'Select_Hero'
	and event = 'clickBanner_App_Mob'
	and date = @dt
	AND banner_belong_area IS NOT NULL
	group by date,banner_belong_area,banner_ranking,campaign_code
) c
on c.banner_ranking = b.banner_ranking
and c.banner_belong_area = b.banner_belong_area
and c.date = b.date
--order by a.date,a.banner_belong_area,b.banner_ranking,c.campaign_code
;
end
GO
