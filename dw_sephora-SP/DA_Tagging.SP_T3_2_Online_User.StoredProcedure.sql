/****** Object:  StoredProcedure [DA_Tagging].[SP_T3_2_Online_User]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T3_2_Online_User] AS
BEGIN


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','online user start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

-- online user 

/* hive-> sql sever代码迁移记录
周刷新数据：age age_group gender province city district constellation 
           user_registered_date user_tenure_days latest_online_purchase_card_type
1.string                               -->  nvarchar(255)
2.dwd.v_events                         -->  [STG_EDW].[v_ubt_events] 
3.oms.v_user_profile                   -->  [STG_EDW].[v_user_profile]
4.dwd.v_user_info                      -->  SUM_EDW.v_user_info
5.oms.v_user_card                      -->  STG_User.V_Card
6.datediff(current_date,register_date) -->  datediff(day,convert(date,DATEADD(hour,8,getdate())),register_date)
7.year(current_date)-year(dateofbirth) as age,month(dateofbirth) --> datediff(year,convert(date,DATEADD(hour,8,getdate())),dateofbirth)
8."Offline" --> 'Offline'
9.dt between convert(date,DATEADD(hour,8,getdate()) - 7) and convert(date,DATEADD(hour,8,getdate()) - 1) 
10.IF OBJECT_ID('tempdb..#TempName') IS NOT NULL DROP TABLE #TempName; 
11.IF OBJECT_ID('DA_Tagging.online_user_login_city','U') IS NOT NULL 
*/
--------------------------------------------------------------------------------------------------
--4423088条数据 1min
/* online user id insert into result table
master_id bigint,
sales_member_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
sephora_user_id bigint,
sensor_id bigint,
sephora_card_no nvarchar(255) collate Chinese_PRC_CS_AI_WS,
province nvarchar(255) collate Chinese_PRC_CS_AI_WS,
city nvarchar(255) collate Chinese_PRC_CS_AI_WS,
district nvarchar(255) collate Chinese_PRC_CS_AI_WS,
age int,
age_group nvarchar(255) collate Chinese_PRC_CS_AI_WS,
gender nvarchar(255) collate Chinese_PRC_CS_AI_WS,
constellation nvarchar(255) collate Chinese_PRC_CS_AI_WS,
user_registered_date nvarchar(255) collate Chinese_PRC_CS_AI_WS,
user_tenure_days int,
latest_online_purchase_card_type nvarchar(255) collate Chinese_PRC_CS_AI_WS,
registered_user_status nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_customer_status nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_store_status_dragon nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_store_status_tmall nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_store_status_jd nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_store_status_red nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_channel_status_app nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_channel_status_mnp nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_channel_status_sephora_tmall nvarchar(255) collate Chinese_PRC_CS_AI_WS,
eb_channel_status_tmall_wei_tmall nvarchar(255) collate Chinese_PRC_CS_AI_WS,
dragon_registered_category nvarchar(255) collate Chinese_PRC_CS_AI_WS
*/

--------------------------------------------------------------------------------------------------

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','Tagging System Online User Update, create result table Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

TRUNCATE TABLE  DA_Tagging.online_user
-- go
insert into DA_Tagging.online_user(master_id,sales_member_id,sephora_user_id,sensor_id,sephora_card_no)
select t1.master_id, t2.sales_member_id, t1.sephora_user_id, t1.sensor_id, t1.sephora_card_no
from(
  select master_id, sephora_user_id, sensor_id, sephora_card_no
  from DA_Tagging.id_mapping
  where invalid_date='9999-12-31' 
)t1
left outer join DA_Tagging.sales_id_mapping t2 on t1.master_id=t2.master_id
where sephora_user_id is not null or sensor_id  is not null 
or sephora_card_no is not null or sales_member_id is not null

/* ############ ############ ############ Weekly Update OnlineUser Tag ############ ############ ############ 
[user_registered_date]				// 丝芙兰官网注册日期
[user_tenure_days]					// 丝芙兰官网注册用户持有天数
[latest_online_purchase_card_type]	// 最后一次线上购买时会员等级
[age]								// 用户年龄
[age_group]							// 用户年龄区间
[constellation]						// 用户星座
[gender]							// 用户性别
[province]							// 用户常住省份
[city]								// 用户常住城市名
[district]							// 用户常住行政区名
*/

DECLARE @WeekNum VARCHAR(50)= datename(weekday, DATEADD(hour,8,getdate()))
if @WeekNum='Saturday'  -- Sunday
begin 
		--108045 条数据 20s
		----订单表中用户订单的城市 跑通
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_2','Tagging System Online User Update, update city as order city Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

		-- go
		update DA_Tagging.tagging_weekly
		set  city = tt2.city
		   ,district = tt2.district
		from DA_Tagging.tagging_weekly tt1
		join(
		select sales_member_id,city,district
		from(
		   select sales_member_id,city,district,row_number() over(partition by sales_member_id order by sales desc) as rn
		   from(
			   select sales_member_id,city,district,sum(product_amount) as sales
				   from DA_Tagging.sales_order_basic_temp
				   group by sales_member_id,city,district
			   )t1 
		   )tt1 where rn=1
		)tt2 on tt1.sales_member_id=tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
		-- go

		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_2','Tagging System Online User Update, update city as login city Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		-- go

		-- events表中 最近三十天登录最多的城市 跑起来很慢 是否换成V_Sensor_User_Province
		;
		TRUNCATE TABLE  DA_Tagging.ss_city
		insert into DA_Tagging.ss_city(master_id,sensor_user_id ,city,province,update_date)
		select master_id,ss_user_id as sensor_user_id ,ss_city as city
		,ss_province as province,convert(date ,ss_time) as update_date
		from DW_Sensor.v_sensor_user_province t1
		join (
				select * from DA_Tagging.id_mapping 
				where invalid_date='9999-12-31' and master_id<>0
		) t2 on t1.ss_user_id=t2.sensor_id


		-- 测试环境 516009 条数据 2min
		-- 正式环境 27030001 条数据 5min
		-- 用户注册城市 注册表无数据
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_2','Tagging System Online User Update, update city as register city Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		-- go
		update DA_Tagging.tagging_weekly
		set  city = tt2.city
		from DA_Tagging.tagging_weekly tt1
		join (
		  select distinct user_id,city
		  from STG_User.V_User_Profile
		  where city is not null) tt2
		on tt1.sephora_user_id = tt2.user_id
		where tt1.city is null

		--4423088条数据 2min
		-- 用户城市名标准化  跑通
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_2','Tagging System Online User Update, update city as standard cityname Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		-- go
		update DA_Tagging.tagging_weekly
		set  city = t2.standardcityname
		  ,district = t3.standarddistrictname
		  ,province = t4.province
		from DA_Tagging.tagging_weekly t1
		left outer join(
			select originalcityname,standardcityname 
			from DA_Tagging.city 
			where standardcityname<>'error' and originalcityname<>''
		)t2 on t1.city=t2.originalcityname collate Chinese_PRC_CS_AI_WS
		left outer join(
			select distinct originaldistrictname,standarddistrictname from DA_Tagging.coding_district
			where standarddistrictname<>'error' and standarddistrictname is not null and originaldistrictname<>''
		)t3 on t1.district=t3.originaldistrictname collate Chinese_PRC_CS_AI_WS
		left outer join DA_Tagging.province_city t4 on t1.city = t4.city collate Chinese_PRC_CS_AI_WS 
		-- go


		---- 用户年龄            // age
		---- 用户年龄区间        // age_group
		---- 用户性别            // gender
		---- 用户星座            // constellation
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_2','Tagging System Online User Update, update age&agegroup&gender&constellation Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		-- go

		--update DA_Tagging.online_user --32904214条数据 6min
		--set age = case when t1.age between 1 and 120 then t1.age else null end
		--   ,age_group = case when t1.age <=10 or t1.age >=80 then N'[未知]'  when t1.age>10 and t1.age <18 then N'[18岁以下]'
		--       when t1.age >=18 and t1.age <=24 then N'[18,24]' when t1.age >=25 and t1.age <=29 then N'[25,29]' 
		--       when t1.age >=30 and t1.age <=34 then N'[30,34]' when t1.age >=35 and t1.age <=39 then N'[35,39]' 
		--       when t1.age >=40 and t1.age <80 then N'[40岁以上]' else null end
		--   ,gender = case when t1.gender='F' then N'女性' when t1.gender='M' then N'男性' else N'未知' end
		--   ,constellation = t2.constellation
		--from DA_Tagging.online_user tt1
		--join (
		--   select user_id,gender,month(dateofbirth) as birth_month
		--   ,dateofbirth, datediff(year,dateofbirth,convert(date,DATEADD(hour,8,getdate()))) as age
		--   ,day(dateofbirth) as birth_date from STG_User.V_User_Profile
		--   where isnumeric(user_id)=1 and user_id is not null
		--)t1 on tt1.sephora_user_id = t1.user_id 
		--left outer join [DA_Tagging].[constellation_cn] t2 on t1.birth_month=t2.birth_month and t1.birth_date=t2.birth_date
		-- go

		/** 20210913修改 匹配的字段null值较多,分两种情况**/
		--1. dateofbirth is null
		update DA_Tagging.tagging_weekly --29087111条数据 6min
		set gender = t1.gender
		from DA_Tagging.tagging_weekly tt1
		join (
		   select user_id,case when gender='F' then N'女性' when gender='M' then N'男性' else N'未知' end as gender
		   from STG_User.V_User_Profile
		   where isnumeric(user_id)=1 and user_id is not null and dateofbirth is null
		)t1 on tt1.sephora_user_id = t1.user_id 

		--2. dateofbirth is not null
		update DA_Tagging.tagging_weekly --7452596条数据 6min
		set age = case when t1.age between 1 and 120 then t1.age else null end
		   ,age_group = case when t1.age <=10 or t1.age >=80 then N'[未知]'  when t1.age>10 and t1.age <18 then N'[18岁以下]'
			   when t1.age >=18 and t1.age <=24 then N'[18,24]' when t1.age >=25 and t1.age <=29 then N'[25,29]' 
			   when t1.age >=30 and t1.age <=34 then N'[30,34]' when t1.age >=35 and t1.age <=39 then N'[35,39]' 
			   when t1.age >=40 and t1.age <80 then N'[40岁以上]' else null end
		   ,gender = t1.gender
		   ,constellation = t2.constellation
		from DA_Tagging.tagging_weekly tt1
		join (
		   select user_id,case when gender='F' then N'女性' when gender='M' then N'男性' else N'未知' end as gender
				 ,month(dateofbirth) as birth_month,dateofbirth, datediff(year,dateofbirth,convert(date,DATEADD(hour,8,getdate()))) as age,day(dateofbirth) as birth_date 
		   from STG_User.V_User_Profile
		   where isnumeric(user_id)=1 and user_id is not null and dateofbirth is not null
		)t1 on tt1.sephora_user_id = t1.user_id 
		left outer join [DA_Tagging].[constellation_cn] t2 on t1.birth_month=t2.birth_month and t1.birth_date=t2.birth_date

		-- 丝芙兰官网注册日期            // user_registered_date
		-- 丝芙兰官网注册用户持有天数     // user_tenure_days
		--正式环境 12837141条数据 3min
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_2','Tagging System Online User Update, update registered date Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		-- go
		update DA_Tagging.tagging_weekly
		set user_registered_date = tt2.register_date
		   ,user_tenure_days = tt2.tenure_days
		from DA_Tagging.tagging_weekly tt1
		join(
		   select user_id,card_no,register_date,datediff(day,register_date,convert(date,DATEADD(hour,8,getdate()))) as tenure_days
		   from (
			   select user_id,t2.card_no,convert(date,register_time) as register_date,source
			   from [DW_User].[V_User_Info] t1
			   left outer join [STG_User].[V_Card] t2 on t1.card_no=t2.card_no
			 where t2.source<>'Offline'  and isnumeric(user_id)=1
			   )tt1
		   )tt2
		on tt1.sephora_user_id = tt2.user_id 
		-- go


		-- 正式环境 833041 条数据 2min
		-- 最后一次线上购买时会员等级   // latest_online_purchase_card_type
		insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
		select 'T3_2','Tagging System Online User Update, update member card Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
		-- go
		update DA_Tagging.tagging_weekly
		set latest_online_purchase_card_type=tt2.latest_online_purchase_card_type
		from DA_Tagging.tagging_weekly tt1 
		join(
		   select sales_member_id,member_card_grade as latest_online_purchase_card_type
		   from(
			   select sales_member_id,member_card_grade,place_time 
			   ,row_number() over (partition by sales_member_id order by place_time desc) as rn
			   from DA_Tagging.sales_order_basic_temp
			 where member_card_grade is not null
			   )t1 
		   where rn=1 
		)tt2
		on tt1.sales_member_id=tt2.sales_member_id
		-- go
end

/* ############ ############ ############ Daily Update OnlineUser Tag ############ ############ ############ */
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','Tagging System Online User Update, update Weekly Tag Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

IF OBJECT_ID('tempdb..#weekly_onlineuser','U')  IS NOT NULL
drop table #weekly_onlineuser;
create table #weekly_onlineuser
(	
    master_id bigint,
	user_tenure_days	int,
	latest_online_purchase_card_type	nvarchar(255)	collate	Chinese_PRC_CS_AI_WS,
	user_registered_date	date,	
	age_group	nvarchar(255)	collate	Chinese_PRC_CS_AI_WS,
	constellation	nvarchar(255)	collate	Chinese_PRC_CS_AI_WS,
	gender	nvarchar(255)	collate	Chinese_PRC_CS_AI_WS,
	province	nvarchar(255)	collate	Chinese_PRC_CS_AI_WS,
	city	nvarchar(255)	collate	Chinese_PRC_CS_AI_WS,
	district	nvarchar(255)	collate	Chinese_PRC_CS_AI_WS,
	age	int

)
insert into #weekly_onlineuser(master_id,user_registered_date,user_tenure_days,latest_online_purchase_card_type,age,age_group,constellation,gender,province,city,district)
select master_id,user_registered_date,user_tenure_days,latest_online_purchase_card_type,age,age_group,constellation,gender,province,city,district
from DA_Tagging.tagging_weekly
where user_tenure_days is not null
or latest_online_purchase_card_type is not null
or user_registered_date is not null
or age_group is not null
or constellation is not null
or gender is not null
or province is not null
or city is not null
or district is not null
or age is not null

update DA_Tagging.online_user
set  user_tenure_days = tt2.user_tenure_days
	, latest_online_purchase_card_type = tt2.latest_online_purchase_card_type
	, user_registered_date = tt2.user_registered_date
	, age = tt2.age
	, age_group = tt2.age_group
	, constellation = tt2.constellation
	, gender = tt2.gender
	, province = tt2.province
	, city = tt2.city
	, district = tt2.district
from DA_Tagging.online_user t1
join #weekly_onlineuser tt2 on t1.master_id=tt2.master_id


--正式环境 12837141条数据 2min
-- 丝芙兰官网注册用户状态   // registered_user_status
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','Tagging System Online User Update, update registered status Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
update DA_Tagging.online_user
set registered_user_status=(case when tt2.user_id is null
  then N'非注册用户' else N'注册用户' end)
from DA_Tagging.online_user tt1 
join(
      select t1.card_no, t1.user_id,t2.source
      from STG_User.V_User_Profile t1 
      left outer join STG_User.V_Card t2 on t1.card_no=t2.card_no
      where source<>'Offline'
)tt2 on tt1.sephora_user_id=tt2.user_id
-- go

--------------------------------------------------------------------------------------------------
-- 正式环境 1234287 条数据40s
-- 线上新老客状态
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','Tagging System Online User Update, update eb customer status Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
update DA_Tagging.online_user
set eb_customer_status=tt2.eb_customer_status
from DA_Tagging.online_user tt1
join (
   select distinct sales_member_id
   ,case when all_order_placed_seq = 1 and member_card_grade in ('White', 'Black', 'Gold','',null) then 'CONVERT NEW'
   when all_order_placed_seq = 1 then 'BRAND NEW'
   when all_order_placed_seq > 1 then 'RETURN' end as eb_customer_status
   from(
       select sales_member_id,row_number() over(partition by sales_member_id order by place_time desc) as rn
       ,all_order_placed_seq, member_card_grade
       from(
           select sales_member_id, sales_order_number,member_card_grade,place_time
           ,count(sales_order_number) over (partition by sales_member_id) as all_order_placed_seq
           from DA_Tagging.sales_order_basic_temp
           )t1
       )tt1 where rn=1
)tt2 on tt1.sales_member_id = tt2.sales_member_id collate Chinese_PRC_CS_AI_WS

-- go

--正式环境 1234287 条数据 7min
-- 官网新老客状态 天猫新老客状态 京东新老客状态
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','Tagging System Online User Update, update eb platform customer status Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
update DA_Tagging.online_user
set eb_store_status_jd = tt2.eb_store_status_jd
  ,eb_store_status_tmall =tt2.eb_store_status_tmall
  ,eb_store_status_dragon =tt2.eb_store_status_dragon
  ,eb_store_status_red =tt2.eb_store_status_red
from DA_Tagging.online_user tt1 
join(
	  select sales_member_id
	 ,case when eb_store_status_jd is not null then eb_store_status_jd else N'京东未购买过' end as eb_store_status_jd
	 ,case when eb_store_status_tmall is not null then eb_store_status_tmall else N'天猫未购买过' end as eb_store_status_tmall
	 ,case when eb_store_status_dragon is not null then eb_store_status_dragon else N'官网未购买过' end as eb_store_status_dragon
	 ,case when eb_store_status_red is not null then eb_store_status_red else N'小红书未购买过' end as eb_store_status_red
	 from(
		 select sales_member_id
		,MIN(case when store = N'京东' then channel_status else null end) as eb_store_status_jd
		,MIN(case when store = N'天猫' then channel_status else null end) as eb_store_status_tmall
		,MIN(case when store = N'官网' then channel_status else null end) as eb_store_status_dragon
		,MIN(case when store = N'小红书' then channel_status else null end) as eb_store_status_red
		from (
			select distinct sales_member_id,store
			,case when chcnt = 1 then concat(store ,N'新客' collate Chinese_PRC_CS_AI_WS) 
			when chcnt > 1 then concat(store,N'老客' collate Chinese_PRC_CS_AI_WS) 
			else concat(store,N'未购买过' collate Chinese_PRC_CS_AI_WS) end as channel_status 
			from (
					select sales_member_id,case when store=N'丝芙兰官网' then N'官网' else store end as store
					,case when store is null then null else count(0) over(partition by sales_member_id,store) end chcnt
					from DA_Tagging.sales_order_basic_temp 
					--where sales_member_id in ('8120241719','8088290187','8147577988','8081337464'
					--,'4143286','8123499777','8042880370','8125777006','8084499253','8088150159','8058295794')
					) t1 where store is not null
			) t2 group by sales_member_id
	) tt1 
   )tt2 
on tt1.sales_member_id = tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
-- go

-- 跑通108045条数据 3min
-- 官网APP新老客状态 官网MNP新老客状态 丝芙兰天猫店新老客状态 蔚蓝之美天猫店新老客状态
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','Tagging System Online User Update, update eb channel customer status Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
update DA_Tagging.online_user
set eb_channel_status_app =tt2.eb_channel_status_app
  ,eb_channel_status_mnp =tt2.eb_channel_status_mnp
  ,eb_channel_status_sephora_tmall =tt2.eb_channel_status_sephora_tmall
  ,eb_channel_status_tmall_wei_tmall =tt2.eb_channel_status_tmall_wei_tmall
from DA_Tagging.online_user tt1 
join(
	select sales_member_id
	,case when eb_channel_status_app is not null then eb_channel_status_app else N'APP未购买过' end as eb_channel_status_app
	,case when eb_channel_status_mnp is not null then eb_channel_status_mnp else N'MNP未购买过' end as eb_channel_status_mnp
	,case when eb_channel_status_sephora_tmall is not null then eb_channel_status_sephora_tmall else N'丝芙兰天猫店未购买过' end as eb_channel_status_sephora_tmall
	,case when eb_channel_status_tmall_wei_tmall is not null then eb_channel_status_tmall_wei_tmall else N'蔚蓝之美天猫店未购买过' end as eb_channel_status_tmall_wei_tmall
	from(
		select sales_member_id
		,min(case when channel = N'APP' then channel_status else null end) as eb_channel_status_app
		,min(case when channel = N'MNP' then channel_status else null end) as eb_channel_status_mnp
		,min(case when channel = N'丝芙兰天猫店' then channel_status else null end) as eb_channel_status_sephora_tmall
		,min(case when channel = N'蔚蓝之美天猫店' then channel_status else null end) as eb_channel_status_tmall_wei_tmall
		from (
			select sales_member_id,channel
			,case when chcnt = 1 then concat(channel,N'新客' collate Chinese_PRC_CS_AI_WS) 
		when chcnt > 1 then concat(channel,N'老客' collate Chinese_PRC_CS_AI_WS)
		else concat(channel,N'未购买过' collate Chinese_PRC_CS_AI_WS) end as channel_status
			from (
				select sales_member_id,case when channel=N'小程序' then 'MNP' else channel end as channel
				,case when channel is null then null else count(0) over(partition by sales_member_id,channel) end chcnt
				from DA_Tagging.sales_order_basic_temp
				) as t1
			) as t2 group by sales_member_id
		)tt
)tt2
on tt1.sales_member_id = tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
-- go



-- 分组实现列拼接 
-- 丝芙兰官网首单购买的大类 
--测试环境 3634条数据 4min
--正式环境 698184条数据 5min
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','Tagging System Online User Update, update registered category Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go
update DA_Tagging.online_user
set dragon_registered_category=tt2.dragon_registered_category 
from DA_Tagging.online_user tt1 
join(
   select sales_member_id,STUFF(coalesce(','+Fragrance,'')+coalesce(','+Makeup,'')
       +coalesce(','+Skincare,'')+coalesce(','+Wellness,''),1,1,'') as dragon_registered_category
   from
   (
       select sales_member_id,
         max (case item_category when 'Fragrance' then 'Fragrance' else null end ) Fragrance,
         max (case item_category when 'Makeup' then 'Makeup' else null end ) Makeup,
         max (case item_category when 'Skincare' then 'Skincare' else null end ) Skincare,
         max (case item_category when 'Wellness' then 'Wellness' else null end ) Wellness
       from(
           select sales_member_id,item_category
           from (
               select sales_member_id,sales_order_number,item_category
               ,row_number() over(partition by sales_member_id,sales_order_number order by place_time) as rn
               from DA_Tagging.sales_order_vb_temp
               where store=N'丝芙兰官网'
           ) t1  where rn=1
       )tt group by sales_member_id
   )ttt
)tt2 on tt1.sales_member_id = tt2.sales_member_id collate Chinese_PRC_CS_AI_WS
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','Tagging System Online User Update, update registered category End',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- 删掉无用空数据 online user总量 4000w左右 --25s
delete from DA_Tagging.online_user 
where age is null 
and city is null 
and gender is null 
and district is null 
and province is null 
and age_group is null 
and constellation is null 
and eb_customer_status is null 
and user_tenure_days is null 
and eb_store_status_jd is null 
and eb_store_status_red is null 
and user_registered_date is null 
and eb_channel_status_app is null 
and eb_channel_status_mnp is null 
and eb_store_status_tmall is null 
and eb_store_status_dragon is null 
and registered_user_status is null 
and dragon_registered_category is null 
and eb_channel_status_sephora_tmall is null 
and latest_online_purchase_card_type is null 
and eb_channel_status_tmall_wei_tmall is null 

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T3_2','online user end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

END
GO
