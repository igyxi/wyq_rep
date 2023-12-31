/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sensor_Post_Statistics_Bak_20230315]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sensor_Post_Statistics_Bak_20230315] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-08       houshuangqiang           Initial Version
-- ========================================================================================
delete from RPT.RPT_Sensor_Post_Statistics where statistics_date = @dt
insert 	into RPT.RPT_Sensor_Post_Statistics
select 	statistics_date
		,post_id
		,sum(pv) as pv
		,sum(uv) as uv
		,sum(like_qty) as like_qty
		,sum(comment_qty) as comment_qty
		,sum(collect_qty) as collect_qty
		,sum(share_qty) as share_qty
		,@dt as dt
		,current_timestamp as insert_timestamp
from
(
	select 	format(behavior_time, 'yyyy-MM-dd') as statistics_date
			,post_id
			,0 as pv
			,0 as uv
			,sum(case when behavior_cn = N'点赞' then 1 else 0 end) as like_qty
			,sum(case when behavior_cn = N'评论' then 1 else 0 end) as comment_qty
			,sum(case when behavior_cn = N'收藏' then 1 else 0 end) as collect_qty
			,sum(case when behavior_cn = N'分享' then 1 else 0 end) as share_qty
	from 	DWD.Fact_BeautyIn_Behavior
	where 	format(behavior_time, 'yyyy-MM-dd') = @dt
	group 	by format(behavior_time, 'yyyy-MM-dd'),post_id
	union 	all
	select   format(date, 'yyyy-MM-dd') as statistics_date
			,beauty_article_id COLLATE Chinese_PRC_CS_AI_WS as post_id
			,count(1) as pv
			,count(distinct user_id) as uv
			,0 as like_qty
			,0 as comment_qty
			,0 as collect_qty
			,0 as share_qty
	from 	STG_Sensor.Events
	where 	dt = @dt
	and 	page_id in ('APP_1000503', 'MP_1000503', 'MB_1000503')
	and 	event in ('$AppViewScreen','$MPViewScreen','$pageview')
	and 	beauty_article_id is not null
	group 	by format(date, 'yyyy-MM-dd'),beauty_article_id
) p
group 	by p.statistics_date,p.post_id
END
GO
