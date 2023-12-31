/****** Object:  StoredProcedure [DA_BestSelling].[SP_T1_KPI]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_BestSelling].[SP_T1_KPI] AS
BEGIN


--========================================= Use Case Phase I KPI Total =========================================
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'UseCase1 Kpi','Use Case Phase I , Best Selling Total Kpi Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

declare @Update_Date varchar(100)= convert(date, DATEADD(hour,8,getdate())-1)


delete from DA_BestSelling.kpi_daily_total
where dt=@Update_Date 


truncate table DA_BestSelling.kpi_temp1
insert into DA_BestSelling.kpi_temp1(sales_order_number,place_time,item_product_id,item_apportion_amount,product_amount)
select t1.sales_order_number, t1.place_time, t2.item_product_id, t2.item_apportion_amount, t1.product_amount
    from(
        select sales_order_number,product_amount,place_time
        from [DW_OMS].[V_Sales_Order_Basic_Level]
        where store_cd='S001' and is_placed_flag=1 
        and convert(date,place_time) = @Update_Date 
    )t1 left outer join(
        select sales_order_number
        ,item_apportion_amount,item_product_id
        from [DW_OMS].[V_Sales_Order_VB_Level]
        where store_cd='S001' and is_placed_flag=1 
        and convert(date,place_time) = @Update_Date 
    ) t2 on t1.sales_order_number=t2.sales_order_number
;


truncate table DA_BestSelling.kpi_temp2
insert into DA_BestSelling.kpi_temp2(dt, test_version, user_id, op_code, orderid, platform_type)
select t1.dt, t1.test_version, t1.user_id, t1.op_code, t2.orderid, t1.platform_type
from(
    select dt,time,user_id,op_code
    ,case when event='BestSellerListProductClick' then 'B' else 'A' end as test_version,platform_type
    from STG_Sensor.V_Events
    where (
        (  platform_type ='app' and (substring(ss_app_version,1,1) >= 7 or ss_app_version='6.31.0'))
        or platform_type ='mobile'
    )
    and dt = @Update_Date 
    and event in ('BestSellerListProductClick','CampaignClick')
    and current_url like '%hotsales%'
    and op_code is not null
    )t1
left outer join(
    select dt,time,user_id,orderid,platform_type
    from STG_Sensor.V_Events
    where event='submitOrder' 
    and dt = @Update_Date 
    and (
            (  platform_type ='app' and (substring(ss_app_version,1,1) >= 7 or ss_app_version='6.31.0'))
            or platform_type ='mobile'
        )
    and orderid is not null
    )t2 on t1.user_id=t2.user_id and t1.dt=t2.dt --点击当天的下单行为
where t2.orderid is not null
and t1.time<t2.time
;



insert into DA_BestSelling.kpi_daily_total(dt,platform_type)
select @Update_Date  as dt,'app' as platform_type union all
select @Update_Date  as dt,'mobile' as platform_type union all
select @Update_Date  as dt,'total' as platform_type
;


update DA_BestSelling.kpi_daily_total
set click_product_uv_a=ttt2.click_product_uv_a
    ,click_product_uv_b=ttt2.click_product_uv_b
from DA_BestSelling.kpi_daily_total ttt1
join(

    select dt,platform_type
    ,max(case when test_version='A' then click_product_uv end) as click_product_uv_a
    ,max(case when test_version='B' then click_product_uv end) as click_product_uv_b
    from(
        select dt,platform_type,test_version,count(distinct user_id) as click_product_uv
        from(
            select dt,platform_type,time,user_id,op_code
            ,case when event='BestSellerListProductClick' then 'B' else 'A' end as test_version
            from STG_Sensor.V_Events
            where (
                (  platform_type ='app' and (substring(ss_app_version,1,1) >= 7 or ss_app_version='6.31.0'))
                or platform_type ='mobile'
            )
            and dt = @Update_Date 
            and event in ('BestSellerListProductClick','CampaignClick')
            and current_url like '%hotsales%'
            )t1
        group by dt,platform_type,test_version
    )ttt1
    group by dt,platform_type
)ttt2 on ttt1.dt=ttt2.dt and ttt1.platform_type=ttt2.platform_type
where ttt1.dt = @Update_Date 
;


update DA_BestSelling.kpi_daily_total
set landing_page_uv_a=ttt2.landing_page_uv_a
    ,landing_page_uv_b=ttt2.landing_page_uv_b
from DA_BestSelling.kpi_daily_total ttt1
join(
	select dt,platform_type
	,max(case when test_version='A' then landing_page_uv end) as landing_page_uv_a
	,max(case when test_version='B' then landing_page_uv end) as landing_page_uv_b
	from(
		select dt,platform_type,test_version,count(distinct user_id) as landing_page_uv
		from(
			select dt,platform_type,user_id
			,case when banner_to_url like '%v2/html/hotsalesstandings%' then 'B' 
			when banner_to_url like '%/campaign/hotsales/%' then 'A' end as test_version
			from STG_Sensor.V_Events
			where event='clickBanner_App_Mob' 
			and banner_content=N'畅销榜单' 
			and banner_belong_area in ('Icon','Select_Icon')
			and dt = @Update_Date
			and (
			(  platform_type ='app' and (substring(ss_app_version,1,1) >= 7 or ss_app_version='6.31.0'))
			or platform_type ='mobile'
		)
		)t2
		group by dt,platform_type,test_version
	)tt2
	group by dt,platform_type
)ttt2 on ttt1.dt=ttt2.dt and ttt1.platform_type=ttt2.platform_type
where ttt1.dt = @Update_Date
;



update DA_BestSelling.kpi_daily_total
set same_day_converted_uv_a = ttt2.same_day_converted_uv_a
    , same_day_converted_uv_b = ttt2.same_day_converted_uv_b
    , same_day_converted_order_cnt_a = ttt2.same_day_converted_order_cnt_a
    , same_day_converted_order_cnt_b = ttt2.same_day_converted_order_cnt_b
    , same_day_converted_revenue_a = ttt2.same_day_converted_revenue_a
    , same_day_converted_revenue_b = ttt2.same_day_converted_revenue_b
from DA_BestSelling.kpi_daily_total ttt1
join(
    select dt,platform_type
        ,max(case when test_version='A' then converted_uv end) as same_day_converted_uv_a
        ,max(case when test_version='B' then converted_uv end) as same_day_converted_uv_b
        ,max(case when test_version='A' then converted_order_count end) as same_day_converted_order_cnt_a
        ,max(case when test_version='B' then converted_order_count end) as same_day_converted_order_cnt_b
        ,max(case when test_version='A' then converted_revenue end) as same_day_converted_revenue_a
        ,max(case when test_version='B' then converted_revenue end) as same_day_converted_revenue_b
        from(
            select dt,platform_type,test_version,count(distinct user_id) as converted_uv
                          ,count(distinct sales_order_number) as converted_order_count
                          ,sum(product_amount) as converted_revenue
            from(
                select distinct dt,platform_type,test_version,user_id
                ,sales_order_number,product_amount
                from DA_BestSelling.kpi_temp2 t1
                left outer join 
                DA_BestSelling.kpi_temp1 t2 
                on t1.op_code=t2.item_product_id and t1.orderid=t2.sales_order_number
                where t2.sales_order_number is not null
                )tt1 -- 去重
            group by dt,platform_type,test_version
        )tt1
        group by dt,platform_type
)ttt2 on ttt1.dt=ttt2.dt and ttt1.platform_type=ttt2.platform_type
where ttt1.dt = @Update_Date
;


update DA_BestSelling.kpi_daily_total
set ctr_a = convert(float,click_product_uv_a)/convert(float,landing_page_uv_a)
,ctr_b = convert(float,click_product_uv_b)/convert(float,landing_page_uv_b)
,click_uv_value_a = convert(float,same_day_converted_revenue_a)/convert(float,landing_page_uv_a)
,click_uv_value_b = convert(float,same_day_converted_revenue_b)/convert(float,landing_page_uv_b)
where dt =@Update_Date
;

update DA_BestSelling.kpi_daily_total
    set landing_page_uv_a = tt.landing_page_uv_a
    ,landing_page_uv_b = tt.landing_page_uv_b
    ,click_product_uv_a = tt.click_product_uv_a
    ,click_product_uv_b = tt.click_product_uv_b
    ,ctr_a = tt.ctr_a
    ,ctr_b = tt.ctr_b
    ,same_day_converted_uv_a = tt.same_day_converted_uv_a
    ,same_day_converted_uv_b = tt.same_day_converted_uv_b
    ,same_day_converted_order_cnt_a = tt.same_day_converted_order_cnt_a
    ,same_day_converted_order_cnt_b = tt.same_day_converted_order_cnt_b
    ,same_day_converted_revenue_a = tt.same_day_converted_revenue_a
    ,same_day_converted_revenue_b = tt.same_day_converted_revenue_b
    ,click_uv_value_a = tt.click_uv_value_a
    ,click_uv_value_b = tt.click_uv_value_b
from DA_BestSelling.kpi_daily_total t1
join(
    select dt,'total' as platform_type
    , landing_page_uv_a, landing_page_uv_b, click_product_uv_a, click_product_uv_b, ctr_a, ctr_b
    , same_day_converted_uv_a, same_day_converted_uv_b, same_day_converted_order_cnt_a, same_day_converted_order_cnt_b
    , same_day_converted_revenue_a, same_day_converted_revenue_b, click_uv_value_a, click_uv_value_b
    from(
        select dt
        ,sum(landing_page_uv_a) as landing_page_uv_a
        ,sum(landing_page_uv_b) as landing_page_uv_b
        ,sum(click_product_uv_a) as click_product_uv_a
        ,sum(click_product_uv_b) as click_product_uv_b
        ,avg(ctr_a) as ctr_a
        ,avg(ctr_b) as ctr_b
        ,sum(same_day_converted_uv_a) as same_day_converted_uv_a
        ,sum(same_day_converted_uv_b) as same_day_converted_uv_b
        ,sum(same_day_converted_order_cnt_a) as same_day_converted_order_cnt_a
        ,sum(same_day_converted_order_cnt_b) as same_day_converted_order_cnt_b
        ,sum(same_day_converted_revenue_a) as same_day_converted_revenue_a
        ,sum(same_day_converted_revenue_b) as same_day_converted_revenue_b
        ,avg(click_uv_value_a) as click_uv_value_a
        ,avg(click_uv_value_b) as click_uv_value_b
        from DA_BestSelling.kpi_daily_total
        where dt = @Update_Date
        group by dt
    )t1
)tt on t1.dt=tt.dt and t1.platform_type=tt.platform_type
 where t1.platform_type='total'
 ;


--========================================= Use Case Phase I KPI By Group =========================================
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'UseCase1 Kpi','Use Case Phase I , Best Selling By Group Kpi Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

 -- ByGroup Use Case Kpi 
-- Landing page UV by group


delete from DA_BestSelling.kpi_daily_bygroup
where dt=@Update_Date 


insert into DA_BestSelling.kpi_daily_bygroup(dt,platform_type)
select @Update_Date as dt,'app' as platform_type union all
select @Update_Date as dt,'mobile' as platform_type union all
select @Update_Date as dt,'total' as platform_type


update DA_BestSelling.kpi_daily_bygroup
set landing_page_uv_group1 = tt2.landing_page_uv_group1,
    landing_page_uv_group2 = tt2.landing_page_uv_group2,
    landing_page_uv_group3 = tt2.landing_page_uv_group3,
    landing_page_uv_group4 = tt2.landing_page_uv_group4,
    landing_page_uv_group5 = tt2.landing_page_uv_group5,
    landing_page_uv_group6 = tt2.landing_page_uv_group6,
    landing_page_uv_group7 = tt2.landing_page_uv_group7
from DA_BestSelling.kpi_daily_bygroup tt1
join(
	select dt,platform_type
	, [1] as landing_page_uv_group1, [2] as landing_page_uv_group2, [3] as landing_page_uv_group3, [4] as landing_page_uv_group4
	, [5] as landing_page_uv_group5, [6] as landing_page_uv_group6, [7] as landing_page_uv_group7
    from(
        select dt,platform_type,group_id,count(distinct user_id) as total_cnt
        from(
            select dt,platform_type
			,case when group_id is not null then convert(nvarchar(255),group_id) else '7' end as group_id,t1.user_id
            from(
                select dt,user_id,platform_type
                from STG_Sensor.V_Events
                where dt = @Update_Date
                and banner_belong_area in ('Icon','Select_Icon') and banner_to_url like '%v2/html/hotsalesstandings%' 
                and event='clickBanner_App_Mob' and banner_content=N'畅销榜单'
                and (
					(  platform_type ='app' and (substring(ss_app_version,1,1) >= 7 or ss_app_version='6.31.0'))
					or platform_type ='mobile'
				)
            )t1
            left outer join DA_BestSelling.id_mapping t2 on t1.user_id=t2.sensor_id 
            left outer join (select * 
							from DA_BestSelling.user_group 
							where insert_date = (select max(insert_date) from DA_BestSelling.user_group)
							)t3 on t2.sephora_user_id=t3.user_id
        )tt1
        group by dt,platform_type,group_id
        )ttt1
        PIVOT (
			  max(total_cnt) for group_id in (
	  			[1],[2],[3],[4],[5],[6],[7])
				)b
)tt2 on tt1.dt=tt2.dt collate Chinese_PRC_CS_AI_WS
and tt1.platform_type=tt2.platform_type collate Chinese_PRC_CS_AI_WS
where tt1.dt = @Update_Date
;




update DA_BestSelling.kpi_daily_bygroup
set click_product_uv_group1 = tt2.click_product_uv_group1,
    click_product_uv_group2 = tt2.click_product_uv_group2,
    click_product_uv_group3 = tt2.click_product_uv_group3,
    click_product_uv_group4 = tt2.click_product_uv_group4,
    click_product_uv_group5 = tt2.click_product_uv_group5,
    click_product_uv_group6 = tt2.click_product_uv_group6,
    click_product_uv_group7 = tt2.click_product_uv_group7
from DA_BestSelling.kpi_daily_bygroup tt1
join(
	-- Click product UV by group
	select dt,platform_type
	,[1] as click_product_uv_group1,[2] as click_product_uv_group2,[3] as click_product_uv_group3,[4] as click_product_uv_group4
	,[5] as click_product_uv_group5,[6] as click_product_uv_group6,[7] as click_product_uv_group7
    from (
    select dt,platform_type,group_id,count(distinct t1.user_id) as cnt
        from (
            select dt,platform_type
			,case when group_id is not null then convert(nvarchar(255),group_id) else '7' end as group_id,t1.user_id
            from(
                select dt,user_id,platform_type
                from STG_Sensor.V_Events
                where dt = @Update_Date 
                and current_url like '%hotsales%'
                and current_url not like '%hotsales20210302%'
                and (
					(  platform_type ='app' and (substring(ss_app_version,1,1) >= 7 or ss_app_version='6.31.0'))
					or platform_type ='mobile'
				)
                and event='BestSellerListProductClick' and referrer is null--not referrer like '%/campaign/hotsales/%'

            )t1
            left outer join DA_BestSelling.id_mapping t2 on t1.user_id=t2.sensor_id
            left outer join (select * 
							from DA_BestSelling.user_group 
							where insert_date = (select max(insert_date) from DA_BestSelling.user_group)
							) t3 on t2.sephora_user_id=t3.user_id
        )t1 group by dt,platform_type,group_id
    )ttt2 PIVOT (
			  max(cnt) for group_id in (
	  			[1],[2],[3],[4],[5],[6],[7])
				)b

)tt2 on tt1.dt=tt2.dt collate Chinese_PRC_CS_AI_WS
and tt1.platform_type=tt2.platform_type collate Chinese_PRC_CS_AI_WS
where tt1.dt = @Update_Date
;


select dt,platform_type,group_id,count(distinct user_id) as uv_value
,count(distinct sales_order_number) as converted_order_count
,sum(product_amount) as converted_revenue
into #converted_temp
from(
	select dt,platform_type
	,case when group_id is not null and group_id <>'' then convert(nvarchar(255),group_id) else '7' end as group_id
	,tt1.user_id,sales_order_number,product_amount
	from(
		select distinct dt,platform_type,user_id,sales_order_number,product_amount
		from(
			select dt,platform_type,user_id,orderid,op_code
			from DA_BestSelling.kpi_temp2
			where test_version='B'
			)t1
		left outer join DA_BestSelling.kpi_temp1 t2 on t1.op_code=t2.item_product_id 
		and t1.orderid=t2.sales_order_number
		where convert(date, t2.place_time)=t1.dt
	)tt1 -- 去重
	inner join DA_BestSelling.id_mapping t2 on tt1.user_id=t2.sensor_id
	left outer join (select * 
							from DA_BestSelling.user_group 
							where insert_date = (select max(insert_date) from DA_BestSelling.user_group)
							) t3 on t2.sephora_user_id=t3.user_id
)t group by dt,platform_type,group_id



update DA_BestSelling.kpi_daily_bygroup
set same_day_converted_order_cnt_group1 = tt2.same_day_converted_order_cnt_group1, same_day_converted_order_cnt_group2 = tt2.same_day_converted_order_cnt_group2,
    same_day_converted_order_cnt_group3 = tt2.same_day_converted_order_cnt_group3, same_day_converted_order_cnt_group4 = tt2.same_day_converted_order_cnt_group4,
    same_day_converted_order_cnt_group5 = tt2.same_day_converted_order_cnt_group5, same_day_converted_order_cnt_group6 = tt2.same_day_converted_order_cnt_group6,
    same_day_converted_order_cnt_group7 = tt2.same_day_converted_order_cnt_group7
from DA_BestSelling.kpi_daily_bygroup tt1
join(
    select dt,platform_type
		, [1] as same_day_converted_order_cnt_group1, [2] as same_day_converted_order_cnt_group2 , [3] as same_day_converted_order_cnt_group3
		, [4] as same_day_converted_order_cnt_group4 , [5] as same_day_converted_order_cnt_group5, [6] as same_day_converted_order_cnt_group6 
		, [7] as same_day_converted_order_cnt_group7
        from (
		select dt,platform_type, group_id,converted_order_count
		from #converted_temp
    )ttt2 PIVOT (
			  max(converted_order_count) for group_id in (
	  			[1],[2],[3],[4],[5],[6],[7])
				)b

)tt2 on tt1.dt=tt2.dt and tt1.platform_type=tt2.platform_type 
where tt1.dt = @Update_Date
;



update DA_BestSelling.kpi_daily_bygroup
set same_day_converted_revenue_group1 = tt2.same_day_converted_revenue_group1,
    same_day_converted_revenue_group2 = tt2.same_day_converted_revenue_group2, same_day_converted_revenue_group3 = tt2.same_day_converted_revenue_group3,
    same_day_converted_revenue_group4 = tt2.same_day_converted_revenue_group4, same_day_converted_revenue_group5 = tt2.same_day_converted_revenue_group5,
    same_day_converted_revenue_group6 = tt2.same_day_converted_revenue_group6, same_day_converted_revenue_group7 = tt2.same_day_converted_revenue_group7
from DA_BestSelling.kpi_daily_bygroup tt1
join(
    select dt, platform_type
		,[1] as same_day_converted_revenue_group1 ,[2] as same_day_converted_revenue_group2 ,[3] as same_day_converted_revenue_group3 
		,[4] as same_day_converted_revenue_group4 ,[5] as same_day_converted_revenue_group5 ,[6] as same_day_converted_revenue_group6
		,[7] as same_day_converted_revenue_group7
        from (
		select dt,platform_type, group_id,converted_revenue
		from #converted_temp
    )ttt2  PIVOT (
			  max(converted_revenue) for group_id in (
	  			[1],[2],[3],[4],[5],[6],[7])
				)b
)tt2 on tt1.dt=tt2.dt and tt1.platform_type=tt2.platform_type 
where tt1.dt = @Update_Date
;


update DA_BestSelling.kpi_daily_bygroup
set group_size_group1 = tt2.group_size_group1,
    group_size_group2 = tt2.group_size_group2,
    group_size_group3 = tt2.group_size_group3,
    group_size_group4 = tt2.group_size_group4,
    group_size_group5 = tt2.group_size_group5,
    group_size_group6 = tt2.group_size_group6
from DA_BestSelling.kpi_daily_bygroup tt1
join(
	select dt
		,[1] as group_size_group1
		,[2] as group_size_group2
		,[3] as group_size_group3
		,[4] as group_size_group4
		,[5] as group_size_group5
		,[6] as group_size_group6
      from (
          select @Update_Date as dt,convert(nvarchar(255) ,group_id) as group_id 
		  ,group_number from DA_BestSelling.user_attr
      )t1
	   PIVOT (
			  max(group_number) for group_id in (
	  			[1],[2],[3],[4],[5],[6])
				)b
)tt2 on tt1.dt=tt2.dt
where tt1.dt = @Update_Date
;



update DA_BestSelling.kpi_daily_bygroup
set group_size_group1_theday = tt2.group_size_group1_theday,
    group_size_group2_theday = tt2.group_size_group2_theday,
    group_size_group3_theday = tt2.group_size_group3_theday,
    group_size_group4_theday = tt2.group_size_group4_theday,
    group_size_group5_theday = tt2.group_size_group5_theday,
    group_size_group6_theday = tt2.group_size_group6_theday,
    group_size_group7_theday = tt2.group_size_group7_theday
from DA_BestSelling.kpi_daily_bygroup tt1
join(
    select dt,platform_type
		,[1] as group_size_group1_theday,[2] as group_size_group2_theday,[3] as group_size_group3_theday,[4] as group_size_group4_theday
		,[5] as group_size_group5_theday,[6] as group_size_group6_theday,[7] as group_size_group7_theday
        from (
            select dt,platform_type, group_id,count(distinct t1.user_id) as cnt
            from (
                select dt,platform_type
				,case when group_id is not null then convert(nvarchar(255),group_id) else '7' end as group_id,t1.user_id
                from(
                    select dt,platform_type,user_id from STG_Sensor.V_Events 
					where dt = @Update_Date
                    and (
					(  platform_type ='app' and (substring(ss_app_version,1,1) >= 7 or ss_app_version='6.31.0'))
					or platform_type ='mobile'
					)
                    )t1
                    inner join DA_BestSelling.id_mapping t2 on t1.user_id=t2.sensor_id
                    left outer join (select * 
							from DA_BestSelling.user_group 
							where insert_date = (select max(insert_date) from DA_BestSelling.user_group)
							) t3 on t2.sephora_user_id=t3.user_id
                )t1
            group by dt,platform_type, group_id
        )t1
		PIVOT (
			  max(cnt) for group_id in (
	  			[1],[2],[3],[4],[5],[6],[7])
				)b
)tt2 on tt1.dt=tt2.dt collate Chinese_PRC_CS_AI_WS
and tt1.platform_type=tt2.platform_type collate Chinese_PRC_CS_AI_WS
where tt1.dt = @Update_Date
;


update DA_BestSelling.kpi_daily_bygroup
set ctr_group1 = convert(float,click_product_uv_group1)/convert(float,landing_page_uv_group1 )
,ctr_group2 = convert(float,click_product_uv_group2)/convert(float,landing_page_uv_group2 )
,ctr_group3 = convert(float,click_product_uv_group3)/convert(float,landing_page_uv_group3 )
,ctr_group4 = convert(float,click_product_uv_group4)/convert(float,landing_page_uv_group4 )
,ctr_group5 = convert(float,click_product_uv_group5)/convert(float,landing_page_uv_group5 )
,ctr_group6 = convert(float,click_product_uv_group6)/convert(float,landing_page_uv_group6)
,ctr_group7 = convert(float,click_product_uv_group7)/convert(float,landing_page_uv_group7)
,uv_value_group1 = convert(float,same_day_converted_revenue_group1)/convert(float,landing_page_uv_group1)
,uv_value_group2 = convert(float,same_day_converted_revenue_group2)/convert(float,landing_page_uv_group2)
,uv_value_group3 = convert(float,same_day_converted_revenue_group3)/convert(float,landing_page_uv_group3)
,uv_value_group4 = convert(float,same_day_converted_revenue_group4)/convert(float,landing_page_uv_group4)
,uv_value_group5 = convert(float,same_day_converted_revenue_group5)/convert(float,landing_page_uv_group5)
,uv_value_group6 = convert(float,same_day_converted_revenue_group6)/convert(float,landing_page_uv_group6)
,uv_value_group7 = convert(float,same_day_converted_revenue_group7)/convert(float,landing_page_uv_group7)
from DA_BestSelling.kpi_daily_bygroup
where dt =@Update_Date


update DA_BestSelling.kpi_daily_bygroup
set landing_page_uv_group1 = tt.landing_page_uv_group1
, landing_page_uv_group2 = tt.landing_page_uv_group2
, landing_page_uv_group3 = tt.landing_page_uv_group3
, landing_page_uv_group4 = tt.landing_page_uv_group4
, landing_page_uv_group5 = tt.landing_page_uv_group5
, landing_page_uv_group6 = tt.landing_page_uv_group6
, landing_page_uv_group7 = tt.landing_page_uv_group7
, click_product_uv_group1 = tt.click_product_uv_group1
, click_product_uv_group2 = tt.click_product_uv_group2
, click_product_uv_group3 = tt.click_product_uv_group3
, click_product_uv_group4 = tt.click_product_uv_group4
, click_product_uv_group5 = tt.click_product_uv_group5
, click_product_uv_group6 = tt.click_product_uv_group6
, click_product_uv_group7 = tt.click_product_uv_group7
, ctr_group3 = tt.ctr_group3
, ctr_group7 = tt.ctr_group7
, same_day_converted_order_cnt_group1 = tt.same_day_converted_order_cnt_group1
, same_day_converted_order_cnt_group2 = tt.same_day_converted_order_cnt_group2
, same_day_converted_order_cnt_group3 = tt.same_day_converted_order_cnt_group3
, same_day_converted_order_cnt_group4 = tt.same_day_converted_order_cnt_group4
, same_day_converted_order_cnt_group5 = tt.same_day_converted_order_cnt_group5
, same_day_converted_order_cnt_group6 = tt.same_day_converted_order_cnt_group6
, same_day_converted_order_cnt_group7 = tt.same_day_converted_order_cnt_group7
, same_day_converted_revenue_group1 = tt.same_day_converted_revenue_group1
, same_day_converted_revenue_group2 = tt.same_day_converted_revenue_group2
, same_day_converted_revenue_group3 = tt.same_day_converted_revenue_group3
, same_day_converted_revenue_group4 = tt.same_day_converted_revenue_group4
, same_day_converted_revenue_group5 = tt.same_day_converted_revenue_group5
, same_day_converted_revenue_group6 = tt.same_day_converted_revenue_group6
, same_day_converted_revenue_group7 = tt.same_day_converted_revenue_group7
, uv_value_group1 = tt.uv_value_group1
, uv_value_group2 = tt.uv_value_group2
, uv_value_group3 = tt.uv_value_group3
, uv_value_group4 = tt.uv_value_group4
, uv_value_group5 = tt.uv_value_group5
, uv_value_group6 = tt.uv_value_group6
, uv_value_group7 = tt.uv_value_group7
, group_size_group1_theday = tt.group_size_group1_theday
, group_size_group2_theday = tt.group_size_group2_theday
, group_size_group3_theday = tt.group_size_group3_theday
, group_size_group4_theday = tt.group_size_group4_theday
, group_size_group5_theday = tt.group_size_group5_theday
, group_size_group6_theday = tt.group_size_group6_theday
, group_size_group7_theday = tt.group_size_group7_theday
from DA_BestSelling.kpi_daily_bygroup tt1
join(
select t1.dt
, 'total' as platform_type, landing_page_uv_group1, landing_page_uv_group2, landing_page_uv_group3, landing_page_uv_group4, landing_page_uv_group5, landing_page_uv_group6, landing_page_uv_group7
, click_product_uv_group1, click_product_uv_group2, click_product_uv_group3, click_product_uv_group4, click_product_uv_group5, click_product_uv_group6, click_product_uv_group7
, ctr_group1, ctr_group2, ctr_group3, ctr_group4, ctr_group5, ctr_group6, ctr_group7
, same_day_converted_order_cnt_group1, same_day_converted_order_cnt_group2, same_day_converted_order_cnt_group3, same_day_converted_order_cnt_group4, same_day_converted_order_cnt_group5, same_day_converted_order_cnt_group6, same_day_converted_order_cnt_group7
, same_day_converted_revenue_group1, same_day_converted_revenue_group2, same_day_converted_revenue_group3, same_day_converted_revenue_group4, same_day_converted_revenue_group5, same_day_converted_revenue_group6, same_day_converted_revenue_group7
, uv_value_group1, uv_value_group2, uv_value_group3, uv_value_group4, uv_value_group5, uv_value_group6, uv_value_group7
, group_size_group1, group_size_group2, group_size_group3, group_size_group4, group_size_group5, group_size_group6
, group_size_group1_theday, group_size_group2_theday, group_size_group3_theday, group_size_group4_theday, group_size_group5_theday, group_size_group6_theday, group_size_group7_theday
from(
    select dt
             ,sum(landing_page_uv_group1) as landing_page_uv_group1
             ,sum(landing_page_uv_group2) as landing_page_uv_group2
             ,sum(landing_page_uv_group3) as landing_page_uv_group3
             ,sum(landing_page_uv_group4) as landing_page_uv_group4
             ,sum(landing_page_uv_group5) as landing_page_uv_group5
             ,sum(landing_page_uv_group6) as landing_page_uv_group6
             ,sum(landing_page_uv_group7) as landing_page_uv_group7
             ,sum(click_product_uv_group1) as click_product_uv_group1
             ,sum(click_product_uv_group2) as click_product_uv_group2
             ,sum(click_product_uv_group3) as click_product_uv_group3
             ,sum(click_product_uv_group4) as click_product_uv_group4
             ,sum(click_product_uv_group5) as click_product_uv_group5
             ,sum(click_product_uv_group6) as click_product_uv_group6
             ,sum(click_product_uv_group7) as click_product_uv_group7
             ,avg(ctr_group1) as ctr_group1, avg(ctr_group2) as ctr_group2, avg(ctr_group3) as ctr_group3
             ,avg(ctr_group4) as ctr_group4, avg(ctr_group5) as ctr_group5, avg(ctr_group6) as ctr_group6, avg(ctr_group7) as ctr_group7
             ,sum(same_day_converted_order_cnt_group1) as same_day_converted_order_cnt_group1
             ,sum(same_day_converted_order_cnt_group2) as same_day_converted_order_cnt_group2
             ,sum(same_day_converted_order_cnt_group3) as same_day_converted_order_cnt_group3
             ,sum(same_day_converted_order_cnt_group4) as same_day_converted_order_cnt_group4
             ,sum(same_day_converted_order_cnt_group5) as same_day_converted_order_cnt_group5
             ,sum(same_day_converted_order_cnt_group6) as same_day_converted_order_cnt_group6
             ,sum(same_day_converted_order_cnt_group7) as same_day_converted_order_cnt_group7
             ,sum(same_day_converted_revenue_group1) as same_day_converted_revenue_group1
             ,sum(same_day_converted_revenue_group2) as same_day_converted_revenue_group2
             ,sum(same_day_converted_revenue_group3) as same_day_converted_revenue_group3
             ,sum(same_day_converted_revenue_group4) as same_day_converted_revenue_group4
             ,sum(same_day_converted_revenue_group5) as same_day_converted_revenue_group5
             ,sum(same_day_converted_revenue_group6) as same_day_converted_revenue_group6
             ,sum(same_day_converted_revenue_group7) as same_day_converted_revenue_group7
             ,avg(uv_value_group1) as uv_value_group1
             ,avg(uv_value_group2) as uv_value_group2
             ,avg(uv_value_group3) as uv_value_group3
             ,avg(uv_value_group4) as uv_value_group4
             ,avg(uv_value_group5) as uv_value_group5
             ,avg(uv_value_group6) as uv_value_group6
             ,avg(uv_value_group7) as uv_value_group7
			 , sum(group_size_group1_theday) as group_size_group1_theday
			, sum(group_size_group2_theday) as group_size_group2_theday
			, sum(group_size_group3_theday) as group_size_group3_theday
			, sum(group_size_group4_theday) as group_size_group4_theday
			, sum(group_size_group5_theday) as group_size_group5_theday
			, sum(group_size_group6_theday) as group_size_group6_theday
			, sum(group_size_group7_theday) as group_size_group7_theday
             from DA_BestSelling.kpi_daily_bygroup
             where dt = @Update_Date 
             group by dt
             )t1
            left join (
                select distinct dt
				,group_size_group1, group_size_group2, group_size_group3, group_size_group4, group_size_group5, group_size_group6
                    from  DA_BestSelling.kpi_daily_bygroup
                    where dt =@Update_Date
                    ) t2 on t1.dt = t2.dt 
)tt on tt1.dt=tt.dt and tt1.platform_type=tt.platform_type
 where tt1.platform_type='total'
 ;

insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'UseCase1 Kpi','Use Case Phase I , Best Selling By Group Kpi End....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;


END 
GO
