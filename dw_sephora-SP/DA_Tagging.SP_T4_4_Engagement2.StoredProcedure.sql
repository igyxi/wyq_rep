/****** Object:  StoredProcedure [DA_Tagging].[SP_T4_4_Engagement2]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T4_4_Engagement2] AS
BEGIN

/* ############ ############ ############ Engagement Update ############ ############ ############ */

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Tab Start...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

TRUNCATE TABLE DA_Tagging.engagement2
insert into DA_Tagging.engagement2(master_id, sensor_user_id, device_id_IDFA, device_id_IMEI, device_id_others, wechat_union_id,sephora_user_id,sephora_card_no)
select master_id, sensor_id as sensor_user_id, device_id_IDFA, device_id_IMEI, device_id_others, wechat_union_id ,sephora_user_id,sephora_card_no
from DA_Tagging.id_mapping
where invalid_date='9999-12-31'
;


/* ############ ############ ############ Engagement Weely Update Tag ############ ############ ############ 
Conversion_probabilty		// 购买概率
Most_Searched_Brand			// 最常搜索的品牌
Most_Searched_Category		// 最常搜索的品类
Most_Searched_Function		// 最常搜索的功能
BeautyIN_Visit				// 美印访问天数
Campaign_Engaged			// 最常参与的活动类型
Campaign_Product_Click		// 活动期间产品点击次数
Campaign_Page_AVG_Stay_Time	// APP&MNP活动期间平均停留时间
Campaign_Visit				// 活动期间访问天数
APP_Activation				// 是否由投放进行APP激活
Holiday_Preference			// 最常浏览的节假日
Season_Preference			// 最常浏览的季节
Private_Sale_Preference		// 最常浏览的大促期间
UV_Value					// 每天访问价值*/
DECLARE @WeekNum VARCHAR(10)= datename(weekday, DATEADD(hour,8,getdate()))
if @WeekNum='Saturday'  --'Thursday' Saturday
begin 

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement pageview & submitOrder Temp Tab ...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		;

		--7min
		-- P90d pageview & submitOrder
		-- 1209根据业务需求 改成按180天计算
		IF OBJECT_ID('tempdb..#v_events_pageview_90d','U')  IS NOT NULL
		drop table #v_events_pageview_90d;
		create table #v_events_pageview_90d
		(	
			user_id bigint ,
			event nvarchar(255) collate Chinese_PRC_CS_AI_WS,
			time datetime,
			dt date
		)
		insert into #v_events_pageview_90d(user_id ,event,time,dt)
		select user_id ,event,time,dt
		from STG_Sensor.V_Events
		where  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		and event in ('$AppViewScreen','$MPViewScreen','$pageview','submitOrder')
		;


		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [conversion_probabilty]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 486.用户购买概率：计算既有浏览又有购买的session数除以有浏览的session数
		/*
		当 event = 'submitOrder'时，对应的sessionid为有购买记录
		当event ('$AppViewScreen', '$MPViewScreen','$pageview')
		对应的sessionid为有访问记录
		*/

		--0.5min
		update DA_Tagging.tagging_weekly
		set conversion_probabilty = tt.conversion_probabilty
		from DA_Tagging.tagging_weekly t1
		join(
			select t1.user_id,convert(float,order_dt)/convert(float,view_dt) as conversion_probabilty
			from(
				select user_id, count(distinct dt)  as view_dt
				from #v_events_pageview_90d
				where event in ('$AppViewScreen', '$MPViewScreen','$pageview')
				group by  user_id
			)t1 left join(
				select user_id, count(distinct dt)  as order_dt
				from #v_events_pageview_90d
				where event='submitOrder'
				group by  user_id
			)t2 on t1.user_id = t2.user_id
		)tt  on t1.sensor_id = tt.user_id 
		;


		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement Most Searched Brand & Category & Function temp',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 478.最常搜索的品牌
		-- 注1：原来如果和oms.v_sku_profile相联结的话，events表里的op_code缺失，所以还是根据brand content 里边查找近义词
		-- 注2：搜索次数最多用什么数据来衡量
		/*筛选项
		（platform_type ='app',event='clickBanner_App_Mob')，
		or(platform_type ='MiniProgram',event='clickBanner_MP')
		or(platform_type ='web',event='clickBanner_web')
		or(platform_type ='mobile',event='clickBanner_App_Mob')
		banner_belong_area='searchview',
		用banner_content匹配[DA_Tagging.coding_synonyms_match]中的Synoyms，得到对应name
		计算90天内搜索次数最多的品牌 品类 功能
		*/

		--建立搜索词中间表 3min
		-- 1209 根据业务需求改为180天
		select user_id,dt,time, tt.query as query,t2.name as standard_query , t2.[type]
		into #v_events_search_value_P90d
		from(
			select user_id,dt,time ,value as query
			from STG_Sensor.V_Events
			CROSS APPLY  String_Split(banner_content, N'|')     -- 对banner_content进行分列处理
			where banner_belong_area = 'searchview'
			and event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  -- 对platform_type,event做相应限制
			and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)-- 时间限制：近180天
		)tt 
		left join DA_Tagging.coding_synonyms_match t2 on tt.query = t2.Synoyms collate Chinese_PRC_CS_AI_WS
		;

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [most_searched_brand],[most_searched_category],[most_searched_function]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;

		--15s
		update DA_Tagging.tagging_weekly
		set most_searched_brand= tt.most_searched_brand
			,most_searched_category= tt.most_searched_category
			,most_searched_function= tt.most_searched_function
		from DA_Tagging.tagging_weekly t1
		join(
			select user_id
			,max(case when type='Brand' then max_cnt_query end ) as most_searched_brand
			,max(case when type='level1_name' then max_cnt_query end ) as most_searched_category
			,max(case when type='Function' then max_cnt_query end ) as most_searched_function
			from(
				select user_id,type
				,case when query_cnt= (max(query_cnt) over(partition by user_id,type) ) then standard_query else null end as max_cnt_query
				from(
					select user_id,type,standard_query, count(0) as query_cnt
					from #v_events_search_value_P90d
					where standard_query is not null
					group by user_id,type,standard_query
					)t1 
				)tt1 group by user_id
		)tt on t1.sensor_id = tt.user_id 
		;


		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [beautyin_visit]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 491.美印访问次数：首页运营位点击bottom bar + event=beautyin_blog_view，banner content有美印信息，按session个数算
		--6min
		--update DA_Tagging.engagement2
		--set beautyin_visit = tt.beautyin_dt_cn 
		--from DA_Tagging.engagement2 t1
		--join(
		--    select user_id,COUNT(distinct dt) as beautyin_dt_cn
		--    from STG_Sensor.V_Events
		--    where (event = 'beautyIN_blog_view' 
		--        or event = 'beautyIN_bottom_tab_click'
		--        or banner_content LIKE N'%beautyIN%'
		--        or banner_content LIKE N'%美印%')
		--		and dt between convert(date,getdate() -90) and convert(date,getdate() -1) 
		--    group by user_id
		--)tt on t1.sensor_id=tt.user_id
		--;
		-- 0915 修改为Temp表的形式计算
		IF OBJECT_ID('tempdb..#beautyin_dt_cn','U')  IS NOT NULL
		drop table #beautyin_dt_cn;
		create table #beautyin_dt_cn(user_id bigint ,beautyin_dt_cn int)
		insert into #beautyin_dt_cn(user_id,beautyin_dt_cn)
		select user_id,COUNT(distinct dt) as beautyin_dt_cn
		from STG_Sensor.V_Events
		where (event = 'beautyIN_blog_view' 
		   or event = 'beautyIN_bottom_tab_click'
		   or banner_content LIKE N'%beautyIN%'
		   or banner_content LIKE N'%美印%')
			and dt between convert(date,getdate() -180) and convert(date,getdate() -1) 
		group by user_id
		;

		update DA_Tagging.tagging_weekly
		set beautyin_visit = tt.beautyin_dt_cn 
		from DA_Tagging.tagging_weekly t1
		join #beautyin_dt_cn tt on t1.sensor_id=tt.user_id

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement Campaign Temp',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;

		--建立P90d内campaign期间的页面浏览中间表
		--6min
		truncate table [DA_Tagging].[v_events_campaign_P90d]
		insert into [DA_Tagging].[v_events_campaign_P90d](user_id,dt,time,event,visit_hour,campaign_type,[platform],campaign_detail)
		select user_id,dt,time,event,datename(hour,time) as visit_hour
		,t2.Campaign_Type,t2.Platform,t2.Campaign_Detail
		from STG_Sensor.V_Events t1
		inner join (
			select distinct convert(varchar(10),Campaign_Date) as Campaign_Date, Campaign_Type,Platform ,Campaign_Detail from  DA_Tagging.coding_campaign_name 
				)t2 on t1.dt = t2.Campaign_Date	
		where t1.dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		and event in ('$AppViewScreen', '$MPViewScreen','$pageview','viewCommodityDetail')
		;

		-- 493.最常参与的活动类型：计算每个用户90天内数量最多的活动类型，以时间判断活动类型
		/** 
		逻辑：
		创建虚拟表1：包含字段：date，Campaign_Type，platform
		创建虚拟表2：RIGHT JOIN 表格：[STG_Sensor].[V_Events],包含字段date，Campaign_Type，platform，campaign_count 时间限制：近90天
		创建虚拟表3：在虚拟表2的基础上，使用开窗函数ROW_NUMBER()对campaign_count进行降序，获得新列【排名】
		在虚拟表3的基础上，筛选出每位用户对应的排名第一的活动
		**/ 

		
		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [campaign_engaged]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;

		--2min
		IF OBJECT_ID('tempdb..#Campaign_Type','U')  IS NOT NULL
		drop table #Campaign_Type;
		create table #Campaign_Type
		(	
			user_id bigint ,
			Campaign_Type nvarchar(255) collate Chinese_PRC_CS_AI_WS
		)
		insert into #Campaign_Type(user_id,Campaign_Type)
		select user_id,Campaign_Type
		from(
			select user_id,Campaign_Type
			,row_number() over (partition by user_id order by campaign_engaged desc) rn
			from(
				select user_id,Campaign_Type,count(distinct dt) as campaign_engaged
				from [DA_Tagging].[v_events_campaign_P90d]
				group by user_id,Campaign_Type
			)t1
		)tt1
		where rn=1


		update DA_Tagging.tagging_weekly
		set campaign_engaged = tt.Campaign_Type 
		from  DA_Tagging.tagging_weekly t1
		join #Campaign_Type tt on t1.sensor_id=tt.user_id
		;

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [campaign_product_click]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;

		-- 496.活动期间产品点击次数：取90天活动期间内event = ‘viewCommodityDetail’的op_code，计算每个用户点击产品的次数
		-- 实际的关联表为：[DA_Tagging].[v_events_session]
		-- 6min
		update DA_Tagging.tagging_weekly
		set campaign_product_click = tt.campaign_product_click 
		from DA_Tagging.tagging_weekly t1
		join(
			select user_id,count(distinct op_code) as campaign_product_click
			from STG_Sensor.V_Events
			where event = 'viewCommodityDetail'
			and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
			and dt in (select distinct Campaign_Date from DA_Tagging.coding_campaign_name)
			group by  user_id
		)tt on t1.sensor_id=tt.user_id
		;


		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [campaign_page_avg_stay_time],[campaign_visit]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 497.活动期间平均停留时间：计算90天活动期间用户平均session time    
		-- 498.活动期间访问次数：计算90天活动期间用户平均session个数 
		-- 30s
		update DA_Tagging.tagging_weekly
		set campaign_page_avg_stay_time = tt.campaign_page_avg_stay_time 
			--,campaign_visit = tt.campaign_visit
		from DA_Tagging.tagging_weekly t1
		join(
			select user_id
			, round(avg(sessiontime),2) as campaign_page_avg_stay_time
			--, count(distinct sessionid) as campaign_visit
			from(
				select distinct user_id, sessionid, sessiontime 
				from [DA_Tagging].[v_events_session]
				where dt in (select distinct Campaign_Date from DA_Tagging.coding_campaign_name)
				and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)-- session表筛选近90天
			) t1
			group by  user_id
		)tt on t1.sensor_id=tt.user_id
		;


		update DA_Tagging.tagging_weekly
		set campaign_visit = tt.campaign_visit
		from DA_Tagging.tagging_weekly t1
		join(
			select user_id, count(distinct dt) as campaign_visit
				from STG_Sensor.V_Events
				where dt in (select distinct Campaign_Date from DA_Tagging.coding_campaign_name)
				and event in ('$AppViewScreen', '$MPViewScreen','$pageview','viewCommodityDetail')
				and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)-- session表筛选近90天
			group by  user_id
		)tt on t1.sensor_id=tt.user_id
		;


		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement App Activation Sensor',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 504.是否由投放进行APP激活：计算每个用户是否在install表中有对应的device_id,有则1，无则0
		/* 细节要求
		数据源：[ODS_TD].[Tb_android_Install],[ODS_TD].[Tb_IOS_Install]
		列：android_id,idfa
		*/
		--取出 app 激活用户
		IF OBJECT_ID('tempdb..#app_sensor','U')  IS NOT NULL
		drop table #app_sensor;
		create table #app_sensor(
			user_id bigint
		)
		insert into #app_sensor(user_id)
		select distinct user_id 
		from STG_Sensor.V_Events
		where dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		and platform_type in ('app','APP')
		;

		update DA_Tagging.tagging_weekly
		set app_activation= 0
		from DA_Tagging.tagging_weekly t1
		join #app_sensor t2 on t1.sensor_id = t2.user_id 
		;

	
		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement App(android_id) Activation',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;


		IF OBJECT_ID('tempdb..#android_id','U')  IS NOT NULL
		drop table #android_id;
		create table #android_id
		(
			android_id nvarchar(255) collate Chinese_PRC_CS_AI_WS
		)
		insert into #android_id(android_id)
		select distinct android_id
		from ODS_TD.Tb_android_Install 
		where convert(date,active_time) between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		and android_id is not null
		;

		-- 1min
		update DA_Tagging.tagging_weekly
		set app_activation=1
		from DA_Tagging.tagging_weekly t1
		join #android_id t2 on t1.device_id_IMEI = t2.android_id  collate Chinese_PRC_CS_AI_WS
		;

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement App(ios) Activation',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;


		IF OBJECT_ID('tempdb..#idfa','U')  IS NOT NULL
		drop table #idfa;
		create table #idfa
		(	
			idfa nvarchar(255) collate Chinese_PRC_CS_AI_WS
		)
		insert into #idfa(idfa)
		select distinct idfa  
		from ODS_TD.Tb_ios_Install 
		where convert(date,active_time) between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		and idfa is not null
		;
		
		-- 1min
		update DA_Tagging.tagging_weekly
		set app_activation=1
		from DA_Tagging.tagging_weekly t1
		join #idfa t2 on t1.device_id_IDFA = t2.idfa collate Chinese_PRC_CS_AI_WS
		;

		
		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement Holiday Preference temp',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 73.最常浏览的节假日：Holiday Visited Preference 统计每个user_id在360天内出现最多的节假日
		-- 10 min
		-- 此处表名应为 DA_Tagging.v_events_hour_preference 
		-- 5min
		IF OBJECT_ID('tempdb..#v_events_holiday_preference','U')  IS NOT NULL
		drop table #v_events_holiday_preference;
		create table #v_events_holiday_preference
		(	
			user_id bigint,
			holiday_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
		)
		insert into #v_events_holiday_preference(user_id, holiday_preference)
		select user_id, holiday_preference
		from(
			select user_id, holiday_preference 
				,row_number() over(partition by user_id order by visit_cnt desc) as rn
			from(
				select user_id, holidays_festivals as holiday_preference,count(0) as visit_cnt
				from(
					select user_id,event ,dt
					from [STG_Sensor].[V_Events]
					where dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
					and [event] in ('$AppViewScreen', '$MPViewScreen', '$pageview')
					)t1 join(
						select daytype,date,holidays_festivals from DA_Tagging.coding_daytype 
						where daytype = 'Holidays and Festivals'
						)t2 on t1.dt = t2.date
				group by  user_id, holidays_festivals
				)tt1
		)tt2 where rn=1

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement Holiday Preference',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;

		update DA_Tagging.tagging_weekly
		set holiday_preference = tt.holiday_preference
		from DA_Tagging.tagging_weekly t1
		join  #v_events_holiday_preference tt on t1.sensor_id=tt.user_id
		;

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement Season Preference temp',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 75.最常浏览的季节：Season Visited Preference 统计每个user_id在360天内出现最多的季节
		-- 8min
		IF OBJECT_ID('tempdb..#v_events_season_preference','U')  IS NOT NULL
		drop table #v_events_season_preference;
		create table #v_events_season_preference
		(	
			user_id bigint,
			season_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
		)
		insert into #v_events_season_preference(user_id,season_preference)
		select user_id ,season as season_preference
		from (
			select user_id,season
			,row_number() over(partition by user_id order by visit_cnt desc) as rn
			from(
				select user_id,season,count(0) as visit_cnt
				from(
					select user_id 
					,case when month(time) in (3,4,5) then 'Spring' 
					when month(time) in (6,7,8) then 'Summer'
					when month(time) in (9,10,11) then 'Autumn'
					when month(time) in (12,1,2) then 'Winter' end as season
					from STG_Sensor.V_Events
					where dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
					and event in ('$AppViewScreen', '$MPViewScreen', '$pageview')
				)t group by  user_id,season
			)tt
		)t2 where rn=1
		;

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement Season Preference',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;

		update DA_Tagging.tagging_weekly
		set season_preference = tt.season_preference
		from DA_Tagging.tagging_weekly t1
		join #v_events_season_preference tt on t1.sensor_id=tt.user_id
		;


		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement Private Sale Preference temp',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 72.最常浏览的大促期间：Campaign_Name  统计每个user_id在360天内出现最多的大促name
		-- min
		IF OBJECT_ID('tempdb..#v_events_private_preference','U')  IS NOT NULL
		drop table #v_events_private_preference;
		create table #v_events_private_preference
		(
			user_id bigint,
			private_sale_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
		)
		insert into #v_events_private_preference(user_id,private_sale_preference)
		select user_id,private_sale_preference
		from(
			select user_id,Campaign_Name as private_sale_preference
			,row_number() over(partition by user_id order by Campaign_Name_cnt desc) rn
			from(
				select user_id,Campaign_Name,count(0) as Campaign_Name_cnt
				from(
					select user_id,event,convert(date,dt) as dt_date
					from STG_Sensor.V_Events
						where event in ('$AppViewScreen','$MPViewScreen','$pageview')
						and DateDiff(dd,convert(date,dt),getdate())<180
					)t1 
					inner join DA_Tagging.coding_campaign_name tt1 
					on t1.dt_date = tt1.Campaign_Date
				where Campaign_Type = 'Private Sales' 
				group by  user_id,Campaign_Name
			)tt
		)ttt where rn=1
		;


		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement Private Sale Preference',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;

		update DA_Tagging.tagging_weekly
		set private_sale_preference = tt.private_sale_preference
		from DA_Tagging.tagging_weekly t1
		join #v_events_private_preference tt on t1.sensor_id=tt.user_id
		;

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [uv_value] temp ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		-- 624新增：每位用户单次访问价值：30天内，dragon渠道总花费/dragon访问session个数
		/*
		1.session表联结id_mapping表获取：master_id,user_id,session_count   记作T1
		2.订单表联结id_mapping表获取：master_id,member_id,product_amount_sum  记作T2
		3.T1 左联 T2，获得字段：master_id，uv_value
		*/
		--  min

		IF OBJECT_ID('tempdb..#v_events_uv_sales','U')  IS NOT NULL
		drop table #v_events_uv_sales;
		create table #v_events_uv_sales
		(
			sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
			p30d_sales float
		)
		insert into #v_events_uv_sales(sales_member_id,p30d_sales) 
		select member_card as sales_member_id, sum(item_apportion_amount) as p30d_sales
		from DW_OMS.V_Sales_order_VB_Level
		where is_placed_flag=1 and item_apportion_amount>0 and store_cd='S001'
		and convert(date,place_time) between convert(date,DATEADD(hour,8,getdate()) - 180)  and convert(date,DATEADD(hour,8,getdate()) - 1)
		and isnumeric(member_card)=1
		group by member_card
		;

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [uv_value] sales ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;

		update DA_Tagging.tagging_weekly
		set uv_value = t2.p30d_sales
		from DA_Tagging.tagging_weekly t1
		join #v_events_uv_sales t2 on t1.sephora_card_no = convert(nvarchar(255),t2.sales_member_id) collate Chinese_PRC_CS_AI_WS



		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [uv_value] ',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
		update DA_Tagging.tagging_weekly
		set uv_value = t1.uv_value/tt.dt_cn
		from DA_Tagging.tagging_weekly t1
		join(
			select user_id, dt_cn
			from(
				select user_id, count(distinct dt) as dt_cn
				from STG_Sensor.V_Events 
				where dt between convert(date,getdate() -180) and convert(date,getdate() -1) 
				group by user_id
			)t1 
		)tt on t1.sensor_id = tt.user_id
		where t1.uv_value is not null
		;

		insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
		select 'Engagement','Tagging System Engagement, Generate Engagement [uv_value] end',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
		;
end

/* ############ ############ ############ Engagement Daily Update Tag ############ ############ ############ */
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Update Engagement Weekly Tag temp Start...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
IF OBJECT_ID('tempdb..#weekly_engagement2','U')  IS NOT NULL
drop table #weekly_engagement2;
create table #weekly_engagement2(
		master_id bigint,
		Conversion_probabilty	float,    
		Most_Searched_Brand	nvarchar(255)  collate  Chinese_PRC_CS_AI_WS,
		Most_Searched_Category	nvarchar(255)  collate  Chinese_PRC_CS_AI_WS,
		Most_Searched_Function	nvarchar(255)  collate  Chinese_PRC_CS_AI_WS,
		BeautyIN_Visit	int,    
		Campaign_Engaged	nvarchar(255)  collate  Chinese_PRC_CS_AI_WS,
		Campaign_Product_Click	int,    
		Campaign_Page_AVG_Stay_Time	int,    
		Campaign_Visit	int,	    
		APP_Activation	int,    
		Holiday_Preference	nvarchar(255)  collate  Chinese_PRC_CS_AI_WS,
		Season_Preference	nvarchar(255)  collate  Chinese_PRC_CS_AI_WS,
		Private_Sale_Preference	nvarchar(255)  collate  Chinese_PRC_CS_AI_WS,
		UV_Value	float
)
insert into #weekly_engagement2(master_id,Conversion_probabilty,Most_Searched_Brand,Most_Searched_Category,Most_Searched_Function,BeautyIN_Visit,Campaign_Engaged,Campaign_Product_Click
,Campaign_Page_AVG_Stay_Time,Campaign_Visit,APP_Activation,Holiday_Preference,Season_Preference,Private_Sale_Preference,UV_Value)
select master_id,Conversion_probabilty,Most_Searched_Brand,Most_Searched_Category,Most_Searched_Function,BeautyIN_Visit,Campaign_Engaged,Campaign_Product_Click
,Campaign_Page_AVG_Stay_Time,Campaign_Visit,APP_Activation,Holiday_Preference,Season_Preference,Private_Sale_Preference,UV_Value
from DA_Tagging.tagging_weekly


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Update Engagement Weekly Tag Start...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
update DA_Tagging.engagement2
set  Conversion_probabilty = t2.Conversion_probabilty
	, Most_Searched_Brand = t2.Most_Searched_Brand
	, Most_Searched_Category = t2.Most_Searched_Category
	, Most_Searched_Function = t2.Most_Searched_Function
	, BeautyIN_Visit = t2.BeautyIN_Visit
	, Campaign_Engaged = t2.Campaign_Engaged
	, Campaign_Product_Click = t2.Campaign_Product_Click
	, Campaign_Page_AVG_Stay_Time = t2.Campaign_Page_AVG_Stay_Time
	, Campaign_Visit = t2.Campaign_Visit
	, APP_Activation = t2.APP_Activation
	, Holiday_Preference = t2.Holiday_Preference
	, Season_Preference = t2.Season_Preference
	, Private_Sale_Preference = t2.Private_Sale_Preference
	, UV_Value = t2.UV_Value
from DA_Tagging.engagement2 t1
join (
	select master_id, Conversion_probabilty,Most_Searched_Brand,Most_Searched_Category,Most_Searched_Function,BeautyIN_Visit,Campaign_Engaged,Campaign_Product_Click
	,Campaign_Page_AVG_Stay_Time,Campaign_Visit,APP_Activation,Holiday_Preference,Season_Preference,Private_Sale_Preference,UV_Value
	from DA_Tagging.tagging_weekly
	where Conversion_probabilty is not null
		or Most_Searched_Brand is not null
		or Most_Searched_Category is not null
		or Most_Searched_Function is not null
		or BeautyIN_Visit is not null
		or Campaign_Engaged is not null
		or Campaign_Product_Click is not null
		or Campaign_Page_AVG_Stay_Time is not null
		or Campaign_Visit is not null
		or APP_Activation is not null
		or Holiday_Preference is not null
		or Season_Preference is not null
		or Private_Sale_Preference is not null
		or UV_Value is not null
)t2 on t1.master_id = t2.master_id


--====================================================--====================================================--====================================================
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Update Engagement Media Source Session Temp1 Start...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

select user_id,ss_os,ss_device_id,time,dt,platform_type,ss_utm_source,ss_utm_medium,spreadname,channel_name,event--,os
, row_number() over (partition by user_id,dt order by time) as id
into #source_session_app_temp1
from(
        -- app
        select user_id,ss_os,ss_device_id, time,dt,platform_type, null as ss_utm_source,null as ss_utm_medium, spreadname,channel_name,event
        from(
            select  user_id,time,dt
			, case when platform_type='APP' then 'app' else platform_type end as platform_type,ss_os,ss_device_id,event
            from STG_Sensor.V_Events
            WHERE dt = convert(date,DATEADD(hour,8,getdate()) - 1)
            AND platform_type = 'app'
        )t1
        left outer join(
            SELECT idfa AS device_id ,clicktime,spreadname,channel_name 
            FROM ODS_TD.Tb_IOS_Click_Arrange where convert(date,clicktime)=convert(date,DATEADD(hour,8,getdate()) - 1)
            UNION ALL
            SELECT androidid AS device_id ,clicktime,spreadname,channel_name 
            FROM ODS_TD.Tb_Android_Click_Arrange where convert(date,clicktime) =convert(date,DATEADD(hour,8,getdate()) - 1)
        )t2
        on t1.ss_device_id = t2.device_id collate Chinese_PRC_CS_AI_WS
        and t1.dt = convert(date,t2.clicktime) and datename(hour,t1.time) = datename(hour,t2.clicktime) and datename(Minute,t1.time) = datename(Minute,t2.clicktime) 
        where  spreadname is not null or event = '$AppViewScreen' or event='viewCommodityDetail'
                            
        UNION ALL
                            
        --noapp
        select user_id, ss_os, ss_device_id, time, dt
        ,case when platform_type='Mini Program' then 'MiniProgram' else platform_type end as  platform_type
        , ss_utm_source,ss_utm_medium,null as spreadname,null as channel_name, event
        from STG_Sensor.V_Events
        where dt =convert(date,DATEADD(hour,8,getdate()) - 1)
        and(
            (platform_type = 'MiniProgram' AND event = '$MPViewScreen')
            OR  (platform_type = 'mobile' AND event = '$pageview')
            OR  (platform_type = 'web' AND event = '$pageview')
            or  (ss_utm_source IS NOT NULL and platform_type in ('MiniProgram', 'mobile', 'web') )
            or  (event = 'viewCommodityDetail' and platform_type in ('MiniProgram', 'mobile', 'web') )
    )
)tt
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Update Engagement Media Source Session Temp2 Start...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
                            
select id,user_id,dt,event,time,ss_os,ss_device_id,platform_type
,case when spreadname is null then 'this_session_no_spreadname' else spreadname end as spreadname
,case when channel_name is null then 'this_session_no_channel_name' else channel_name end as channel_name
,case when ss_utm_source is null then null else ss_utm_source end as ss_utm_source
,case when ss_utm_medium is null then null else ss_utm_medium end as ss_utm_medium
into #source_session_app_temp2
from (
    select t1.id,t1.user_id,t1.event,t1.time,t1.platform_type,t1.dt,t1.ss_os,t1.ss_device_id
    ,t2.spreadname,t2.channel_name,t2.ss_utm_source,t2.ss_utm_medium
    ,row_number() over(partition by t1.user_id,t1.id order by t2.id desc) as rn
    from #source_session_app_temp1 t1
    left join #source_session_app_temp1 t2 on t1.user_id=t2.user_id and t1.id>=t2.id
    and (
        t2.spreadname is not null or t2.channel_name is not null 
        or t2.ss_utm_source is not null or t2.ss_utm_medium is not null 
    ) and t1.platform_type=t2.platform_type
)t where t.rn=1
;
                            
select user_id,max(SourceID) as max_sourceID
into #max_source_session
from DA_Tagging.v_events_media_session
group by user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Update Engagement Media Source Session Last Day Temp Start...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
                
select dt,user_id,ss_os,ss_device_id, event, time 
, case when platform_type in ('MiniProgram', 'mobile', 'web') then media else null end as ss_utm_source
, case when platform_type in ('MiniProgram', 'mobile', 'web') then ss_utm_medium else null end as ss_utm_medium
, case when platform_type = 'app' then media else null end as spreadname
, case when platform_type = 'app' then channel_name else null end as channel_name
, platform_type
, SourceID ,row_number() over (partition by user_id,sourceID order by time) ViewID
into #v_events_media_session_last_day
from(
    select user_id,event,time ,media,ss_utm_medium,channel_name,dt,ss_os,ss_device_id,platform_type
    ,SUM(flag) OVER (partition by user_id,dt order by time) AS sourceID
    from(
        select user_id,event,time ,media,ss_utm_medium,channel_name,dt,ss_os,ss_device_id,platform_type
        , case when  media<>last_media  then 1 else 0 end as flag
        from(
            select user_id,event,time 
            ,dt,ss_os,ss_device_id,ss_utm_medium,channel_name,platform_type
            ,media ,lag(media,1,0) over (partition by t1.user_id order by time) last_media
            from(
                    select user_id, event, time , ss_os, ss_device_id,platform_type
                    ,case when ss_utm_source is not null then ss_utm_source 
                    else spreadname collate Chinese_PRC_CS_AI_WS end as media
                    , ss_utm_source,ss_utm_medium, spreadname, channel_name, dt
                    from #source_session_app_temp2 t1 
                )t1 
            )tt1  
        )ttt1
    )tttt1
    ;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, insert Engagement Media Source Session Table Start...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
                                     
insert into DA_Tagging.v_events_media_session( dt,user_id,ss_os,ss_device_id, event, time , ss_utm_source,spreadname,channel_name,platform_type,SourceID,ViewID,ss_utm_medium)
select dt, t1.user_id, ss_os, ss_device_id , event, time 
, case when ss_utm_source='this_session_no_spreadname' then null else ss_utm_source end as ss_utm_source
, case when spreadname='this_session_no_spreadname' then null else spreadname end as spreadname
, case when channel_name='this_session_no_channel_name' then null else channel_name end as channel_name
, platform_type
, (case when t1.SourceID is null then 0 else t1.SourceID end)+ (case when t2.max_sourceID is null then 0 else t2.max_sourceID end) as SourceID
, ViewID,ss_utm_medium
from #v_events_media_session_last_day t1
left join #max_source_session t2 on t1.user_id=t2.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, insert Engagement Media Source Session Table End...',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
--====================================================--====================================================--====================================================

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [ad_click]',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

--广告点击次数
--PC/MOBLILE/MNP：90天内每个用户带media标记(ss_utm_source)的pageview个数，归因到每个pageview之前最晚的一个ss_utm_source
--APP：依据安卓id和iosid及click时间匹session表，计算90天内pageview个数，归因到每个pageview之前最晚的一个spreadname
-- 2min
-- 1209根据业务需求改为180天
update DA_Tagging.engagement2
set ad_click = t2.ad_click
from DA_Tagging.engagement2 t1
join(
    select user_id, count(0) as ad_click
    from DA_Tagging.v_events_media_session
    where ss_utm_source is not null or spreadname is not null
    and dt between convert(date,DATEADD(hour,8,getdate()) - 180)  and convert(date,DATEADD(hour,8,getdate()) - 1) 
    and event in ('$AppViewScreen', '$MPViewScreen', '$pageview')
    group by user_id
)t2 on t1.sensor_user_id= t2.user_id 
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [average_visited_category]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;

-- 65.平均每次浏览的大类数量
/*
取90天内event = ‘viewCommodityDetail’的op_code；op_code IS NOT NULL
通过op_code和product_id,匹配出category,计算每个用户浏览的category平均数量
*/
/*
update DA_Tagging.engagement2
set average_visited_category = tt.average_visited_category
from DA_Tagging.engagement2 t1
join(
	select user_id, avg(category_cn)  as average_visited_category
	from(
		select user_id,sessionid, count(distinct category) as category_cn
		from(
			select user_id, sessionid, op_code, category
			from DA_Tagging.v_events_session 
			where event ='viewCommodityDetail' 
			and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
			and op_code is not null
			and isnumeric(op_code) =1
			)t1
		group by  user_id,sessionid
	)tt1 group by  user_id
)tt on t1.sensor_user_id=tt.user_id
;
*/

-- 改为平均每天浏览的大类数量
-- 1209根据业务需求改为180天
update DA_Tagging.engagement2
set average_visited_category = tt.average_visited_category
from DA_Tagging.engagement2 t1
join(
	select user_id, avg(category_cn)  as average_visited_category
	from(
		select user_id, dt, count(distinct category) as category_cn
		from(
			select user_id, dt, op_code, category
			from DA_Tagging.v_events_session 
			where event ='viewCommodityDetail' 
			and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
			and op_code is not null
			and isnumeric(op_code) =1
			)t1
		group by  user_id,dt
	)tt1 group by  user_id
)tt on t1.sensor_user_id=tt.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [average_decision_time]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
/* 475.平均决策时间： 
da_dev.tagging_system_v_events_session中的event ，dt
计算每个用户，event中一个session开始到event = ‘submitOrder’的平均时间差 
*/
-- 1209根据业务需求改成180天
--6min
update DA_Tagging.engagement2
set average_decision_time = tt.average_decision_time 
from DA_Tagging.engagement2 t1
join(
	select user_id, abs(avg(des_time)) as average_decision_time
	from(
		select t1.user_id, t1.sessionid,start_time,des_time as decd_time
		,datediff(ss,start_time,des_time)/60.0 as des_time
		from(
			select distinct user_id,sessionid,time as des_time,dt
			from DA_Tagging.v_events_session
			where event='submitOrder' 
			and  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		)t1
		inner join (
			select user_id,sessionid, seqid,time as start_time,dt
			from DA_Tagging.v_events_session
			where seqid=1 
			and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		)t2 on t1.user_id=t2.user_id and t1.sessionid=t2.sessionid and t1.dt = t2.dt
	)tt1 group by  user_id
)tt on t1.sensor_user_id=tt.user_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [average_session_before_purchase]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 476.平均购买前session个数:取90天内，相邻两个event='submitOrder'之间的session个数
-- 输出字段：[user_id],[session_difference_avg]
-- 注：每两个event，用time做前后标记
-- 6 min
-- 1209根据业务需求改成180天
update [DA_Tagging].[engagement2]
set average_session_before_purchase = tt.session_diff_avg 
from DA_Tagging.engagement2 t1
join(
	select user_id, avg(session_diff) as session_diff_avg
	from(
		select user_id,(sessionid - last_sessionid) as session_diff,sessionid,last_sessionid,time
		from(
			select user_id,sessionid,time,
				   lag(sessionid,1,null)over(partition by user_id,platform_type order by time) last_sessionid	
			from DA_Tagging.v_events_session
			where dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
			and event = 'submitOrder' 
			) t1 where last_sessionid IS NOT NULL
	) tt1 where session_diff >= 0
	group by  user_id 
)tt on t1.sensor_user_id=tt.user_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [average_visited_product_before_purchase]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 477.平均购买前访问产品个数:取90天内，相邻两个event='submitOrder'之间的op_code个数
-- 输出字段：[user_id],[product_difference_avg]
-- 注：每两个event，用time做前后标记
-- 7min
-- 1209根据业务需求改成180天
update DA_Tagging.engagement2
set average_visited_product_before_purchase = tttt.average_visited_product_before_purchase
from  DA_Tagging.engagement2 t1
join(
	select user_id, vist_cnt/(case when order_cnt<>0 then order_cnt else null end) as average_visited_product_before_purchase
	from(
		select user_id
		, count(distinct orderid) as  order_cnt 
		, count(distinct op_code) as vist_cnt
		from(
			select user_id, event ,op_code ,orderid
			from DA_Tagging.v_events_session
			where dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
			and ((event ='viewCommodityDetail' and op_code is not null)
			or (event ='submitOrder' and orderid is not null))
		)tt
		group by  user_id
	)ttt
)tttt on t1.sensor_user_id = tttt.user_id 
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [product_vist]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 484.浏览产品个数
/*
筛选
取90天内event = ‘viewCommodityDetail’的op_code；且op_code IS NOT NULL
数据源：[DA_Tagging].[v_events_session]  -- event_session表
*/
-- 1209根据业务需求改为180天
-- 6 min
update DA_Tagging.engagement2
set product_vist = tt.product_vist
from DA_Tagging.engagement2 t1
join(
	select user_id,count(distinct op_code) as product_vist
	from(
		select user_id,op_code
		from DA_Tagging.v_events_session 
		where dt between convert(date,getdate() -180) and convert(date,getdate() -1) 
		and event ='viewCommodityDetail' and op_code is not null
		)tt
	group by  user_id
)tt  on t1.sensor_user_id = tt.user_id 
;



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [beautyin_score]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 489.美印积分：取每个用户最新的GranuleCount
/** 
逻辑：
1. 创建虚拟表：包含字段[user_id],[GranuleCount],[RN]—— 使用开窗函数对insert_time进行排序，获得新列【排名】			   
3. 在虚拟表的基础上，筛选出每位用户对应的排名第一的[GranuleCount]
**/ 
--已update
--1.5min
 update DA_Tagging.engagement2
set beautyin_score = tt.GranuleCount
from DA_Tagging.engagement2 t1
join(
	select UserId,GranuleCount
	from ODS_BEA.Beauty_Userfortune as a
	where Update_Time = (select max(Update_Time) from ODS_BEA.Beauty_Userfortune where UserId = a.UserId )
)tt on t1.sephora_user_id=tt.UserId
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [beautyin_level]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 490.美印等级：取每个用户最新的BeautyLevelId
/** 
逻辑：
1. 创建虚拟表：包含字段[user_id],[BeautyLevelId],[RN]—— 使用开窗函数对帖子数[BeautyLevelId]进行排序，获得新列【排名】			   
3. 在虚拟表的基础上，筛选出每位用户对应的排名第一的[BeautyLevelId]
**/ 
--30s
update DA_Tagging.engagement2
set beautyin_level = tt.BeautyLevelId
from DA_Tagging.engagement2 t1
join(
	select UserId, BeautyLevelId
	from ODS_BEA.Beauty_Userprofile as a
	where UpdateTime = (select max(UpdateTime) from ODS_BEA.Beauty_Userprofile where UserId = a.UserId )
)tt on t1.sephora_user_id=tt.UserId
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [beautyin_post]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 492.美印发帖次数：取每个用户的PostsCount
--1min
update DA_Tagging.engagement2
set beautyin_post = tt.beautyin_post
from  DA_Tagging.engagement2 t1
join(
       select user_id,count(distinct post_id) as beautyin_post
		from ODS_BEA.Beauty_Send_Timeline
		--where convert(date,create_time) between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		group by  user_id
)tt on t1.sephora_user_id=tt.user_id
;

select top 10 * from ODS_BEA.Beauty_Send_Timeline



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [campaign_type_detail_preference]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 495.访问的活动类型细分偏好:计算每个用户90天内数量最多的活动类型细分，以时间判断活动类型细分
-- 注：思路与上方一致，仅需将T0表钟，活动类型调整为细分类型
--1 min
IF OBJECT_ID('tempdb..#campaign_type_detail_preference','U')  IS NOT NULL
drop table #campaign_type_detail_preference;
create table #campaign_type_detail_preference
(	
    user_id bigint ,
	campaign_type_detail_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #campaign_type_detail_preference(user_id,campaign_type_detail_preference)
select user_id,Campaign_Detail as campaign_type_detail_preference
	from(
		select user_id,Campaign_Detail
		,row_number() over (partition by user_id order by campaign_engaged desc) rn
		from(
			select user_id,Campaign_Detail,count(distinct dt) as campaign_engaged
			from [DA_Tagging].[v_events_campaign_P90d]
			group by user_id,Campaign_Detail
		)t1
	)tt1
	where rn=1


update DA_Tagging.engagement2
set campaign_type_detail_preference = tt.campaign_type_detail_preference 
from  DA_Tagging.engagement2 t1
join #campaign_type_detail_preference tt on t1.sensor_user_id=tt.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [campaign_channel_preference]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 499.活动期间访问渠道偏好：计算90天内的活动期间内每个用户dwd.v_events中访问最多的platform_type
/*
虚拟表1：筛选出符合筛选条件的行，包含字段：user_id,platform_type,platform_type_count
虚拟表2：ROW_NUMBER函数获得排名
在虚拟表2的基础上，筛选出排名=1的记录
**/ 
--1min
IF OBJECT_ID('tempdb..#campaign_channel_preference','U')  IS NOT NULL
drop table #campaign_channel_preference;
create table #campaign_channel_preference
(	
    user_id bigint ,
	campaign_channel_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #campaign_channel_preference(user_id,campaign_channel_preference)

select user_id,Platform as campaign_channel_preference
	from(
		select user_id,Platform
		,row_number() over (partition by user_id order by campaign_engaged desc) rn
		from(
			select user_id,Platform,count(distinct dt) as campaign_engaged
			from [DA_Tagging].[v_events_campaign_P90d]
			group by user_id,Platform
		)t1
	)tt1 where rn=1

update DA_Tagging.engagement2
set campaign_channel_preference = tt.campaign_channel_preference 
from  DA_Tagging.engagement2 t1
join #campaign_channel_preference tt on t1.sensor_user_id=tt.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [campaign_period_preference] temp',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 500.活动期间访问时间段偏好：计算90天内的活动期间内每个用户dwd.v_events中 访问 最多的时间段
-- time 字段需要转化一下格式
-- 1min
IF OBJECT_ID('tempdb..#v_events_hour_preference_campaign','U')  IS NOT NULL
drop table #v_events_hour_preference_campaign;
create table #v_events_hour_preference_campaign
(	
    user_id bigint ,
	campaign_period_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #v_events_hour_preference_campaign(user_id, campaign_period_preference)
select user_id,visit_hour as campaign_period_preference
	from(
		select user_id,visit_hour
		,row_number() over (partition by user_id order by campaign_engaged desc) rn
		from(
			select user_id, visit_hour,count(0) as campaign_engaged
			from [DA_Tagging].[v_events_campaign_P90d]
			group by user_id,visit_hour
		)t1
	)tt1 where rn=1
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [campaign_period_preference]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
update DA_Tagging.engagement2
set campaign_period_preference = tt.campaign_period_preference 
from  DA_Tagging.engagement2 t1
join #v_events_hour_preference_campaign tt on t1.sensor_user_id=tt.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Campaign Period Preference format',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
--3min
update DA_Tagging.engagement2
set campaign_period_preference =  
		case campaign_period_preference when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
	when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
	when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
	when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
	when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' else campaign_period_preference  end
from DA_Tagging.engagement2 t1
;



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [media_resource_preference]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 501.访问的投放渠道偏好
/* 细节要求
数据源：dwd.v_events；[Tb_IOS_Click_Arrange]；[Tb_android_Click_Arrange]；DA_Tagging.coding_media_source
ss_utm_source,spreadname，
(platform_type=‘APP’,event='$AppViewScreen'）
（platform_type=‘MiniProgram’,event='$MPViewScreen'）
（platform_type=‘mobile’,event='$pageview'）
（platform_type='web',event='$pageview'）*/

select user_id,spreadname as resource,count(0) as resource_count
into #app_resource_count
from DA_Tagging.v_events_media_session
where  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
and platform_type='app' and event='$AppViewScreen'
and spreadname is not null
group by  user_id,spreadname

;
select user_id,channel as resource ,count(0) as resource_count
into #noapp_resource_count
from(
    select user_id,ss_utm_medium from DA_Tagging.v_events_media_session
    where  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
    and ((platform_type='MiniProgram' and event='$MPViewScreen') or (platform_type='mobile' and event='$pageview') or (platform_type = 'web' and event = '$pageview'))
)t1 left join  DA_Tagging.coding_media_source t2 on t1.ss_utm_medium = T2.[Medium]
where channel is not null
group by  user_id,channel

;
update DA_Tagging.engagement2
set [media_resource_preference] = tt.media_resource_preference 
from DA_Tagging.engagement2 t1
join(
	select user_id,media_resource_preference 
	from(
		select user_id,resource as media_resource_preference 
		,row_number() over(partition by user_id order by resource_count desc) rn
		from(
			select user_id,resource,resource_count from #app_resource_count
			union 
			select user_id,resource,resource_count from #noapp_resource_count
		)t1
	)tt1 where rn=1
)tt on t1.sensor_user_id = tt.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Media Medium Preference',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 502.访问的投放媒介偏好
/*
PC/MOBLILE/MNP：计算每个用户90天内访问最多的媒介，（PC/H5用mapping表匹配出的Medium,MNP用mapping表匹配出的Source)
APP:计算每个用户90天内点击最多的channel，归因到每个pageview之前最晚的一个channel
*/
--3min
--- app $AppViewScreen 的 channel_name temp
select user_id,channel_name as [medium],count(0) as [medium_count]
into #app_medium_cnt
from DA_Tagging.v_events_media_session
where  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
and platform_type='app' and channel_name is not null and event='$AppViewScreen'
group by  user_id,channel_name

;
-- pc_mobile $pageview 的 Medium temp
select user_id,[medium],count(0) as [medium_count]
into #pc_mobile_medium_cnt
from(
    select user_id,ss_utm_medium from DA_Tagging.v_events_media_session
    where  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
	and platform_type in ('web','mobile') and event = '$pageview'
)t1 left join  DA_Tagging.coding_media_source t2 on t1.ss_utm_medium = T2.[Medium]
where channel is not null
group by  user_id,medium
;

-- mnp $MPViewScreen的 source temp
select user_id,source as [medium] ,count(0) as [medium_count]
into #mnp_medium_cnt
from(
    select user_id,ss_utm_source from DA_Tagging.v_events_media_session
    where  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
    and platform_type='MiniProgram' and event='$MPViewScreen'
)t1 left join  DA_Tagging.coding_media_source t2 on t1.ss_utm_source = T2.[source]
where [source] is not null
group by  user_id,[source]
;

update DA_Tagging.engagement2
set [media_medium_preference] = tt.media_medium_preference 
from DA_Tagging.engagement2 t1
join(
	  select user_id,media_medium_preference 
	  from(
			select user_id,medium as  media_medium_preference 
			,row_number() over (partition by user_id order by medium_count desc) rn
			from(
				select user_id,medium ,medium_count from #app_medium_cnt
				union 
				select user_id,medium ,medium_count from  #pc_mobile_medium_cnt
				union 
				select user_id,medium ,medium_count from #mnp_medium_cnt
			)t1
		)tt1 where rn=1
)tt on t1.sensor_user_id = tt.user_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Media Period Preference',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 503.访问的投放时段偏好
/*
PC/MOBLILE/MNP：计算每个用户90天内最多访问的有ss_utm_source及ss_utm_medium这两列内容的dt时段，归因到最晚的一个的ss_utm_source及ss_utm_medium
APP:计算每个用户90天内clicktime的最多的时段分布：归因到最晚的一个的spreadname及channel
*/
-- 1min
IF OBJECT_ID('tempdb..#v_events_hour_preference_media','U')  IS NOT NULL
drop table #v_events_hour_preference_media;
create table #v_events_hour_preference_media
(	
	user_id bigint ,
	media_period_preference nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #v_events_hour_preference_media(user_id, media_period_preference)
select user_id, media_period_preference
from(
	select user_id, case media_period_preference when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
    when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
    when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
    when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
    when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' else media_period_preference  end as media_period_preference
	,row_number() over (partition by user_id order by media_visit desc) rn
	from(
		select user_id, datename(hour,time) as media_period_preference ,count(0) as media_visit
		from DA_Tagging.v_events_media_session
		where (ss_utm_source is not null or spreadname is not null)
			and event in ('$AppViewScreen', '$MPViewScreen', '$pageview','viewCommodityDetail')
			and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		group by user_id, datename(hour,time)
		)t1
)tt1 where rn=1


update DA_Tagging.engagement2
set [media_period_preference] = tt.media_period_preference 
from DA_Tagging.engagement2 t1
join #v_events_hour_preference_media tt on t1.sensor_user_id = tt.user_id
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Media Linked App Visit',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 505.投放导致的APP访问次数 
/*
内容：依据安卓id和iosid及click时间匹event表，计算90天内的pageview个数
归因到每个pageview之前最晚的一个的spreadname及channel
*/
-- 5min
update DA_Tagging.engagement2
set [media_linked_app_visit] = tt.[media_linked_app_visit] 
from DA_Tagging.engagement2 t1
join(
    select user_id,count(0) as [media_linked_app_visit]
    from DA_Tagging.v_events_media_session
    where dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
    and platform_type='app' and event='$AppViewScreen'
    and (channel_name is not null or spreadname is not null)
    group by  user_id
)tt on t1.sensor_user_id=tt.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Media Linked PC Moblile Mnp Visit',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 506.投放导致的其他渠道访问次数
-- platform_type in ('web','MiniProgram','mobile') ：计算每个用户90天内ss_utm_source，ss_utm_medium不为空的pageview个数
-- 归因到每个pageview之前最晚的一个的ss_utm_source及ss_utm_medium
--5min
update DA_Tagging.engagement2
set media_linked_pc_moblile_mnp_visit = tt.media_linked_pc_mobile_mnp_visit
from DA_Tagging.engagement2 t1
join(
select user_id,count(0) as media_linked_pc_mobile_mnp_visit
    from DA_Tagging.v_events_media_session
    where  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
    and event in ('$MPViewScreen', '$pageview')
    and (ss_utm_source is not null or ss_utm_medium is not null)
    group by  user_id
)tt on t1.sensor_user_id=tt.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Media Linked App Product Click',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 507.投放导致的APP产品点击次数
/*
依据androidid和iosid及click时间匹event表，
计算90天内同一个event里面有‘viewCommodityDetail’的个数，
归因到每个‘viewCommodityDetail’之前最晚的一个spreadname/channel
*/
-- 1min 
update DA_Tagging.engagement2
set media_linked_app_product_click = tt.media_linked_app_product_click
from DA_Tagging.engagement2 t1
join(
    select user_id,count(0) as [media_linked_app_product_click]
    from DA_Tagging.v_events_media_session
    where  dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
    and platform_type='app' and event='viewCommodityDetail'
    and (channel_name is not null or spreadname is not null)
    group by  user_id
)tt on t1.sensor_user_id=tt.user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Media Linked PC Moblile Mnp Product Click',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 508.投放导致的其他渠道产品点击次数
/*
计算每个用户90天内do_utm_source，do_utm_medium不为空，
platform_type in ('web','MiniProgram','mobile') 的
且event = ‘viewCommodityDetail’次数，
归因到每个‘viewCommodityDetail’之前最晚的一个ss_utm_source及ss_utm_medium
*/
-- 1 min
update DA_Tagging.engagement2
set media_linked_pc_moblile_mnp_product_click = tt.media_linked_pc_moblile_mnp_product_click
from DA_Tagging.engagement2 t1
join(
    select user_id,count(0) as media_linked_pc_moblile_mnp_product_click
    from DA_Tagging.v_events_media_session
    where  time between CONVERT(varchar(100),dateadd(day,-180,GETDATE())) and CONVERT(varchar(100),GETDATE())
    and platform_type in ('MiniProgram','mobile','web') and event='viewCommodityDetail'
    and (ss_utm_source is not null or ss_utm_medium is not null)
    group by  user_id
)tt on t1.sensor_user_id=tt.user_id
;



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Group Type',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 720新增.群类型：找到每个人(unionid) join_time最晚的一条记录的channel_name
-- 720新增.群名称：找到每个人(unionid) join_time最晚的一条记录的chat_name
-- 720新增.是否入群：计算unionid是否在这张表出现，出现则为入群，否则为未入群
 
IF OBJECT_ID('tempdb..#group_type','U')  IS NOT NULL
drop table #group_type;
create table #group_type
(	
    unionid nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    last_join_time datetime,
	group_type nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	group_name nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	join_group int
)
insert into #group_type(unionid,last_join_time,group_type,group_name,join_group)
select unionid
	,join_time as last_join_time
	,channel_name as group_type
	,chat_name as group_name
	,1 as join_group
from [STG_SmartBA].[T_WXChat_Sale] as a
where join_time = ( 
	select max(join_time) from [STG_SmartBA].[T_WXChat_Sale] where unionid = a.unionid )
;

update DA_Tagging.engagement2
set join_group = tt.join_group
	,group_type = tt.group_type
	,group_name = tt.group_name
from  DA_Tagging.engagement2 t1
join #group_type tt on t1.wechat_union_id = tt.unionid
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Binding Number',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 510. BA企业微信绑定人数：计算绑定人数
--1min

IF OBJECT_ID('tempdb..#binding_number','U')  IS NOT NULL
drop table #binding_number;
create table #binding_number
(	
    unionid nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    binding_number int
)
insert into #binding_number(unionid,binding_number)
select unionid,count(distinct staff_no) as binding_number 
from [STG_SmartBA].[Customer_Staff_REL]
group by unionid


update DA_Tagging.engagement2
set [binding_number] = tt.binding_number 
from DA_Tagging.engagement2 t1
join #binding_number tt on t1.wechat_union_id = tt.unionid
;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [beautyin_most_visited_topic] temp',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 487.最常浏览的美印主题:计算每个用户90天内behavior不为空的主题数量，选取数量最多的主题
-- 源数据表：ODS_BEA.Beauty_Behavior_Post,ODS_BEA.Beauty_Send_Timeline
-- 输出字段：[user_id],[post_id_count],[topics]
/** 
逻辑：
创建虚拟表1：对[topics]列进行分列处理
创建虚拟表2：RIGHT JOIN 表格：ODS_BEA.Beauty_Behavior_Post,包含字段[user_id]、[topics]、[post_id_count],
时间限制：近90天
[topics] IS NOT NULL
[behavior] IS NOT NULL
创建虚拟表3：在虚拟表2的基础上，使用开窗函数ROW_NUMBER()对帖子数[post_id_count]进行排序，获得新列【排名】
在虚拟表3的基础上，筛选出每位用户对应的排名第一的主题
**/
-- 6 min
IF OBJECT_ID('tempdb..#v_events_beautyin_topic','U')  IS NOT NULL
drop table #v_events_beautyin_topic;
create table #v_events_beautyin_topic
(
    user_id bigint,
	beautyin_most_visited_topic nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #v_events_beautyin_topic(user_id, beautyin_most_visited_topic)
select user_id,topics as beautyin_most_visited_topic
	from(
		select user_id,topics
		,row_number() over (partition by user_id order by visit_topic_cn desc) rn
		from(
			select user_id, t2.topics, count(0) as visit_topic_cn
			from(
				select user_id, beauty_article_id  as post_id
				from STG_Sensor.V_Events 
				where dt between convert(date,getdate() -180) and convert(date,getdate() -1) 
				and event='beautyIN_blog_view' 
				and beauty_article_id is not null and  beauty_article_id not like N'%[吖-座]%'
				
			)t1
			inner join(
					select post_id
					, replace(replace(replace(replace(value,'{',''),'''',''),'#',''),'}','') as topics
					from ODS_BEA.Beauty_Send_Timeline
					OUTER APPLY  String_Split(topics, ',') 
					where topics is not null
			)t2 on t1.post_id = t2.post_id collate Chinese_PRC_CS_AI_WS
			group by  user_id,t2.topics
		)tt1
	)ttt1 where rn=1
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [beautyin_most_visited_topic]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;

update DA_Tagging.engagement2
set [beautyin_most_visited_topic] = tt.beautyin_most_visited_topic 
from DA_Tagging.engagement2 t1
join #v_events_beautyin_topic tt on t1.sensor_user_id=tt.user_id

;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Beautyin most posted topic temp',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 488.最常发帖的美印主题:计算每个用户90天内发帖数量最多的topics
-- 输出字段：[user_id],[post_id_count],[topics]
/** 
逻辑：
1. 创建虚拟表1：包含字段[user_id]、[topics]、[post_id_count],
                时间限制：近90天
                [topic] 做分列处理后，[topic] IS NOT NULL
2. 创建虚拟表2：在虚拟表1的基础上，使用开窗函数对帖子数[post_id_count]进行排序，获得新列【排名】
3. 在虚拟表2的基础上，筛选出每位用户对应的排名第一的主题
**/ 
IF OBJECT_ID('tempdb..#v_events_posted_topic','U')  IS NOT NULL
drop table #v_events_posted_topic;
create table #v_events_posted_topic
(
    user_id bigint,
	beautyin_most_posted_topic nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #v_events_posted_topic(user_id, beautyin_most_posted_topic)
select user_id, topics as beautyin_most_posted_topic
	from(
		select user_id, topics
		,row_number() over(partition by user_id order by send_cn desc) rn
		from(
			select user_id, topics,count(0) as send_cn
			from(
				select user_id
				,replace(replace(replace(replace(value,'{',''),'''',''),'#',''),'}','') as topics
				from ODS_BEA.Beauty_Send_Timeline
				OUTER APPLY  String_Split(topics, ',')
				where  update_time  between convert(date,getdate() -180) and convert(date,getdate() -1) 
				and topics is not null
			)t1
			group by  user_id, topics
		)tt1
	)ttt1 where rn=1

;


insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Beautyin most posted topic',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;

update DA_Tagging.engagement2
set beautyin_most_posted_topic = tt.beautyin_most_posted_topic 
from DA_Tagging.engagement2 t1
join #v_events_posted_topic tt on t1.sephora_user_id=tt.user_id
;



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement [visit_pattern]',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
update DA_Tagging.engagement2
set visit_pattern = tt.vist_pattern
from DA_Tagging.engagement2 t1
join(
    select sensor_user_id
    , case when product_vist=N'低' and average_visited=N'低' and avg_uv_value=N'低' then 'Low-Active User'
        when product_vist=N'低' and average_visited=N'低' and avg_uv_value=N'高' then 'Direct Buyer'
        when product_vist=N'高' and average_visited=N'低' and avg_uv_value=N'高' then 'Buyer'
        when product_vist=N'高' and average_visited=N'高' and avg_uv_value=N'低' then 'Explorer'
        when product_vist=N'高' and average_visited=N'高' and avg_uv_value=N'高' then 'Loyalty User' end as vist_pattern
    from(
        select sensor_user_id
        , case when product_vist >= avg_product_vist then N'高'  when  product_vist < avg_product_vist or product_vist is null then N'低' end as product_vist
        , case when uv_value >= avg_uv_value then N'高'  when  uv_value < avg_uv_value or uv_value is null then N'低' end as avg_uv_value
        , case when average_visited >= avg_avg_visited then N'高'  when  average_visited < avg_avg_visited or average_visited is null then N'低' end as average_visited
        from(
            select sensor_user_id, product_vist, uv_value
            , average_visited_product_before_purchase  as average_visited  
            from DA_Tagging.engagement2
            where product_vist <>0 or uv_value <>0 or average_visited_product_before_purchase <>0
        )t1
        cross join(
            select avg(product_vist) as avg_product_vist
            , avg(uv_value) as avg_uv_value
            , avg(average_visited_product_before_purchase) as avg_avg_visited
            from DA_Tagging.engagement2
			--where product_vist <>0 or uv_value <>0 or average_visited_product_before_purchase <>0
        )tt
    )ttt
)tt on t1.sensor_user_id = tt.sensor_user_id
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Unmet Brand & Category & Function',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;
-- 481.搜索未购买品牌   -- 这个只能先套到master_id
/*筛选
（platform_type ='app',event='clickBanner_App_Mob'，
platform_type ='MiniProgram',event='clickBanner_MP'，
platform_type ='web',event='clickBanner_web'，
platform_type ='mobile',event='clickBanner_App_Mob'，)  
banner_belong_area='searchview',
用banner_content匹配[DA_Tagging.coding_synonyms_match]中的Synoyms，得到对应name
并通过oms.v_oms_sales_order_sku_level_df表中的item_sku_cd匹配sku表中的brand，找到用户购买过的品牌，匹配出用户90天内搜索但未购买的品牌
*/
IF OBJECT_ID('tempdb..#v_events_order_sku_P90d','U')  IS NOT NULL
drop table #v_events_order_sku_P90d;
create table #v_events_order_sku_P90d
(
    sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	item_sku_cd nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	brand_name_cn nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	category nvarchar(255) collate Chinese_PRC_CS_AI_WS,
	[function] nvarchar(255) collate Chinese_PRC_CS_AI_WS
)
insert into #v_events_order_sku_P90d(sales_member_id,item_sku_cd,brand_name_cn,category,[function])
select sales_member_id,item_sku_cd,brand_name_cn,category,[function]
from(
	select distinct sales_member_id,item_sku_cd
	from DA_Tagging.sales_order_vb_temp
	where convert(date,place_time) between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1) 
)t1 left join (
		select distinct sku_cd,value as [function],category,brand_name_cn
		from(
			select distinct sku_cd,brand_name_cn,level1_name as category
			,case when att_47 is not null then att_47 else att_78 end as [function]
			from [DW_Product].[V_SKU_Profile] where att_47 is not null or att_78 is not null
			)t CROSS APPLY  String_Split([function], ',')  
	)t2 on t1.item_sku_cd COLLATE SQL_Latin1_General_CP1_CI_AS =t2.sku_cd
;


update DA_Tagging.engagement2
set  unmet_brand_needs = case when tt.brand<>t2.most_searched_brand then t2.most_searched_brand else null end
	,unmet_category_needs = case when tt.category<>t2.most_searched_category then t2.most_searched_category else null end 
	,unmet_function_needs = case when tt.[function]<>t2.most_searched_function then t2.most_searched_function else null end  
from DA_Tagging.engagement2 t2
join(
	select sales_member_id,brand_name_cn as brand,category,[function]
	from #v_events_order_sku_P90d
)tt on t2.sephora_card_no = tt.sales_member_id 
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Delete Invaild Engagement Tag',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;



delete from DA_Tagging.engagement2 
where ad_click is null
and app_activation is null
and app_frequency is null
and average_decision_time is null
and average_session_before_purchase is null
and average_visited_category is null
and average_visited_product_before_purchase is null
and beautyin_level is null
and beautyin_most_posted_topic is null
and beautyin_most_visited_topic is null
and beautyin_post is null
and beautyin_score is null
and beautyin_visit is null
and binding_number is null
and campaign_channel_preference is null
and campaign_engaged is null
and campaign_page_avg_stay_time is null
and campaign_period_preference is null
and campaign_product_click is null
and campaign_type_detail_preference is null
and campaign_type_preference is null
and campaign_visit is null
and conversion_probabilty is null
and group_name is null
and group_type is null
and holiday_preference is null
and join_group is null
and media_linked_app_product_click is null
and media_linked_app_visit is null
and media_linked_pc_moblile_mnp_product_click is null
and media_linked_pc_moblile_mnp_visit is null
and media_medium_preference is null
and media_period_preference is null
and media_preference is null
and media_resource_preference is null
and mnp_frequency is null
and mobile_frequency is null
and most_searched_brand is null
and most_searched_category is null
and most_searched_function is null
and private_sale_preference is null
and product_vist is null
and season_preference is null
and unmet_brand_needs is null
and unmet_category_needs is null
and unmet_function_needs is null
and uv_value is null
and visit_pattern is null
and web_frequency is null
;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'Engagement','Tagging System Engagement, Generate Engagement Tag End',dateadd(hour,8,getdate()),dateadd(hour,8,getdate())
;


END
GO
