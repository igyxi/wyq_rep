/****** Object:  StoredProcedure [TEST].[SP_RPT_Sensor_Post_Week_Statistics_test]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_Sensor_Post_Week_Statistics_test] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By      version     Requestor        Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-08       houshuangqiang  init        Faina, Liu       帖子统计周报表(调度时间：周一跑上周的数据)
-- ========================================================================================
declare @week_start date
declare @week_end date
set @week_start = (select format(dateadd(week, datediff(week, 0, convert(datetime, @dt, 120) - 1), 0), 'yyyy-MM-dd'));
set @week_end = (select dateadd(day, 6, @week_start))
--select @week_start
--select @week_end


-- delete from RPT.RPT_Sensor_Post_Week_Statistics
-- where dt between @week_start and @week_end
insert 	into test.RPT_Sensor_Post_Week_Statistics_test
select 	statistics_start_date
        ,statistics_end_date
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
     select @week_start as statistics_start_date
            ,@week_end as statistics_end_date
			,post_id
			,0 as pv
			,0 as uv
			,sum(case when behavior_cn = N'点赞' then 1 else 0 end) as like_qty
			,sum(case when behavior_cn = N'评论' then 1 else 0 end) as comment_qty
			,sum(case when behavior_cn = N'收藏' then 1 else 0 end) as collect_qty
			,sum(case when behavior_cn = N'分享' then 1 else 0 end) as share_qty
	from 	DWD.Fact_BeautyIn_Behavior
	where 	format(behavior_time, 'yyyy-MM-dd') between @week_start and @week_end
	group 	by post_id
	union 	all
     select @week_start as statistics_start_date
            ,@week_end as statistics_end_date
			,beauty_article_id COLLATE Chinese_PRC_CS_AI_WS as post_id
			,count(1) as pv
			,count(distinct user_id) as uv
			,0 as like_qty
			,0 as comment_qty
			,0 as collect_qty
			,0 as share_qty
	from 	STG_Sensor.Events
	where 	dt between @week_start and @week_end
	and 	page_id in ('APP_1000503', 'MP_1000503', 'MB_1000503')
	and 	event in ('$AppViewScreen','$MPViewScreen','$pageview')
	and 	beauty_article_id is not null
	group 	by beauty_article_id
) p
group 	by p.statistics_start_date,p.statistics_end_date,p.post_id
END
GO
