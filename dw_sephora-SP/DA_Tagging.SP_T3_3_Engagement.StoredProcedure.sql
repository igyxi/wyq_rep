/****** Object:  StoredProcedure [DA_Tagging].[SP_T3_3_Engagement]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T3_3_Engagement] AS
BEGIN
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','engagement start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, id_mapping insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

truncate table [DW_Sephora].[DA_Tagging].engagement
-- go

insert into [DW_Sephora].[DA_Tagging].engagement(master_id,sensor_id)
select master_id,sensor_id
from [DW_Sephora].[DA_Tagging].id_mapping
where sensor_id<>0 and invalid_date='9999-12-31'
-- go

/* ############ ############ ############ Engagement Weekly Update Tag ############ ############ ############ */

DECLARE @WeekNum VARCHAR(50)= datename(weekday, DATEADD(hour,8,getdate()))
if @WeekNum='Saturday'  -- Sunday
begin 
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_3','Engagement, hour_preference update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		-- go

		;with hour_preference_temp as (
			select sensor_id,hour_name as hour_preference
			from (
				select sensor_id,hour_name,row_number() over(partition by sensor_id order by hour_name_cnt desc) rn
				from (
						select user_id as sensor_id
							  ,case datename(hour,time) when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
											when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
											when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
											when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
											when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' end as hour_name
							  ,count(distinct dt) as hour_name_cnt
						--from [DW_Sephora].[DA_Tagging].v_events_session
						from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
						where event in ('$AppViewScreen','$MPViewScreen','$pageview')
							  and dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
						group by user_id,case datename(hour,time) when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
											when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
											when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
											when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
											when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' end
				) as t1
			) as t2
			where rn = 1
		)

		update DA_Tagging.tagging_weekly
		set hour_preference = tt2.hour_preference
		from DA_Tagging.tagging_weekly as tt1
		join hour_preference_temp as tt2
		on tt1.sensor_id = tt2.sensor_id
		-- go

		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_3','Engagement, weekday_preference update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		-- go

		;with weekday_preference_temp as (
			select sensor_id,week_name as weekday_preference
			from (
				select sensor_id,week_name,row_number() over(partition by sensor_id order by week_name_cnt desc) rn
				from (
						select user_id as sensor_id,datename(weekday,[time]) as week_name,count(distinct dt) as week_name_cnt
						--from [DW_Sephora].[DA_Tagging].v_events_session
						from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
						where event in ('$AppViewScreen','$MPViewScreen','$pageview')
							  and dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
						group by user_id,datename(weekday,[time])
				) as t1
			) as t2
			where rn = 1
		)

		update DA_Tagging.tagging_weekly
		set weekday_preference = tt2.weekday_preference
		from DA_Tagging.tagging_weekly as tt1
		join weekday_preference_temp as tt2
		on tt1.sensor_id = tt2.sensor_id

		
		-- 15min
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_3','Engagement, most_visited_channel generate Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())


		IF OBJECT_ID(N'tempdb..#most_visited_channel', N'U') IS NOT NULL 
		DROP TABLE #most_visited_channel

		CREATE TABLE #most_visited_channel(
			user_id bigint,
			most_visited_channel nvarchar(4000) collate Chinese_PRC_CS_AI_WS
		)

		insert into #most_visited_channel
		select user_id,platform_type as most_visited_channel
		from(
			select user_id,platform_type,row_number() over(partition by user_id order by cnt desc) rn
			from (
				select user_id ,platform_type,count(distinct dt) as cnt
				from DW_Sephora.[STG_Sensor].[V_Events]-- with(nolock)
				where dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
				group by user_id,platform_type
			) as a
		)t2
		where rn=1

		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_3','Engagement, most_visited_channel update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())


		update [DW_Sephora].[DA_Tagging].tagging_weekly
		set most_visited_channel = tt2.most_visited_channel
		from [DW_Sephora].[DA_Tagging].tagging_weekly as tt1
		join #most_visited_channel as tt2
		on tt1.sensor_id = tt2.user_id


end

/* ############ ############ ############ Engagement Daliy Update Tag ############ ############ ############ */
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, Weekly Update Tag Update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

IF OBJECT_ID('tempdb..#weekly_engagement','U')  IS NOT NULL
drop table #weekly_engagement;
create table #weekly_engagement(
	master_id bigint ,
	hour_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	weekday_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	most_visited_channel nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #weekly_engagement(master_id,hour_preference,weekday_preference,most_visited_channel)
select master_id,hour_preference,weekday_preference,most_visited_channel
from DA_Tagging.tagging_weekly 
where sensor_id is not null
and (hour_preference is not null 
or weekday_preference is not null
or most_visited_channel is not null)


update [DW_Sephora].[DA_Tagging].engagement
set hour_preference = tt2.hour_preference
	,weekday_preference = tt2.weekday_preference
	,most_visited_channel = tt2.most_visited_channel
from [DW_Sephora].[DA_Tagging].engagement as tt1
join #weekly_engagement as tt2
on tt1.master_id = tt2.master_id


--IF OBJECT_ID(N'tempdb..#most_visited_channel', N'U') IS NOT NULL 
--DROP TABLE #most_visited_channel
---- go

--CREATE TABLE #most_visited_channel(
--	sensor_id bigint,
--    platform_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
--	platform_cnt int
--)
--go

--insert into #most_visited_channel
--select sensor_id,platform_type,count(*)
--from (
--	select user_id as sensor_id,platform_type,dt
--	from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
--	where dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
--	group by user_id,platform_type,dt
--) as a
--group by sensor_id,platform_type
--go


--update [DW_Sephora].[DA_Tagging].engagement
--set most_visited_channel = tt2.most_visited_channel
--from [DW_Sephora].[DA_Tagging].engagement as tt1
--join (
--    select sensor_id,platform_type as most_visited_channel
--    from(
--        select sensor_id,platform_type,row_number() over(partition by sensor_id order by platform_cnt desc) rn
--        from #most_visited_channel t1
--    )t2
--    where rn=1
--) as tt2
--on tt1.sensor_id = tt2.sensor_id
--go


--print( CONVERT(varchar(100), DATEADD(hour,8,getdate()), 21) + ' Engagement, visited_channel insert Start...')
--go

----20210629修改
print( CONVERT(varchar(100), DATEADD(hour,8,getdate()), 21) + ' Engagement, visited_channel insert Start...')

IF OBJECT_ID(N'tempdb..#visited_channel_table1', N'U') IS NOT NULL 
DROP TABLE #visited_channel_table1

CREATE TABLE #visited_channel_table1(
    user_id bigint,
    platform_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
	min_time datetime,
	max_time datetime
)

insert into #visited_channel_table1
select user_id,platform_type,min(time) as min_time,max(time) as max_time
from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
where dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
		-- 20210611新增条件
		and event in ('$AppViewScreen','$MPViewScreen','$pageview')
group by user_id,platform_type

--IF OBJECT_ID(N'tempdb..#visited_channel', N'U') IS NOT NULL 
--DROP TABLE #visited_channel
--go

--CREATE TABLE #visited_channel(
--	sensor_id bigint,
--    first_visited_channel nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
--	last_visited_channel nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
--	visit_recency int
--)
--go

--insert into #visited_channel
--select distinct user_id as sensor_id
--		,case when time = min(time) over(partition by user_id) then platform_type else null end as first_visited_channel
--		,case when time = max(time) over(partition by user_id) then platform_type else null end as last_visited_channel
--		,case when time = max(time) over(partition by user_id) then datediff(day,time,DATEADD(hour,8,getdate())) else null end as visit_recency
--from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
--where dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
--go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, visited_channel update 1 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
--20210521修改成注释之后那段
--with #visited_channel as (
--select distinct user_id as sensor_id
--		,case when time = min(time) over(partition by user_id) then platform_type else null end as first_visited_channel
--		,case when time = max(time) over(partition by user_id) then platform_type else null end as last_visited_channel
--		,case when time = max(time) over(partition by user_id) then datediff(day,time,DATEADD(hour,8,getdate())) else null end as visit_recency
--from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
--where dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
--)

--update [DW_Sephora].[DA_Tagging].engagement
--set first_visited_channel = tt2.first_visited_channel,
--	last_visited_channel = tt2.last_visited_channel,
--	visit_recency = tt2.visit_recency
--from [DW_Sephora].[DA_Tagging].engagement as tt1
--join (
--	select distinct sensor_id
--			,FIRST_VALUE(first_visited_channel) over(partition by sensor_id order by first_ranking) as first_visited_channel
--			,FIRST_VALUE(last_visited_channel) over(partition by sensor_id order by last_ranking) as last_visited_channel
--			,FIRST_VALUE(visit_recency) over(partition by sensor_id order by last_ranking) as visit_recency
--	from (
--		select sensor_id,first_visited_channel,last_visited_channel,visit_recency
--				,row_number() over(partition by sensor_id order by first_visited_channel desc) as first_ranking
--				,row_number() over(partition by sensor_id order by last_visited_channel desc) as last_ranking
--		from #visited_channel
--		) as t2
--) as tt2
--on tt1.sensor_id = tt2.sensor_id
--go

----20210615修改为后面那段
--;with first_visited_channel_temp as (
--select distinct user_id as sensor_id
--		,case when time = min(time) over(partition by user_id) then platform_type else null end as first_visited_channel
--from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
--where dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
--      -- 20210611新增条件
--      and event in ('$AppViewScreen','$MPViewScreen','$pageview')
--)
--;with first_visited_channel_temp as (
--	select user_id as sensor_id,platform_type as first_visited_channel
--	from (
--		select user_id,platform_type,row_number() over(partition by user_id order by time) as ranking
--		from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
--		where dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
--			  -- 20210611新增条件
--			  and event in ('$AppViewScreen','$MPViewScreen','$pageview')
--	) as a
--	where ranking = 1
--) --20210629修改
;with first_visited_channel_temp as (
	select user_id as sensor_id,platform_type as first_visited_channel
	from (
		select user_id,platform_type,row_number() over(partition by user_id order by min_time) as ranking
		from #visited_channel_table1
	) as a
	where ranking = 1
)

update [DW_Sephora].[DA_Tagging].engagement
set first_visited_channel = tt2.first_visited_channel
from [DW_Sephora].[DA_Tagging].engagement as tt1
join first_visited_channel_temp as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, visited_channel update 2 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

--;with last_visited_channel_temp as (
--	select user_id as sensor_id,platform_type as last_visited_channel,datediff(day,time,DATEADD(hour,8,getdate())) as visit_recency
--	from (
--		select user_id,platform_type,time,row_number() over(partition by user_id order by time desc) as ranking
--		from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
--		where dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
--			  -- 20210611新增条件
--			  and event in ('$AppViewScreen','$MPViewScreen','$pageview')
--	) as a
--	where ranking = 1
--) --20210629修改
;with last_visited_channel_temp as (
	select user_id as sensor_id,platform_type as last_visited_channel,datediff(day,max_time,DATEADD(hour,8,getdate())) as visit_recency
	from (
		select user_id,platform_type,max_time,row_number() over(partition by user_id order by max_time desc) as ranking
		from #visited_channel_table1
	) as a
	where ranking = 1
)

update [DW_Sephora].[DA_Tagging].engagement
set last_visited_channel = tt2.last_visited_channel,
	visit_recency = tt2.visit_recency
from [DW_Sephora].[DA_Tagging].engagement as tt1
join last_visited_channel_temp as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, add_to_card update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with #add_to_card as (
	select sensor_id,count(0) as add_to_card_cnt
	from (
		select user_id as sensor_id,time
		from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
		where event in ('addToShoppingcart','buyNow')
			and dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
		group by user_id,time
	) as t1
	group by sensor_id
)

update [DW_Sephora].[DA_Tagging].engagement
set add_to_card = tt2.add_to_card_cnt
from [DW_Sephora].[DA_Tagging].engagement as tt1
join #add_to_card as tt2
on tt1.sensor_id = tt2.sensor_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, visit_frequency update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
----20210910,访问次数改成访问天数, 数据源为event表
IF OBJECT_ID(N'tempdb..#visit_frequency_temp', N'U') IS NOT NULL 
DROP TABLE #visit_frequency_temp
CREATE TABLE #visit_frequency_temp(
    sensor_id bigint,
    visit_frequency int
)

insert into #visit_frequency_temp
select user_id as sensor_id,count(distinct dt) as visit_frequency
from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
where dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
group by user_id 

update [DW_Sephora].[DA_Tagging].engagement
set visit_frequency = tt2.visit_frequency
from [DW_Sephora].[DA_Tagging].engagement as tt1
join #visit_frequency_temp as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, bounce_rate_30d update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set bounce_rate_30d = tt2.bounce_rate_30d
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
	select t1.sensor_id,visit_frequency,click_session_cnt,1-cast(click_session_cnt as float)/visit_frequency as bounce_rate_30d
	from(
			select user_id as sensor_id,count(distinct sessionid) as visit_frequency
				  ,count(distinct case when behavior_type_coding = 'Click' then sessionid else null end) as click_session_cnt
			from [DW_Sephora].[DA_Tagging].v_events_session
			where dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
			group by user_id 
	)t1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, bounce_rate_90d update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set bounce_rate_90d = tt2.bounce_rate_90d
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
	select t1.sensor_id,1-cast(click_session_cnt_90d as float)/visit_frequency_90d as bounce_rate_90d
	from(
			select user_id as sensor_id,count(distinct sessionid) as visit_frequency_90d
				  ,count(distinct case when behavior_type_coding = 'Click' then sessionid else null end) as click_session_cnt_90d
			from [DW_Sephora].[DA_Tagging].v_events_session
			where dt between convert(date,DATEADD(hour,8,getdate()) - 91) and convert(date,DATEADD(hour,8,getdate()) - 1)
			group by user_id  
	)t1
) as tt2
on tt1.sensor_id = tt2.sensor_id
--go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, visit_recency_ranking update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

declare @tot_cnt_rec float = ( select count(distinct sensor_id) as user_cnt
                                from [DW_Sephora].[DA_Tagging].engagement
                                where visit_recency>0 )

print('total recency count:' + convert(nvarchar,@tot_cnt_rec))

update [DW_Sephora].[DA_Tagging].engagement
set visit_recency_ranking = tt2.visit_recency_ranking
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id
            ,case when visit_recency_rn/@tot_cnt_rec > 0 and visit_recency_rn/@tot_cnt_rec <= 0.2 then '(0,20%]'
                when visit_recency_rn/@tot_cnt_rec > 0.2 and visit_recency_rn/@tot_cnt_rec <= 0.4 then '(20%,40%]'
                when visit_recency_rn/@tot_cnt_rec > 0.4 and visit_recency_rn/@tot_cnt_rec <= 0.6 then '(40%,60%]'
                when visit_recency_rn/@tot_cnt_rec > 0.6 and visit_recency_rn/@tot_cnt_rec <= 0.8 then '(60%,80%]'
                when visit_recency_rn/@tot_cnt_rec > 0.8 then '(80%,100%]'
            end as visit_recency_ranking
    from (
        select sensor_id,row_number() over(order by visit_recency) as visit_recency_rn
        from [DW_Sephora].[DA_Tagging].engagement 
        where visit_recency>0
	) as t1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, visit_frequency_ranking update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

declare @tot_cnt_fre float = ( select count(distinct sensor_id) as user_cnt
                                from [DW_Sephora].[DA_Tagging].engagement
                                where visit_frequency>0 )

print('total frequency count:' + convert(nvarchar,@tot_cnt_fre))

update [DW_Sephora].[DA_Tagging].engagement
set visit_frequency_ranking = tt2.visit_frequency_ranking
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id
            ,case when visit_frequency_rn/@tot_cnt_fre > 0 and visit_frequency_rn/@tot_cnt_fre <= 0.2 then '(0,20%]'
                when visit_frequency_rn/@tot_cnt_fre > 0.2 and visit_frequency_rn/@tot_cnt_fre <= 0.4 then '(20%,40%]'
                when visit_frequency_rn/@tot_cnt_fre > 0.4 and visit_frequency_rn/@tot_cnt_fre <= 0.6 then '(40%,60%]'
                when visit_frequency_rn/@tot_cnt_fre > 0.6 and visit_frequency_rn/@tot_cnt_fre <= 0.8 then '(60%,80%]'
                when visit_frequency_rn/@tot_cnt_fre > 0.8 then '(80%,100%]'
            end as visit_frequency_ranking
    from (
        select sensor_id,row_number() over(order by visit_frequency desc) as visit_frequency_rn
        from [DW_Sephora].[DA_Tagging].engagement
		where visit_frequency > 0
	) as t1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, product_cnt insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

IF OBJECT_ID(N'tempdb..#prod_cnt_temp', N'U') IS NOT NULL 
DROP TABLE #prod_cnt_temp
-- go

create table #prod_cnt_temp(
    sensor_id bigint,
    brand nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    category nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    subcategory nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    thirdcategory nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    segment nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    cnt int
)
-- go

insert into #prod_cnt_temp
select user_id as sensor_id,brand,category,subcategory,thirdcategory,segment,count(0) as cnt
from [DW_Sephora].[DA_Tagging].v_events_session
where brand is not null
      and event = 'viewCommodityDetail'
	  and dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
group by user_id,brand,category,subcategory,thirdcategory,segment
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, most_visited_category update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set most_visited_category = tt2.most_visited_category
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id,category as most_visited_category
    from (
        select sensor_id,category,row_number() over(partition by sensor_id order by cacnt desc) as ranking
        from (
            select sensor_id,category,sum(cnt) as cacnt
            from #prod_cnt_temp
            group by sensor_id,category
            ) as t1
        ) as t2
    where ranking = 1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, most_visited_subcategory update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set most_visited_subcategory = tt2.most_visited_subcategory
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id,subcategory as most_visited_subcategory
    from (
        select sensor_id,subcategory,row_number() over(partition by sensor_id order by cacnt desc) as ranking
        from (
            select sensor_id,subcategory,sum(cnt) as cacnt
            from #prod_cnt_temp
            group by sensor_id,subcategory
            ) as t1
        ) as t2
    where ranking = 1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, most_visited_thirdcategory update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set most_visited_thirdcategory = tt2.most_visited_thirdcategory
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id,thirdcategory as most_visited_thirdcategory
    from (
        select sensor_id,thirdcategory,row_number() over(partition by sensor_id order by cacnt desc) as ranking
        from (
            select sensor_id,thirdcategory,sum(cnt) as cacnt
            from #prod_cnt_temp
            group by sensor_id,thirdcategory
            ) as t1
        ) as t2
    where ranking = 1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, most_visited_brand update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set most_visited_brand = tt2.most_visited_brand
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id,brand as most_visited_brand
    from (
        select sensor_id,brand,row_number() over(partition by sensor_id order by cacnt desc) as ranking
        from (
            select sensor_id,brand,sum(cnt) as cacnt
            from #prod_cnt_temp
            group by sensor_id,brand
            ) as t1
        ) as t2
    where ranking = 1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, most_visited_detailcategory update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set most_visited_detailcategory = tt2.most_visited_detailcategory
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id,segment as most_visited_detailcategory
    from (
        select sensor_id,segment,row_number() over(partition by sensor_id order by cacnt desc) as ranking
        from (
            select sensor_id,segment,sum(cnt) as cacnt
            from #prod_cnt_temp
            group by sensor_id,segment
            ) as t1
        ) as t2
    where ranking = 1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, productline_cnt insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

IF OBJECT_ID(N'tempdb..#productline_cnt_temp', N'U') IS NOT NULL 
DROP TABLE #productline_cnt_temp
-- go

create table #productline_cnt_temp(
    sensor_id bigint,
    productline nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    cnt int
)
-- go

insert into #productline_cnt_temp
select user_id as sensor_id,productline,count(0) as cnt
from [DW_Sephora].[DA_Tagging].v_events_session
where productline is not null
      and dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
group by user_id,productline
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, most_visited_product_line update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set most_visited_product_line = tt2.most_visited_product_line
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id,productline as most_visited_product_line
    from (
        select sensor_id,productline,row_number() over(partition by sensor_id order by cnt desc) as ranking
        from #productline_cnt_temp
        ) as t1
    where ranking = 1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, productfunction_cnt insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

IF OBJECT_ID(N'tempdb..#productfunction_cnt_temp', N'U') IS NOT NULL 
DROP TABLE #productfunction_cnt_temp
-- go

create table #productfunction_cnt_temp(
    sensor_id bigint,
    productfunction nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    cnt int
)
-- go

insert into #productfunction_cnt_temp
select user_id as sensor_id,productfunction,count(0) as cnt
from [DW_Sephora].[DA_Tagging].v_events_session
where productfunction is not null
      and dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
group by user_id,productfunction
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, most_visited_function update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

update [DW_Sephora].[DA_Tagging].engagement
set most_visited_function = tt2.most_visited_function
from [DW_Sephora].[DA_Tagging].engagement as tt1
join (
    select sensor_id,productfunction as most_visited_function
    from (
        select sensor_id,productfunction,row_number() over(partition by sensor_id order by cnt desc) as ranking
        from #productfunction_cnt_temp
        ) as t1
    where ranking = 1
) as tt2
on tt1.sensor_id = tt2.sensor_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, average_visited_product_30d update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with average_visited_product_30d_temp as (
	select sensor_id,avg(procnt) average_visited_product_30d
	from(
		select user_id as sensor_id,dt,count(distinct op_code) as procnt
		from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
		where op_code is not null
		      and dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
		group by user_id,dt
	)t1
	group by sensor_id
)

update [DW_Sephora].[DA_Tagging].engagement
set average_visited_product_30d = tt2.average_visited_product_30d
from [DW_Sephora].[DA_Tagging].engagement as tt1
join average_visited_product_30d_temp as tt2
on tt1.sensor_id = tt2.sensor_id

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, average_stay_time_30d update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with average_stay_time_30d_temp as (
	select sensor_id,avg(sessiontime) average_stay_time_30d--,avg(procnt) average_visited_product_30d
	from(
		select platform_type,user_id as sensor_id,sessionid,sessiontime--,count(distinct product_id) as procnt
		from [DW_Sephora].[DA_Tagging].v_events_session
		where dt between convert(date,DATEADD(hour,8,getdate()) - 31) and convert(date,DATEADD(hour,8,getdate()) - 1)
		group by platform_type,user_id,sessionid,sessiontime
	)t1
	group by sensor_id
)

update [DW_Sephora].[DA_Tagging].engagement
set average_stay_time_30d = tt2.average_stay_time_30d
from [DW_Sephora].[DA_Tagging].engagement as tt1
join average_stay_time_30d_temp as tt2
on tt1.sensor_id = tt2.sensor_id
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, average_visited_product_90d update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with average_visited_product_90d_temp as (
	select sensor_id,avg(procnt) average_visited_product_90d
	from(
		select user_id as sensor_id,dt,count(distinct op_code) as procnt
		from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
		where  op_code is not null
		       and dt between convert(date,DATEADD(hour,8,getdate()) - 91) and convert(date,DATEADD(hour,8,getdate()) - 1)
		group by user_id,dt
	)t1
	group by sensor_id
)

update [DW_Sephora].[DA_Tagging].engagement
set average_visited_product_90d = tt2.average_visited_product_90d
from [DW_Sephora].[DA_Tagging].engagement as tt1
join average_visited_product_90d_temp as tt2
on tt1.sensor_id = tt2.sensor_id

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, average_stay_time_90d update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

;with average_stay_time_90d_temp as (
    select sensor_id,avg(sessiontime) average_stay_time_90d--,avg(procnt) average_visited_product_90d
    from(
        select platform_type,user_id as sensor_id,sessionid,sessiontime--,count(distinct product_id) as procnt
        from [DW_Sephora].[DA_Tagging].v_events_session
		where dt between convert(date,DATEADD(hour,8,getdate()) - 91) and convert(date,DATEADD(hour,8,getdate()) - 1)
        group by platform_type,user_id,sessionid,sessiontime
    )t1
    group by sensor_id
)

update [DW_Sephora].[DA_Tagging].engagement
set average_stay_time_90d = tt2.average_stay_time_90d
from [DW_Sephora].[DA_Tagging].engagement as tt1
join average_stay_time_90d_temp as tt2
on tt1.sensor_id = tt2.sensor_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','Engagement, delete null Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

delete from [DW_Sephora].[DA_Tagging].engagement
where add_to_card is null 
	and most_visited_channel is null 
	and first_visited_channel is null 
	and last_visited_channel is null 
	and visit_recency is null 
	and hour_preference is null 
	and weekday_preference is null 
	and visit_frequency is null 
	and bounce_rate_30d is null 
	and bounce_rate_90d is null 
	and visit_recency_ranking is null 
	and visit_frequency_ranking is null 
	and most_visited_category is null 
	and most_visited_subcategory is null 
	and most_visited_thirdcategory is null 
	and most_visited_brand is null 
	and most_visited_detailcategory is null 
	and most_visited_product_line is null 
	and most_visited_function is null 
	and average_visited_product_30d is null 
	and average_stay_time_30d is null 
	and average_visited_product_90d is null 
	and average_stay_time_90d is null
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_3','engagement end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
END
GO
