/****** Object:  StoredProcedure [RPT].[SP_RPT_Sensor_Post_Month_Statistics_New]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sensor_Post_Month_Statistics_New] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By      version     Requestor        Description
-- ----------------------------------------------------------------------------------------
-- 2023-02-08       houshuangqiang  init        Faina, Liu       帖子统计月报表
-- ========================================================================================
delete from RPT.RPT_Sensor_Post_Month_Statistics_New where format(dt, 'yyyy-MM') = format(@dt, 'yyyy-MM')
insert 	into RPT.RPT_Sensor_Post_Month_Statistics_New
select  
    *
from 
(
    select 	statistics_month
            ,post_id
            ,sum(pv) as pv
            ,sum(uv) as uv
            ,sum(click_pv) as click_pv
            ,sum(click_uv) as click_uv
            ,round(sum(click_pv)/(nullif(sum(pv),0)+0.0),2) as ctr
            ,round(sum(click_uv)/(nullif(sum(uv),0)+0.0),2) as uv_ctr
            ,sum(like_qty) as like_qty
            ,sum(comment_qty) as comment_qty
            ,sum(collect_qty) as collect_qty
            ,sum(share_qty) as share_qty
            ,@dt as dt
            ,current_timestamp as insert_timestamp
    from
    (
        select 	format(behavior_time, 'yyyy-MM') as statistics_month
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
        where 	format(behavior_time, 'yyyy-MM') = format(@dt, 'yyyy-MM')
        group 	by format(behavior_time, 'yyyy-MM'),post_id
        union 	all
        select   format(date, 'yyyy-MM') as statistics_month
                ,beauty_article_id COLLATE Chinese_PRC_CS_AI_WS as post_id
                ,count(case when event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as pv       
                ,count(distinct case when event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) uv
                ,count(case when event ='beautyIN_blog_commodity_click' and  action_id = '1000503_965' then user_id end ) as click_pv
                ,count(distinct case when event ='beautyIN_blog_commodity_click' and  action_id = '1000503_965' then user_id end ) as click_uv
                ,0 as like_qty
                ,0 as comment_qty
                ,0 as collect_qty
                ,0 as share_qty
        from 	STG_Sensor.Events
    --	where 	format(dt, 'yyyy-MM') = format(@dt, 'yyyy-MM')
        where   left(dt, 7) = format(@dt, 'yyyy-MM')
        and 	page_id in ('APP_1000503', 'MP_1000503', 'MB_1000503')
        and 	(event in ('$AppViewScreen','$MPViewScreen','$pageview')
                or (event ='beautyIN_blog_commodity_click' and  action_id = '1000503_965'))  --因新增click_pv数据，增加or条件。
        and 	beauty_article_id is not null
        group 	by format(date, 'yyyy-MM'),beauty_article_id
    ) p
    group 	by p.statistics_month,p.post_id
) total
where total.pv<>0           --过滤掉点击但没有浏览、点赞帖子的脏数据
or total.like_qty<>0 or total.comment_qty<>0 or total.collect_qty<>0 or total.share_qty<>0   --保证DWD.Fact_BeautyIn_Behavior中post_id不被过滤
END
GO
