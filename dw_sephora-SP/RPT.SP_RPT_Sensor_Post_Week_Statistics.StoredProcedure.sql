/****** Object:  StoredProcedure [RPT].[SP_RPT_Sensor_Post_Week_Statistics]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sensor_Post_Week_Statistics] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By      version     Requestor        Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-08       houshuangqiang  init        Faina, Liu       帖子统计周报表(调度时间：周一跑上周的数据)
-- 2023-03-15       wangzhichun              add column
-- ========================================================================================
declare @week_start date
declare @week_end date
set @week_start = (select format(dateadd(week, datediff(week, 0, convert(datetime, @dt, 120) - 1), 0), 'yyyy-MM-dd'));
set @week_end = (select dateadd(day, 6, @week_start))
--select @week_start
--select @week_end


delete from RPT.RPT_Sensor_Post_Week_Statistics
where dt between @week_start and @week_end
insert 	into RPT.RPT_Sensor_Post_Week_Statistics
select  
    statistics_start_date,
    statistics_end_date,
    post_id,
    pv,
    uv,
    click_pv,
    click_uv,
    case when ctr='%' then null else ctr end as ctr,
    case when uv_ctr='%' then null else uv_ctr end as uv_ctr,
    like_qty,
    comment_qty,
    collect_qty,
    share_qty,
    dt,
    current_timestamp as insert_timestamp
from 
(
    select 	statistics_start_date
            ,statistics_end_date
            ,post_id
            ,sum(pv) as pv
            ,sum(uv) as uv
            ,sum(click_pv) as click_pv
            ,sum(click_uv) as click_uv
            ,concat(cast(convert(decimal(18,1),(sum(click_pv)*100/(nullif(sum(pv),0)+0.0))) as nvarchar(512)),'%') as ctr
            ,concat(cast(convert(decimal(18,1),(sum(click_uv)*100/(nullif(sum(uv),0)+0.0))) as nvarchar(512)),'%') as uv_ctr
            ,sum(like_qty) as like_qty
            ,sum(comment_qty) as comment_qty
            ,sum(collect_qty) as collect_qty
            ,sum(share_qty) as share_qty
            ,@dt as dt
    from
    (
        select @week_start as statistics_start_date
                ,@week_end as statistics_end_date
                ,post_id
                ,0 as pv
                ,0 as uv
                ,0 as click_pv
                ,0 as click_uv
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
                ,beauty_article_id COLLATE Chinese_PRC_CS_AI_WS
                ,count(case when event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as pv       
                ,count(distinct case when event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) uv
                ,count(case when event ='beautyIN_blog_commodity_click' and  action_id = '1000503_965' then user_id end ) as click_pv
                ,count(distinct case when event ='beautyIN_blog_commodity_click' and  action_id = '1000503_965' then user_id end ) as click_uv
                ,0 as like_qty
                ,0 as comment_qty
                ,0 as collect_qty
                ,0 as share_qty
        from 	STG_Sensor.Events
        where 	dt between @week_start and @week_end
        and 	page_id in ('APP_1000503', 'MP_1000503', 'MB_1000503')
        and 	(event in ('$AppViewScreen','$MPViewScreen','$pageview')
                or (event ='beautyIN_blog_commodity_click' and  action_id = '1000503_965'))  --因新增click_pv数据，增加or条件。
        and 	beauty_article_id is not null
        group 	by beauty_article_id
    ) p
    group 	by p.statistics_start_date,p.statistics_end_date,p.post_id
) total
where total.pv<>0           --过滤掉点击但没有浏览、点赞帖子的脏数据
or total.like_qty<>0 or total.comment_qty<>0 or total.collect_qty<>0 or total.share_qty<>0   --保证DWD.Fact_BeautyIn_Behavior中post_id不被过滤
END
GO
