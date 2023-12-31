/****** Object:  StoredProcedure [DA_TopRanking].[SP_T1_KPI]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_TopRanking].[SP_T1_KPI] AS
BEGIN

--========================================= Use Case Phase II KPI Total =========================================
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'UseCase2 Kpi','Use Case Phase II , TopRanking Total Kpi Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
declare @Update_Date varchar(100) = convert(date, DATEADD(hour,8,getdate())-1)

delete from DA_TopRanking.kpi_tracking_totalV2
where dt=@Update_Date 

-- 商品详情页表现 - 榜单及小标签产品
-- PLP-to-PDP CTR
-- PLP-to-PDP clicks/Total PLP PV 
-- PLP到榜单或小标签产品PDP点击率。PDP仅包含有小标签或者榜单的产品PDP
 
if not object_id(N'Tempdb..#prod_temp') is null 
drop table #prod_temp
  
select item_product_id, dt
into #prod_temp
from(
	select distinct item_product_id  ,convert(date,convert(datetime,create_date)+1) as dt 
	from [DA_TopRanking].[prod_label_t] 

	union

	select distinct item_product_id ,convert(date,convert(datetime,create_date)+1) as dt 
	from [DA_TopRanking].[prod_list_t] 
)t
;
--订单数据计算部分
--====================================================================================================================
-- PDP UV Value: 
-- 榜单及小标签产品的PDP访客 当日销售价值
-- PDP Buyer Conversion Rate:
-- 榜单与小标签产品的PDP访客 当日点击转化率
-- 订单数据
if not object_id(N'Tempdb..#sameday_order_temp') is null 
drop table #sameday_order_temp
select t1.sales_order_number,t1.place_time,t2.item_product_id,t1.product_amount
,convert(date,t1.place_time) as place_date
into #sameday_order_temp
from(
    select sales_order_number,product_amount,place_time
    from  [DW_OMS].[V_Sales_Order_Basic_Level]
    where store_cd = 'S001' and is_placed_flag = 1 
    and convert(date,place_time) = @Update_Date 
)t1
left outer join(
    select sales_order_number
    ,item_apportion_amount,item_product_id
    from [DW_OMS].[V_Sales_Order_VB_Level]
    where store_cd = 'S001' and is_placed_flag = 1 
    and convert(date,place_time) = @Update_Date 
) t2 on t1.sales_order_number = t2.sales_order_number
;

--小程序计算部分
--====================================================================================================================
-- 进入MNP PLP 页面的 PV 
if not object_id(N'Tempdb..#total_plp_pv_mnp') is null 
drop table #total_plp_pv_mnp
select dt, count(0) as total_plp_pv_mnp
into #total_plp_pv_mnp
from(
	select dt, user_id
	from STG_Sensor.V_Events
	where dt = @Update_Date 
	and platform_type in ('Mini Program','MiniProgram')
	and event='$MPViewScreen'
	and page_type='List-page'
)tt	group by dt


-- 插入total plp pv数据
insert into DA_TopRanking.kpi_tracking_totalV2(dt,platform_type,total_plp_pv)
select distinct dt,'mnp' as platform_type, total_plp_pv_mnp from #total_plp_pv_mnp
select 1

-- PLP 页面点击了带榜单/小标签信息的产品的人次
if not object_id(N'Tempdb..#plp2pdp_mnp') is null 
drop table #plp2pdp_mnp
select dt
, count(0) as plp2pdp_clicks
, count(distinct user_id) as plp2pdp_uv
into #plp2pdp_mnp
from(
	select t1.dt, t1.user_id,op_code
	from(
		select dt, user_id,op_code
		from STG_Sensor.V_Events
		where dt = @Update_Date 
		and platform_type in ('Mini Program','MiniProgram')
		and event='ListProductClick'
		and page_type='List-page'
	)t1 inner join #prod_temp t2 on t1.dt = t2.dt and t1.op_code = t2.item_product_id
)tt1 group by dt
;

select 2

update DA_TopRanking.kpi_tracking_totalV2
set plp2pdp_clicks = t2.plp2pdp_clicks,
	plp2pdp_uv = t2.plp2pdp_uv
from DA_TopRanking.kpi_tracking_totalV2 t1
join(
	select dt, plp2pdp_clicks,plp2pdp_uv
	from #plp2pdp_mnp
)t2 on t1.dt = t2.dt collate Chinese_PRC_CS_AI_WS
and platform_type='mnp'
select 3

-- 浏览带榜单信息的产品
if not object_id(N'Tempdb..#sameday_view_temp1') is null 
drop table #sameday_view_temp1
select distinct dt, user_id, op_code,time
into #sameday_view_temp1
from(
		select t01.dt, time , t01.user_id, op_code
		from(
			select dt, time , user_id, op_code
			from STG_Sensor.V_Events
			where dt = @Update_Date 
			and platform_type in ('Mini Program','MiniProgram')
			and event='viewCommodityDetail'
		)t01 inner join #prod_temp t2 on t01.dt = t2.dt and t01.op_code = t2.item_product_id
)t1
;
select 4


-- 浏览带榜单信息产品然后提交订单
if not object_id(N'Tempdb..#sameday_view_temp') is null 
drop table #sameday_view_temp
select distinct t1.dt, t1.user_id, t1.op_code, t2.orderid
into #sameday_view_temp
from #sameday_view_temp1 t1
left outer join(
    select dt,time,user_id,orderid
    from STG_Sensor.V_Events
    where event='submitOrder'
    and dt = @Update_Date 
	and platform_type in ('Mini Program','MiniProgram')
    and orderid is not null
    )t2 on t1.user_id=t2.user_id and t1.dt=t2.dt 
where t1.time<t2.time    --浏览后下单
;

select 5
update DA_TopRanking.kpi_tracking_totalV2
set list_pdp_uv = t2.list_pdp_uv 
from DA_TopRanking.kpi_tracking_totalV2 t1
join(
	select dt,count(distinct user_id) list_pdp_uv
	from #sameday_view_temp1
	group by dt
)t2 on t1.dt = t2.dt collate Chinese_PRC_CS_AI_WS
and platform_type='mnp'
;
select 6

-- 浏览带产品榜单信息的转化率、uv value
update DA_TopRanking.kpi_tracking_totalV2
set converted_uv = t2.converted_uv
,converted_order_count = t2.converted_order_count
,converted_revenue = t2.converted_revenue
from DA_TopRanking.kpi_tracking_totalV2 t1
join(
	select dt
	,count(distinct user_id) as converted_uv 
	,count(distinct sales_order_number) as converted_order_count
	,sum(product_amount) as converted_revenue
	from(
		select distinct dt,user_id,sales_order_number,product_amount
		from #sameday_view_temp t1 
		left outer join #sameday_order_temp t2 on t1.op_code COLLATE SQL_Latin1_General_CP1_CI_AS=t2.item_product_id and t1.orderid COLLATE SQL_Latin1_General_CP1_CI_AS=t2.sales_order_number
		where t2.sales_order_number is not null
	)tt1 group by dt
)t2 on t1.dt = t2.dt collate Chinese_PRC_CS_AI_WS
where platform_type='mnp'
;

select 7
--APP计算部分
--====================================================================================================================
-- 进入APP PLP 页面的 PV 
if not object_id(N'Tempdb..#total_plp_pv') is null 
drop table #total_plp_pv
select dt,total_plp_pv
into #total_plp_pv
from(
	select dt, count(0) as total_plp_pv
	from(
			select t1.dt, t1.user_id
			from(
				select dt, user_id
				from STG_Sensor.V_Events
				where dt = @Update_Date 
				and platform_type = 'app'
				and event='$AppViewScreen'
				and page_type='List-page'
			)t1 
	)tt	group by dt
)t
;

-- 插入total plp pv数据
insert into DA_TopRanking.kpi_tracking_totalV2(dt,platform_type,total_plp_pv)
select distinct dt,'app' as platform_type, total_plp_pv from #total_plp_pv


------------------------------------------------
-- PLP 页面点击了带榜单/小标签信息的产品的人次
if not object_id(N'Tempdb..#plp2pdp') is null 
drop table #plp2pdp
select dt
, count(0) as plp2pdp_clicks
, count(distinct user_id) as plp2pdp_uv
into #plp2pdp
from(
	select t1.dt, t1.user_id,op_code
	from(
		select dt, user_id,op_code
		from STG_Sensor.V_Events
		where dt = @Update_Date 
		and lower(platform_type) = 'app'
		and event='ListProductClick'
		and page_type='List-page'
	)t1 inner join #prod_temp t2 on t1.dt = t2.dt and t1.op_code = t2.item_product_id
)tt1 group by dt
;
select 1
update DA_TopRanking.kpi_tracking_totalV2
set plp2pdp_clicks = t2.plp2pdp_clicks,
	plp2pdp_uv = t2.plp2pdp_uv
from DA_TopRanking.kpi_tracking_totalV2 t1
join(
	select dt, plp2pdp_clicks,plp2pdp_uv
	from #plp2pdp
)t2 on t1.dt = t2.dt collate Chinese_PRC_CS_AI_WS
and platform_type='app'
select 2

-- PDP UV Value: 
-- 榜单及小标签产品的PDP访客 当日销售价值
-- PDP Buyer Conversion Rate:
-- 榜单与小标签产品的PDP访客 当日点击转化率
-- 订单数据
if not object_id(N'Tempdb..#sameday_order_temp') is null 
drop table #sameday_order_temp
select t1.sales_order_number,t1.place_time,t2.item_product_id,t1.product_amount
,convert(date,t1.place_time) as place_date
into #sameday_order_temp
from(
    select sales_order_number,product_amount,place_time
    from  [DW_OMS].[V_Sales_Order_Basic_Level]
    where store_cd = 'S001' and is_placed_flag = 1 
    and convert(date,place_time) = @Update_Date 
)t1
left outer join(
    select sales_order_number
    ,item_apportion_amount,item_product_id
    from [DW_OMS].[V_Sales_Order_VB_Level]
    where store_cd = 'S001' and is_placed_flag = 1 
    and convert(date,place_time) = @Update_Date 
) t2 on t1.sales_order_number = t2.sales_order_number
;
select 3

-- 浏览带榜单信息的产品
if not object_id(N'Tempdb..#sameday_view_temp1') is null 
drop table #sameday_view_temp1
select distinct dt, user_id, op_code,time
into #sameday_view_temp1
from(
		select t01.dt, time , t01.user_id, op_code
		from(
			select dt, time , user_id, op_code
			from STG_Sensor.V_Events
			where dt = @Update_Date 
			and lower(platform_type) = 'app'
			and event='viewCommodityDetail'
		)t01 inner join #prod_temp t2 on t01.dt = t2.dt and t01.op_code = t2.item_product_id
)t1
;
select 4
-- 浏览带榜单信息产品然后提交订单
if not object_id(N'Tempdb..#sameday_view_temp') is null 
drop table #sameday_view_temp
select distinct t1.dt, t1.user_id, t1.op_code, t2.orderid
into #sameday_view_temp
from #sameday_view_temp1 t1
left outer join(
    select dt,time,user_id,orderid
    from STG_Sensor.V_Events
    where event='submitOrder'
    and dt = @Update_Date 
	and lower(platform_type) = 'app'
    and orderid is not null
    )t2 on t1.user_id=t2.user_id and t1.dt=t2.dt 
where t1.time<t2.time    --浏览后下单
;
select 5
update DA_TopRanking.kpi_tracking_totalV2
set list_pdp_uv = t2.list_pdp_uv 
from DA_TopRanking.kpi_tracking_totalV2 t1
join(
	select dt,count(distinct user_id) list_pdp_uv
	from #sameday_view_temp1
	group by dt
)t2 on t1.dt = t2.dt collate Chinese_PRC_CS_AI_WS
and platform_type='app'
;
select 6
-- 浏览带产品榜单信息的转化率、uv value
update DA_TopRanking.kpi_tracking_totalV2
set converted_uv = t2.converted_uv
,converted_order_count = t2.converted_order_count
,converted_revenue = t2.converted_revenue
from DA_TopRanking.kpi_tracking_totalV2 t1
join(
	select dt
	,count(distinct user_id) as converted_uv 
	,count(distinct sales_order_number) as converted_order_count
	,sum(product_amount) as converted_revenue
	from(
		select distinct dt,user_id,sales_order_number,product_amount
		from #sameday_view_temp t1 
		left outer join #sameday_order_temp t2 on t1.op_code COLLATE SQL_Latin1_General_CP1_CI_AS=t2.item_product_id and t1.orderid COLLATE SQL_Latin1_General_CP1_CI_AS=t2.sales_order_number
		where t2.sales_order_number is not null
	)tt1 group by dt
)t2 on t1.dt = t2.dt collate Chinese_PRC_CS_AI_WS
and platform_type='app'
;

select 7

--Total 指标部分
--===================================================================================================================================================
insert into DA_TopRanking.kpi_tracking_totalV2(dt, platform_type, total_plp_pv, plp2pdp_clicks, plp2pdp_uv, list_pdp_uv, converted_uv
, converted_order_count, converted_revenue)
select dt,platform_type, total_plp_pv, plp2pdp_clicks
,plp2pdp_uv,  list_pdp_uv, converted_uv, converted_order_count, converted_revenue
from(
	select 'total' as platform_type ,* 
	from(
		select dt
		,sum(total_plp_pv) as total_plp_pv
		,sum(list_pdp_uv) as list_pdp_uv
		,sum(plp2pdp_clicks) as plp2pdp_clicks
		,sum(plp2pdp_uv) as plp2pdp_uv
		,sum(converted_uv) as converted_uv
		,sum(converted_order_count) as converted_order_count
		,sum(converted_revenue) as converted_revenue
		from(
				select distinct dt, platform_type
				,  total_plp_pv, plp2pdp_clicks, plp2pdp_uv
				,  list_pdp_uv, converted_uv, converted_order_count, converted_revenue
				from DA_TopRanking.kpi_tracking_totalV2
				where dt =@Update_Date 
				)t1 group by dt
	)tt1
)t1
select 8

-- 计算指标部分
--===================================================================================================================================================
-- 计算ctr  uv_value  conversion_rate
update DA_TopRanking.kpi_tracking_totalV2
set plp_to_pdp_ctr = convert(float,plp2pdp_clicks)/convert(float,total_plp_pv)
,pdp_conversoin_rate = convert(float,converted_uv)/convert(float,list_pdp_uv)
,pdp_uv_value = convert(float,converted_revenue)/convert(float,list_pdp_uv)
where dt  = @Update_Date 



insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'UseCase2 Kpi','Use Case Phase II , TopRanking ByList Kpi Start....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;
--===================================================================================================================================================


--declare @Update_Date varchar(100) = '2021-12-27'--convert(date, DATEADD(hour,8,getdate())-1)
declare @Group_Update_Date varchar(100) = convert(varchar(10),dateadd(wk, datediff(wk,0,getdate()), 0),120)


delete from DA_TopRanking.kpi_tracking_bylist
where dt= @Update_Date 


insert into DA_TopRanking.kpi_tracking_bylist(dt,platform_type)
select @Update_Date,'app' 
union all  select @Update_Date,'mnp' 

;


-- B版用户在plp页面点击产品时 产品的榜单、产品code
if not object_id(N'Tempdb..#list_click_product_bygroup') is null 
drop table #list_click_product_bygroup
select dt,platform_type,user_id,sephora_user_id,op_code,tt2.list_id,tt2.list_name,time
into #list_click_product_bygroup
from(
	select dt,platform_type, t1.user_id, op_code ,t2.sephora_user_id
	,case when t3.group_id is not null then t3.group_id  else 7 end as group_id 
	,time
	from(
		select dt,platform_type, t01.user_id, op_code,time
		from(
				select dt
				,case when lower(platform_type) in ('mini program','miniprogram') then 'mnp'
	  				when lower(platform_type)='app' then 'app' end as platform_type
				,user_id, op_code,time
				from STG_Sensor.V_Events
				where dt =@Update_Date
				and event='ListProductClick'
				and page_type='List-page' 
				and lower(platform_type) in ( 'app','mini program','miniprogram')
			)t01 
		)t1 
	inner join DA_Tagging.id_mapping t2 on t1.user_id=t2.sensor_id
	left join (
				select * from DA_BestSelling.user_group
				where insert_date = (select max(insert_date) from DA_BestSelling.user_group)
				) t3 on t3.user_id = t2.sephora_user_id
)tt1 left outer join (
	select distinct group_id,item_op_cd,list_id,list_name,create_date
	from DA_TopRanking.group_list_prod_t 
	where create_date=convert(date,convert(datetime,@Update_Date)-1)
)tt2 on tt1.group_id=tt2.group_id 
	and tt1.op_code=tt2.item_op_cd collate Chinese_PRC_CS_AI_WS 
;



-- B版用户在plp页面点击产品 by list的人数和次数
if not object_id(N'Tempdb..#by_list_kpi_temp1') is null 
drop table #by_list_kpi_temp1
select distinct tt1.dt,platform_type,list_id, plp2pdp_pv, plp2pdp_uv 
into #by_list_kpi_temp1
 from(
	  select dt,platform_type,list_id,list_name
	  , convert(float,count(0)) as plp2pdp_pv
	  , convert(float,count(distinct user_id)) as plp2pdp_uv
	  from #list_click_product_bygroup
	  group by dt,platform_type,list_id,list_name
)tt1
;

select 10
if not object_id(N'Tempdb..#by_list_kpi_temp2') is null 
drop table #by_list_kpi_temp2
select distinct dt,platform_type, total_plp_pv as total_plp_pv_b
into #by_list_kpi_temp2
from DA_TopRanking.kpi_tracking_totalV2
where dt = @Update_Date
and platform_type in ('app','mnp','total')
;

select 11
update DA_TopRanking.kpi_tracking_bylist
set total_plp_pv_b = t2.total_plp_pv_b
from DA_TopRanking.kpi_tracking_bylist t1
join #by_list_kpi_temp2 t2 
on t1.dt=t2.dt and t1.platform_type=t2.platform_type
;
select 12

-- B版用户在plp页面点击产品后的转化
if not object_id(N'Tempdb..#sameday_view_temp_bylist') is null 
drop table #sameday_view_temp_bylist
select distinct t1.dt,platform_type,t1.user_id,t1.op_code,t2.orderid,list_id,list_name
into #sameday_view_temp_bylist
from(
    select dt,platform_type, time , user_id, op_code,list_id,list_name
    from #list_click_product_bygroup

) t1 
left outer join(
    select dt,time,user_id,orderid
    from STG_Sensor.V_Events
    where event='submitOrder'
    and dt = @Update_Date
    and orderid is not null
    )t2 on t1.user_id=t2.user_id and t1.dt=t2.dt 
where t1.time<t2.time    --浏览后下单
;
select 13


--计算日期当天所有订单数据
if not object_id(N'Tempdb..#sameday_order_temp') is null 
drop table #sameday_order_temp
select t1.sales_order_number,t1.place_time,t2.item_product_id,t1.product_amount
,convert(date,t1.place_time) as place_date
into #sameday_order_temp
from(
    select sales_order_number,product_amount,place_time
    from  [DW_OMS].[V_Sales_Order_Basic_Level]
    where store_cd = 'S001' and is_placed_flag = 1 
    and convert(date,place_time) = @Update_Date
)t1
left outer join(
    select sales_order_number
    ,item_apportion_amount,item_product_id
    from [DW_OMS].[V_Sales_Order_VB_Level]
    where store_cd = 'S001' and is_placed_flag = 1 
    and convert(date,place_time) = @Update_Date
) t2 on t1.sales_order_number = t2.sales_order_number
;
select 14

-- B版用户在plp点击产品后转化的人数 订单数 订单金额
if not object_id(N'Tempdb..#by_list_kpi_temp3') is null 
drop table #by_list_kpi_temp3
select dt,platform_type, list_id
,count(distinct user_id) as converted_uv 
,sum(product_amount) as converted_sales 
into #by_list_kpi_temp3
from(
	select distinct dt,platform_type,user_id,sales_order_number,product_amount,list_id
	from #sameday_view_temp_bylist t1 
	left outer join #sameday_order_temp t2 on t1.op_code  COLLATE SQL_Latin1_General_CP1_CI_AS=t2.item_product_id and t1.orderid  COLLATE SQL_Latin1_General_CP1_CI_AS=t2.sales_order_number
	where t2.sales_order_number is not null
)tt1 group by dt,platform_type, list_id
;
select 15


-- B版用户在plp页面点击产品后的加购
if not object_id(N'Tempdb..#sameday_add_temp_bylist') is null 
drop table #sameday_add_temp_bylist
select distinct t1.dt,platform_type,t1.user_id,t1.op_code,list_id,list_name
into #sameday_add_temp_bylist
from(
    select dt,platform_type, time , user_id, op_code,list_id,list_name
    from #list_click_product_bygroup

) t1 
left outer join(
		select dt,time,user_id,op_code
		from STG_Sensor.V_Events
		where dt = @Update_Date
		and event='addToShoppingcart'
		and lower(platform_type) = 'app'
		and op_code is not null 
    )t2 on t1.user_id=t2.user_id and t1.dt=t2.dt and t1.op_code=t2.op_code
where t1.time<t2.time    --浏览后
;
select 16

if not object_id(N'Tempdb..#by_list_kpi_temp4') is null 
drop table #by_list_kpi_temp4
select dt,platform_type,list_id
,count(distinct user_id) as add2Cart_uv
into #by_list_kpi_temp4
from #sameday_add_temp_bylist
group by dt,platform_type,list_id
;
select 17

if not object_id(N'Tempdb..#by_list_kpi_temp5') is null 
drop table #by_list_kpi_temp5
select t1.dt,t1.platform_type,t1.list_id,t2.total_plp_pv_b, t1.plp2pdp_pv, t1.plp2pdp_uv ,t3.converted_uv,t3.converted_sales,t4.add2Cart_uv
into #by_list_kpi_temp5
from #by_list_kpi_temp1 t1
left join #by_list_kpi_temp2 t2 on t1.dt=t2.dt collate Chinese_PRC_CS_AI_WS and t1.platform_type=t2.platform_type collate Chinese_PRC_CS_AI_WS
left join #by_list_kpi_temp3 t3 on t1.dt=t3.dt and t1.list_id = t3.list_id and t1.platform_type=t3.platform_type 
left join #by_list_kpi_temp4 t4 on t1.dt=t4.dt and t1.list_id = t4.list_id and t1.platform_type=t4.platform_type 
where t1.list_id is not null
;


select 18

update DA_TopRanking.kpi_tracking_bylist
set plp2pdp_uv1=  isnull(t2.[1],0) ,plp2pdp_uv2 = isnull(t2.[2],0), plp2pdp_uv3 = isnull(t2.[3],0),plp2pdp_uv4 = isnull(t2.[4],0), plp2pdp_uv5=isnull(t2.[5],0),plp2pdp_uv6 = isnull(t2.[6],0),plp2pdp_uv7 = isnull(t2.[7],0),plp2pdp_uv8 = isnull(t2.[8],0)
,   plp2pdp_uv9=  isnull(t2.[9],0) ,plp2pdp_uv10 = isnull(t2.[10],0), plp2pdp_uv11 = isnull(t2.[11],0),plp2pdp_uv12 = isnull(t2.[12],0), plp2pdp_uv13=isnull(t2.[13],0),plp2pdp_uv14 = isnull(t2.[14],0),plp2pdp_uv15 = isnull(t2.[15],0),plp2pdp_uv16 = isnull(t2.[16],0)
,   plp2pdp_uv17=  isnull(t2.[17],0) ,plp2pdp_uv18 = isnull(t2.[18],0), plp2pdp_uv19 = isnull(t2.[19],0),plp2pdp_uv20 = isnull(t2.[20],0), plp2pdp_uv21=isnull(t2.[21],0),plp2pdp_uv22 = isnull(t2.[22],0),plp2pdp_uv23 = isnull(t2.[23],0),plp2pdp_uv24 = isnull(t2.[24],0)
,   plp2pdp_uv25=  isnull(t2.[25],0) ,plp2pdp_uv26 = isnull(t2.[26],0), plp2pdp_uv27 = isnull(t2.[27],0),plp2pdp_uv28 = isnull(t2.[28],0), plp2pdp_uv29=isnull(t2.[29],0),plp2pdp_uv30 = isnull(t2.[30],0),plp2pdp_uv31 = isnull(t2.[31],0),plp2pdp_uv32 = isnull(t2.[32],0)
,   plp2pdp_uv33=  isnull(t2.[33],0) ,plp2pdp_uv34 = isnull(t2.[34],0), plp2pdp_uv35 = isnull(t2.[35],0),plp2pdp_uv36 = isnull(t2.[36],0), plp2pdp_uv37=isnull(t2.[37],0),plp2pdp_uv38 = isnull(t2.[38],0),plp2pdp_uv39 = isnull(t2.[39],0),plp2pdp_uv40 = isnull(t2.[40],0)
,   plp2pdp_uv41=  isnull(t2.[41],0) ,plp2pdp_uv42 = isnull(t2.[42],0), plp2pdp_uv43 = isnull(t2.[43],0),plp2pdp_uv44 = isnull(t2.[44],0), plp2pdp_uv45=isnull(t2.[45],0),plp2pdp_uv46 = isnull(t2.[46],0),plp2pdp_uv47 = isnull(t2.[47],0),plp2pdp_uv48 = isnull(t2.[48],0)
,   plp2pdp_uv49=  isnull(t2.[49],0) ,plp2pdp_uv50 = isnull(t2.[50],0), plp2pdp_uv51 = isnull(t2.[51],0),plp2pdp_uv52 = isnull(t2.[52],0), plp2pdp_uv53=isnull(t2.[53],0),plp2pdp_uv54 = isnull(t2.[54],0),plp2pdp_uv55 = isnull(t2.[55],0),plp2pdp_uv56 = isnull(t2.[56],0)
,   plp2pdp_uv57=  isnull(t2.[57],0) ,plp2pdp_uv58 = isnull(t2.[58],0), plp2pdp_uv59 = isnull(t2.[59],0),plp2pdp_uv60 = isnull(t2.[60],0), plp2pdp_uv61=isnull(t2.[61],0),plp2pdp_uv62 = isnull(t2.[62],0),plp2pdp_uv63 = isnull(t2.[63],0),plp2pdp_uv64 = isnull(t2.[64],0)
,   plp2pdp_uv65=  isnull(t2.[65],0) ,plp2pdp_uv66 = isnull(t2.[66],0), plp2pdp_uv67 = isnull(t2.[67],0),plp2pdp_uv68 = isnull(t2.[68],0), plp2pdp_uv69=isnull(t2.[69],0),plp2pdp_uv70 = isnull(t2.[70],0),plp2pdp_uv71 = isnull(t2.[71],0),plp2pdp_uv72 = isnull(t2.[72],0)
,   plp2pdp_uv73=  isnull(t2.[73],0) ,plp2pdp_uv74 = isnull(t2.[74],0), plp2pdp_uv75 = isnull(t2.[75],0),plp2pdp_uv76 = isnull(t2.[76],0), plp2pdp_uv77=isnull(t2.[77],0),plp2pdp_uv78 = isnull(t2.[78],0),plp2pdp_uv79 = isnull(t2.[79],0),plp2pdp_uv80 = isnull(t2.[80],0)
,   plp2pdp_uv81=  isnull(t2.[81],0) ,plp2pdp_uv82 = isnull(t2.[82],0), plp2pdp_uv83 = isnull(t2.[83],0),plp2pdp_uv84 = isnull(t2.[84],0), plp2pdp_uv85=isnull(t2.[85],0),plp2pdp_uv86 = isnull(t2.[86],0),plp2pdp_uv87 = isnull(t2.[87],0),plp2pdp_uv88 = isnull(t2.[88],0)
,   plp2pdp_uv89=  isnull(t2.[89],0) ,plp2pdp_uv90 = isnull(t2.[90],0), plp2pdp_uv91 = isnull(t2.[91],0),plp2pdp_uv92 = isnull(t2.[92],0), plp2pdp_uv93=isnull(t2.[93],0),plp2pdp_uv94 = isnull(t2.[94],0),plp2pdp_uv95 = isnull(t2.[95],0),plp2pdp_uv96 = isnull(t2.[96],0)
,   plp2pdp_uv97=  isnull(t2.[97],0)
from DA_TopRanking.kpi_tracking_bylist t1
join(
	select * from(
		select dt,platform_type,list_id, plp2pdp_uv
		from #by_list_kpi_temp5
		)t  PIVOT (
		  max(plp2pdp_uv) for list_id in (
	  		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30]
	  		,[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52],[53],[54]
			,[55],[56],[57],[58],[59],[60],[61],[62],[63],[64],[65],[66],[67],[68],[69],[70],[71],[72],[73],[74],[75],[76],[77],[78]
			,[79],[80],[81],[82],[83],[84],[85],[86],[87],[88],[89],[90],[91],[92],[93],[94],[95],[96],[97]
		  )
		)b
)t2 on t1.dt = t2.dt and t1.platform_type=t2.platform_type collate Chinese_PRC_CS_AI_WS
;

select 19

update DA_TopRanking.kpi_tracking_bylist
set plp2pdp_pv1=  isnull(t2.[1],0) ,plp2pdp_pv2 = isnull(t2.[2],0), plp2pdp_pv3 = isnull(t2.[3],0),plp2pdp_pv4 = isnull(t2.[4],0), plp2pdp_pv5=isnull(t2.[5],0),plp2pdp_pv6 = isnull(t2.[6],0),plp2pdp_pv7 = isnull(t2.[7],0),plp2pdp_pv8 = isnull(t2.[8],0)
,   plp2pdp_pv9=  isnull(t2.[9],0) ,plp2pdp_pv10 = isnull(t2.[10],0), plp2pdp_pv11 = isnull(t2.[11],0),plp2pdp_pv12 = isnull(t2.[12],0), plp2pdp_pv13=isnull(t2.[13],0),plp2pdp_pv14 = isnull(t2.[14],0),plp2pdp_pv15 = isnull(t2.[15],0),plp2pdp_pv16 = isnull(t2.[16],0)
,   plp2pdp_pv17=  isnull(t2.[17],0) ,plp2pdp_pv18 = isnull(t2.[18],0), plp2pdp_pv19 = isnull(t2.[19],0),plp2pdp_pv20 = isnull(t2.[20],0), plp2pdp_pv21=isnull(t2.[21],0),plp2pdp_pv22 = isnull(t2.[22],0),plp2pdp_pv23 = isnull(t2.[23],0),plp2pdp_pv24 = isnull(t2.[24],0)
,   plp2pdp_pv25=  isnull(t2.[25],0) ,plp2pdp_pv26 = isnull(t2.[26],0), plp2pdp_pv27 = isnull(t2.[27],0),plp2pdp_pv28 = isnull(t2.[28],0), plp2pdp_pv29=isnull(t2.[29],0),plp2pdp_pv30 = isnull(t2.[30],0),plp2pdp_pv31 = isnull(t2.[31],0),plp2pdp_pv32 = isnull(t2.[32],0)
,   plp2pdp_pv33=  isnull(t2.[33],0) ,plp2pdp_pv34 = isnull(t2.[34],0), plp2pdp_pv35 = isnull(t2.[35],0),plp2pdp_pv36 = isnull(t2.[36],0), plp2pdp_pv37=isnull(t2.[37],0),plp2pdp_pv38 = isnull(t2.[38],0),plp2pdp_pv39 = isnull(t2.[39],0),plp2pdp_pv40 = isnull(t2.[40],0)
,   plp2pdp_pv41=  isnull(t2.[41],0) ,plp2pdp_pv42 = isnull(t2.[42],0), plp2pdp_pv43 = isnull(t2.[43],0),plp2pdp_pv44 = isnull(t2.[44],0), plp2pdp_pv45=isnull(t2.[45],0),plp2pdp_pv46 = isnull(t2.[46],0),plp2pdp_pv47 = isnull(t2.[47],0),plp2pdp_pv48 = isnull(t2.[48],0)
,   plp2pdp_pv49=  isnull(t2.[49],0) ,plp2pdp_pv50 = isnull(t2.[50],0), plp2pdp_pv51 = isnull(t2.[51],0),plp2pdp_pv52 = isnull(t2.[52],0), plp2pdp_pv53=isnull(t2.[53],0),plp2pdp_pv54 = isnull(t2.[54],0),plp2pdp_pv55 = isnull(t2.[55],0),plp2pdp_pv56 = isnull(t2.[56],0)
,   plp2pdp_pv57=  isnull(t2.[57],0) ,plp2pdp_pv58 = isnull(t2.[58],0), plp2pdp_pv59 = isnull(t2.[59],0),plp2pdp_pv60 = isnull(t2.[60],0), plp2pdp_pv61=isnull(t2.[61],0),plp2pdp_pv62 = isnull(t2.[62],0),plp2pdp_pv63 = isnull(t2.[63],0),plp2pdp_pv64 = isnull(t2.[64],0)
,   plp2pdp_pv65=  isnull(t2.[65],0) ,plp2pdp_pv66 = isnull(t2.[66],0), plp2pdp_pv67 = isnull(t2.[67],0),plp2pdp_pv68 = isnull(t2.[68],0), plp2pdp_pv69=isnull(t2.[69],0),plp2pdp_pv70 = isnull(t2.[70],0),plp2pdp_pv71 = isnull(t2.[71],0),plp2pdp_pv72 = isnull(t2.[72],0)
,   plp2pdp_pv73=  isnull(t2.[73],0) ,plp2pdp_pv74 = isnull(t2.[74],0), plp2pdp_pv75 = isnull(t2.[75],0),plp2pdp_pv76 = isnull(t2.[76],0), plp2pdp_pv77=isnull(t2.[77],0),plp2pdp_pv78 = isnull(t2.[78],0),plp2pdp_pv79 = isnull(t2.[79],0),plp2pdp_pv80 = isnull(t2.[80],0)
,   plp2pdp_pv81=  isnull(t2.[81],0) ,plp2pdp_pv82 = isnull(t2.[82],0), plp2pdp_pv83 = isnull(t2.[83],0),plp2pdp_pv84 = isnull(t2.[84],0), plp2pdp_pv85=isnull(t2.[85],0),plp2pdp_pv86 = isnull(t2.[86],0),plp2pdp_pv87 = isnull(t2.[87],0),plp2pdp_pv88 = isnull(t2.[88],0)
,   plp2pdp_pv89=  isnull(t2.[89],0) ,plp2pdp_pv90 = isnull(t2.[90],0), plp2pdp_pv91 = isnull(t2.[91],0),plp2pdp_pv92 = isnull(t2.[92],0), plp2pdp_pv93=isnull(t2.[93],0),plp2pdp_pv94 = isnull(t2.[94],0),plp2pdp_pv95 = isnull(t2.[95],0),plp2pdp_pv96 = isnull(t2.[96],0)
,   plp2pdp_pv97=  isnull(t2.[97],0) 
from DA_TopRanking.kpi_tracking_bylist t1
join(
	select * from(
		select dt,platform_type,list_id, plp2pdp_pv
		from #by_list_kpi_temp5
		)t  PIVOT (
		  max(plp2pdp_pv) for list_id in (
	  		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30]
	  		,[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52],[53],[54]
			,[55],[56],[57],[58],[59],[60],[61],[62],[63],[64],[65],[66],[67],[68],[69],[70],[71],[72],[73],[74],[75],[76],[77],[78]
			,[79],[80],[81],[82],[83],[84],[85],[86],[87],[88],[89],[90],[91],[92],[93],[94],[95],[96],[97]
		  )
		)b
)t2 on t1.dt = t2.dt and t1.platform_type=t2.platform_type collate Chinese_PRC_CS_AI_WS
;

select 20
update DA_TopRanking.kpi_tracking_bylist
set add_to_cart_uv1=  isnull(t2.[1],0) ,add_to_cart_uv2 = isnull(t2.[2],0), add_to_cart_uv3 = isnull(t2.[3],0),add_to_cart_uv4 = isnull(t2.[4],0), add_to_cart_uv5=isnull(t2.[5],0),add_to_cart_uv6 = isnull(t2.[6],0),add_to_cart_uv7 = isnull(t2.[7],0),add_to_cart_uv8 = isnull(t2.[8],0)
,   add_to_cart_uv9=  isnull(t2.[9],0) ,add_to_cart_uv10 = isnull(t2.[10],0), add_to_cart_uv11 = isnull(t2.[11],0),add_to_cart_uv12 = isnull(t2.[12],0), add_to_cart_uv13=isnull(t2.[13],0),add_to_cart_uv14 = isnull(t2.[14],0),add_to_cart_uv15 = isnull(t2.[15],0),add_to_cart_uv16 = isnull(t2.[16],0)
,   add_to_cart_uv17=  isnull(t2.[17],0) ,add_to_cart_uv18 = isnull(t2.[18],0), add_to_cart_uv19 = isnull(t2.[19],0),add_to_cart_uv20 = isnull(t2.[20],0), add_to_cart_uv21=isnull(t2.[21],0),add_to_cart_uv22 = isnull(t2.[22],0),add_to_cart_uv23 = isnull(t2.[23],0),add_to_cart_uv24 = isnull(t2.[24],0)
,   add_to_cart_uv25=  isnull(t2.[25],0) ,add_to_cart_uv26 = isnull(t2.[26],0), add_to_cart_uv27 = isnull(t2.[27],0),add_to_cart_uv28 = isnull(t2.[28],0), add_to_cart_uv29=isnull(t2.[29],0),add_to_cart_uv30 = isnull(t2.[30],0),add_to_cart_uv31 = isnull(t2.[31],0),add_to_cart_uv32 = isnull(t2.[32],0)
,   add_to_cart_uv33=  isnull(t2.[33],0) ,add_to_cart_uv34 = isnull(t2.[34],0), add_to_cart_uv35 = isnull(t2.[35],0),add_to_cart_uv36 = isnull(t2.[36],0), add_to_cart_uv37=isnull(t2.[37],0),add_to_cart_uv38 = isnull(t2.[38],0),add_to_cart_uv39 = isnull(t2.[39],0),add_to_cart_uv40 = isnull(t2.[40],0)
,   add_to_cart_uv41=  isnull(t2.[41],0) ,add_to_cart_uv42 = isnull(t2.[42],0), add_to_cart_uv43 = isnull(t2.[43],0),add_to_cart_uv44 = isnull(t2.[44],0), add_to_cart_uv45=isnull(t2.[45],0),add_to_cart_uv46 = isnull(t2.[46],0),add_to_cart_uv47 = isnull(t2.[47],0),add_to_cart_uv48 = isnull(t2.[48],0)
,   add_to_cart_uv49=  isnull(t2.[49],0) ,add_to_cart_uv50 = isnull(t2.[50],0), add_to_cart_uv51 = isnull(t2.[51],0),add_to_cart_uv52 = isnull(t2.[52],0), add_to_cart_uv53=isnull(t2.[53],0),add_to_cart_uv54 = isnull(t2.[54],0),add_to_cart_uv55 = isnull(t2.[55],0),add_to_cart_uv56 = isnull(t2.[56],0)
,   add_to_cart_uv57=  isnull(t2.[57],0) ,add_to_cart_uv58 = isnull(t2.[58],0), add_to_cart_uv59 = isnull(t2.[59],0),add_to_cart_uv60 = isnull(t2.[60],0), add_to_cart_uv61=isnull(t2.[61],0),add_to_cart_uv62 = isnull(t2.[62],0),add_to_cart_uv63 = isnull(t2.[63],0),add_to_cart_uv64 = isnull(t2.[64],0)
,   add_to_cart_uv65=  isnull(t2.[65],0) ,add_to_cart_uv66 = isnull(t2.[66],0), add_to_cart_uv67 = isnull(t2.[67],0),add_to_cart_uv68 = isnull(t2.[68],0), add_to_cart_uv69=isnull(t2.[69],0),add_to_cart_uv70 = isnull(t2.[70],0),add_to_cart_uv71 = isnull(t2.[71],0),add_to_cart_uv72 = isnull(t2.[72],0)
,   add_to_cart_uv73=  isnull(t2.[73],0) ,add_to_cart_uv74 = isnull(t2.[74],0), add_to_cart_uv75 = isnull(t2.[75],0),add_to_cart_uv76 = isnull(t2.[76],0), add_to_cart_uv77=isnull(t2.[77],0),add_to_cart_uv78 = isnull(t2.[78],0),add_to_cart_uv79 = isnull(t2.[79],0),add_to_cart_uv80 = isnull(t2.[80],0)
,   add_to_cart_uv81=  isnull(t2.[81],0) ,add_to_cart_uv82 = isnull(t2.[82],0), add_to_cart_uv83 = isnull(t2.[83],0),add_to_cart_uv84 = isnull(t2.[84],0), add_to_cart_uv85=isnull(t2.[85],0),add_to_cart_uv86 = isnull(t2.[86],0),add_to_cart_uv87 = isnull(t2.[87],0),add_to_cart_uv88 = isnull(t2.[88],0)
,   add_to_cart_uv89=  isnull(t2.[89],0) ,add_to_cart_uv90 = isnull(t2.[90],0), add_to_cart_uv91 = isnull(t2.[91],0),add_to_cart_uv92 = isnull(t2.[92],0), add_to_cart_uv93=isnull(t2.[93],0),add_to_cart_uv94 = isnull(t2.[94],0),add_to_cart_uv95 = isnull(t2.[95],0),add_to_cart_uv96 = isnull(t2.[96],0)
,   add_to_cart_uv97=  isnull(t2.[97],0) 
from DA_TopRanking.kpi_tracking_bylist t1
join(
	select * from(
		select dt,platform_type,list_id, add2cart_uv
		from #by_list_kpi_temp5
		)t  PIVOT (
		  max(add2cart_uv) for list_id in (
	  		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30]
	  		,[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52],[53],[54]
			,[55],[56],[57],[58],[59],[60],[61],[62],[63],[64],[65],[66],[67],[68],[69],[70],[71],[72],[73],[74],[75],[76],[77],[78]
			,[79],[80],[81],[82],[83],[84],[85],[86],[87],[88],[89],[90],[91],[92],[93],[94],[95],[96],[97]
		  )
		)b
)t2 on t1.dt = t2.dt and t1.platform_type=t2.platform_type collate Chinese_PRC_CS_AI_WS
;
select 21
update DA_TopRanking.kpi_tracking_bylist
set converted_uv1=  isnull(t2.[1],0) ,converted_uv2 = isnull(t2.[2],0), converted_uv3 = isnull(t2.[3],0),converted_uv4 = isnull(t2.[4],0), converted_uv5=isnull(t2.[5],0),converted_uv6 = isnull(t2.[6],0),converted_uv7 = isnull(t2.[7],0),converted_uv8 = isnull(t2.[8],0)
,   converted_uv9=  isnull(t2.[9],0) ,converted_uv10 = isnull(t2.[10],0), converted_uv11 = isnull(t2.[11],0),converted_uv12 = isnull(t2.[12],0), converted_uv13=isnull(t2.[13],0),converted_uv14 = isnull(t2.[14],0),converted_uv15 = isnull(t2.[15],0),converted_uv16 = isnull(t2.[16],0)
,   converted_uv17=  isnull(t2.[17],0) ,converted_uv18 = isnull(t2.[18],0), converted_uv19 = isnull(t2.[19],0),converted_uv20 = isnull(t2.[20],0), converted_uv21=isnull(t2.[21],0),converted_uv22 = isnull(t2.[22],0),converted_uv23 = isnull(t2.[23],0),converted_uv24 = isnull(t2.[24],0)
,   converted_uv25=  isnull(t2.[25],0) ,converted_uv26 = isnull(t2.[26],0), converted_uv27 = isnull(t2.[27],0),converted_uv28 = isnull(t2.[28],0), converted_uv29=isnull(t2.[29],0),converted_uv30 = isnull(t2.[30],0),converted_uv31 = isnull(t2.[31],0),converted_uv32 = isnull(t2.[32],0)
,   converted_uv33=  isnull(t2.[33],0) ,converted_uv34 = isnull(t2.[34],0), converted_uv35 = isnull(t2.[35],0),converted_uv36 = isnull(t2.[36],0), converted_uv37=isnull(t2.[37],0),converted_uv38 = isnull(t2.[38],0),converted_uv39 = isnull(t2.[39],0),converted_uv40 = isnull(t2.[40],0)
,   converted_uv41=  isnull(t2.[41],0) ,converted_uv42 = isnull(t2.[42],0), converted_uv43 = isnull(t2.[43],0),converted_uv44 = isnull(t2.[44],0), converted_uv45=isnull(t2.[45],0),converted_uv46 = isnull(t2.[46],0),converted_uv47 = isnull(t2.[47],0),converted_uv48 = isnull(t2.[48],0)
,   converted_uv49=  isnull(t2.[49],0) ,converted_uv50 = isnull(t2.[50],0), converted_uv51 = isnull(t2.[51],0),converted_uv52 = isnull(t2.[52],0), converted_uv53=isnull(t2.[53],0),converted_uv54 = isnull(t2.[54],0),converted_uv55 = isnull(t2.[55],0),converted_uv56 = isnull(t2.[56],0)
,   converted_uv57=  isnull(t2.[57],0) ,converted_uv58 = isnull(t2.[58],0), converted_uv59 = isnull(t2.[59],0),converted_uv60 = isnull(t2.[60],0), converted_uv61=isnull(t2.[61],0),converted_uv62 = isnull(t2.[62],0),converted_uv63 = isnull(t2.[63],0),converted_uv64 = isnull(t2.[64],0)
,   converted_uv65=  isnull(t2.[65],0) ,converted_uv66 = isnull(t2.[66],0), converted_uv67 = isnull(t2.[67],0),converted_uv68 = isnull(t2.[68],0), converted_uv69=isnull(t2.[69],0),converted_uv70 = isnull(t2.[70],0),converted_uv71 = isnull(t2.[71],0),converted_uv72 = isnull(t2.[72],0)
,   converted_uv73=  isnull(t2.[73],0) ,converted_uv74 = isnull(t2.[74],0), converted_uv75 = isnull(t2.[75],0),converted_uv76 = isnull(t2.[76],0), converted_uv77=isnull(t2.[77],0),converted_uv78 = isnull(t2.[78],0),converted_uv79 = isnull(t2.[79],0),converted_uv80 = isnull(t2.[80],0)
,   converted_uv81=  isnull(t2.[81],0) ,converted_uv82 = isnull(t2.[82],0), converted_uv83 = isnull(t2.[83],0),converted_uv84 = isnull(t2.[84],0), converted_uv85=isnull(t2.[85],0),converted_uv86 = isnull(t2.[86],0),converted_uv87 = isnull(t2.[87],0),converted_uv88 = isnull(t2.[88],0)
,   converted_uv89=  isnull(t2.[89],0) ,converted_uv90 = isnull(t2.[90],0), converted_uv91 = isnull(t2.[91],0),converted_uv92 = isnull(t2.[92],0), converted_uv93=isnull(t2.[93],0),converted_uv94 = isnull(t2.[94],0),converted_uv95 = isnull(t2.[95],0),converted_uv96 = isnull(t2.[96],0)
,   converted_uv97=  isnull(t2.[97],0) 
from DA_TopRanking.kpi_tracking_bylist t1
join(
	select * from(
		select dt,platform_type,list_id, converted_uv
		from #by_list_kpi_temp5
		)t  PIVOT (
		   max(converted_uv) for list_id in (
	  		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30]
	  		,[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52],[53],[54]
			,[55],[56],[57],[58],[59],[60],[61],[62],[63],[64],[65],[66],[67],[68],[69],[70],[71],[72],[73],[74],[75],[76],[77],[78]
			,[79],[80],[81],[82],[83],[84],[85],[86],[87],[88],[89],[90],[91],[92],[93],[94],[95],[96],[97]
		  )
		)b
)t2 on t1.dt = t2.dt and t1.platform_type=t2.platform_type collate Chinese_PRC_CS_AI_WS
;
select 22
update DA_TopRanking.kpi_tracking_bylist
set converted_sales1=  isnull(t2.[1],0) ,converted_sales2 = isnull(t2.[2],0), converted_sales3 = isnull(t2.[3],0),converted_sales4 = isnull(t2.[4],0), converted_sales5=isnull(t2.[5],0),converted_sales6 = isnull(t2.[6],0),converted_sales7 = isnull(t2.[7],0),converted_sales8 = isnull(t2.[8],0)
,   converted_sales9=  isnull(t2.[9],0) ,converted_sales10 = isnull(t2.[10],0), converted_sales11 = isnull(t2.[11],0),converted_sales12 = isnull(t2.[12],0), converted_sales13=isnull(t2.[13],0),converted_sales14 = isnull(t2.[14],0),converted_sales15 = isnull(t2.[15],0),converted_sales16 = isnull(t2.[16],0)
,   converted_sales17=  isnull(t2.[17],0) ,converted_sales18 = isnull(t2.[18],0), converted_sales19 = isnull(t2.[19],0),converted_sales20 = isnull(t2.[20],0), converted_sales21=isnull(t2.[21],0),converted_sales22 = isnull(t2.[22],0),converted_sales23 = isnull(t2.[23],0),converted_sales24 = isnull(t2.[24],0)
,   converted_sales25=  isnull(t2.[25],0) ,converted_sales26 = isnull(t2.[26],0), converted_sales27 = isnull(t2.[27],0),converted_sales28 = isnull(t2.[28],0), converted_sales29=isnull(t2.[29],0),converted_sales30 = isnull(t2.[30],0),converted_sales31 = isnull(t2.[31],0),converted_sales32 = isnull(t2.[32],0)
,   converted_sales33=  isnull(t2.[33],0) ,converted_sales34 = isnull(t2.[34],0), converted_sales35 = isnull(t2.[35],0),converted_sales36 = isnull(t2.[36],0), converted_sales37=isnull(t2.[37],0),converted_sales38 = isnull(t2.[38],0),converted_sales39 = isnull(t2.[39],0),converted_sales40 = isnull(t2.[40],0)
,   converted_sales41=  isnull(t2.[41],0) ,converted_sales42 = isnull(t2.[42],0), converted_sales43 = isnull(t2.[43],0),converted_sales44 = isnull(t2.[44],0), converted_sales45=isnull(t2.[45],0),converted_sales46 = isnull(t2.[46],0),converted_sales47 = isnull(t2.[47],0),converted_sales48 = isnull(t2.[48],0)
,   converted_sales49=  isnull(t2.[49],0) ,converted_sales50 = isnull(t2.[50],0), converted_sales51 = isnull(t2.[51],0),converted_sales52 = isnull(t2.[52],0), converted_sales53=isnull(t2.[53],0),converted_sales54 = isnull(t2.[54],0),converted_sales55 = isnull(t2.[55],0),converted_sales56 = isnull(t2.[56],0)
,   converted_sales57=  isnull(t2.[57],0) ,converted_sales58 = isnull(t2.[58],0), converted_sales59 = isnull(t2.[59],0),converted_sales60 = isnull(t2.[60],0), converted_sales61=isnull(t2.[61],0),converted_sales62 = isnull(t2.[62],0),converted_sales63 = isnull(t2.[63],0),converted_sales64 = isnull(t2.[64],0)
,   converted_sales65=  isnull(t2.[65],0) ,converted_sales66 = isnull(t2.[66],0), converted_sales67 = isnull(t2.[67],0),converted_sales68 = isnull(t2.[68],0), converted_sales69=isnull(t2.[69],0),converted_sales70 = isnull(t2.[70],0),converted_sales71 = isnull(t2.[71],0),converted_sales72 = isnull(t2.[72],0)
,   converted_sales73=  isnull(t2.[73],0) ,converted_sales74 = isnull(t2.[74],0), converted_sales75 = isnull(t2.[75],0),converted_sales76 = isnull(t2.[76],0), converted_sales77=isnull(t2.[77],0),converted_sales78 = isnull(t2.[78],0),converted_sales79 = isnull(t2.[79],0),converted_sales80 = isnull(t2.[80],0)
,   converted_sales81=  isnull(t2.[81],0) ,converted_sales82 = isnull(t2.[82],0), converted_sales83 = isnull(t2.[83],0),converted_sales84 = isnull(t2.[84],0), converted_sales85=isnull(t2.[85],0),converted_sales86 = isnull(t2.[86],0),converted_sales87 = isnull(t2.[87],0),converted_sales88 = isnull(t2.[88],0)
,   converted_sales89=  isnull(t2.[89],0) ,converted_sales90 = isnull(t2.[90],0), converted_sales91 = isnull(t2.[91],0),converted_sales92 = isnull(t2.[92],0), converted_sales93=isnull(t2.[93],0),converted_sales94 = isnull(t2.[94],0),converted_sales95 = isnull(t2.[95],0),converted_sales96 = isnull(t2.[96],0)
,   converted_sales97=  isnull(t2.[97],0) 
from DA_TopRanking.kpi_tracking_bylist t1
join(
	select * from(
		select dt,platform_type,list_id, converted_sales
		from #by_list_kpi_temp5
		)t  PIVOT (
		   max(converted_sales) for list_id in (
	  		[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30]
	  		,[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48],[49],[50],[51],[52],[53],[54]
			,[55],[56],[57],[58],[59],[60],[61],[62],[63],[64],[65],[66],[67],[68],[69],[70],[71],[72],[73],[74],[75],[76],[77],[78]
			,[79],[80],[81],[82],[83],[84],[85],[86],[87],[88],[89],[90],[91],[92],[93],[94],[95],[96],[97]
		  )
		)b
)t2 on t1.dt = t2.dt and t1.platform_type=t2.platform_type collate Chinese_PRC_CS_AI_WS
;

select 23
if not object_id(N'Tempdb..#temp1') is null 
drop table #temp1
select dt
 ,sum(total_plp_pv_b) as total_plp_pv_b ,sum(add_to_cart_uv1) as add_to_cart_uv1 ,sum(add_to_cart_uv10) as add_to_cart_uv10 ,sum(add_to_cart_uv11) as add_to_cart_uv11 ,sum(add_to_cart_uv12) as add_to_cart_uv12 ,sum(add_to_cart_uv13) as add_to_cart_uv13 ,sum(add_to_cart_uv14) as add_to_cart_uv14 
 ,sum(add_to_cart_uv15) as add_to_cart_uv15 ,sum(add_to_cart_uv16) as add_to_cart_uv16 ,sum(add_to_cart_uv17) as add_to_cart_uv17 ,sum(add_to_cart_uv18) as add_to_cart_uv18 ,sum(add_to_cart_uv19) as add_to_cart_uv19 ,sum(add_to_cart_uv2) as add_to_cart_uv2 ,sum(add_to_cart_uv20) as add_to_cart_uv20 
 ,sum(add_to_cart_uv21) as add_to_cart_uv21 ,sum(add_to_cart_uv22) as add_to_cart_uv22 ,sum(add_to_cart_uv23) as add_to_cart_uv23 ,sum(add_to_cart_uv24) as add_to_cart_uv24 ,sum(add_to_cart_uv25) as add_to_cart_uv25 ,sum(add_to_cart_uv26) as add_to_cart_uv26 ,sum(add_to_cart_uv27) as add_to_cart_uv27 
 ,sum(add_to_cart_uv28) as add_to_cart_uv28 ,sum(add_to_cart_uv29) as add_to_cart_uv29 ,sum(add_to_cart_uv3) as add_to_cart_uv3 ,sum(add_to_cart_uv30) as add_to_cart_uv30 ,sum(add_to_cart_uv31) as add_to_cart_uv31 ,sum(add_to_cart_uv32) as add_to_cart_uv32 ,sum(add_to_cart_uv33) as add_to_cart_uv33 
 ,sum(add_to_cart_uv34) as add_to_cart_uv34 ,sum(add_to_cart_uv35) as add_to_cart_uv35 ,sum(add_to_cart_uv36) as add_to_cart_uv36 ,sum(add_to_cart_uv37) as add_to_cart_uv37 ,sum(add_to_cart_uv38) as add_to_cart_uv38 ,sum(add_to_cart_uv39) as add_to_cart_uv39 ,sum(add_to_cart_uv4) as add_to_cart_uv4 
 ,sum(add_to_cart_uv40) as add_to_cart_uv40 ,sum(add_to_cart_uv41) as add_to_cart_uv41 ,sum(add_to_cart_uv42) as add_to_cart_uv42 ,sum(add_to_cart_uv43) as add_to_cart_uv43 ,sum(add_to_cart_uv44) as add_to_cart_uv44 ,sum(add_to_cart_uv45) as add_to_cart_uv45 ,sum(add_to_cart_uv46) as add_to_cart_uv46 
 ,sum(add_to_cart_uv47) as add_to_cart_uv47 ,sum(add_to_cart_uv48) as add_to_cart_uv48 ,sum(add_to_cart_uv49) as add_to_cart_uv49 ,sum(add_to_cart_uv5) as add_to_cart_uv5 ,sum(add_to_cart_uv50) as add_to_cart_uv50 ,sum(add_to_cart_uv51) as add_to_cart_uv51 ,sum(add_to_cart_uv52) as add_to_cart_uv52 
 ,sum(add_to_cart_uv53) as add_to_cart_uv53 ,sum(add_to_cart_uv54) as add_to_cart_uv54 ,sum(add_to_cart_uv55) as add_to_cart_uv55 ,sum(add_to_cart_uv56) as add_to_cart_uv56 ,sum(add_to_cart_uv57) as add_to_cart_uv57 ,sum(add_to_cart_uv58) as add_to_cart_uv58 ,sum(add_to_cart_uv59) as add_to_cart_uv59 
 ,sum(add_to_cart_uv6) as add_to_cart_uv6 ,sum(add_to_cart_uv60) as add_to_cart_uv60 ,sum(add_to_cart_uv61) as add_to_cart_uv61 ,sum(add_to_cart_uv62) as add_to_cart_uv62 ,sum(add_to_cart_uv63) as add_to_cart_uv63 ,sum(add_to_cart_uv64) as add_to_cart_uv64 ,sum(add_to_cart_uv65) as add_to_cart_uv65 
 ,sum(add_to_cart_uv66) as add_to_cart_uv66 ,sum(add_to_cart_uv67) as add_to_cart_uv67 ,sum(add_to_cart_uv68) as add_to_cart_uv68 ,sum(add_to_cart_uv69) as add_to_cart_uv69 ,sum(add_to_cart_uv7) as add_to_cart_uv7 ,sum(add_to_cart_uv70) as add_to_cart_uv70 ,sum(add_to_cart_uv71) as add_to_cart_uv71 
 ,sum(add_to_cart_uv72) as add_to_cart_uv72 ,sum(add_to_cart_uv73) as add_to_cart_uv73 ,sum(add_to_cart_uv74) as add_to_cart_uv74 ,sum(add_to_cart_uv75) as add_to_cart_uv75 ,sum(add_to_cart_uv76) as add_to_cart_uv76 ,sum(add_to_cart_uv77) as add_to_cart_uv77 ,sum(add_to_cart_uv78) as add_to_cart_uv78 
 ,sum(add_to_cart_uv79) as add_to_cart_uv79 ,sum(add_to_cart_uv8) as add_to_cart_uv8 ,sum(add_to_cart_uv80) as add_to_cart_uv80 ,sum(add_to_cart_uv81) as add_to_cart_uv81 ,sum(add_to_cart_uv82) as add_to_cart_uv82 ,sum(add_to_cart_uv83) as add_to_cart_uv83 ,sum(add_to_cart_uv84) as add_to_cart_uv84 
 ,sum(add_to_cart_uv85) as add_to_cart_uv85 ,sum(add_to_cart_uv86) as add_to_cart_uv86 ,sum(add_to_cart_uv87) as add_to_cart_uv87 ,sum(add_to_cart_uv88) as add_to_cart_uv88 ,sum(add_to_cart_uv89) as add_to_cart_uv89 ,sum(add_to_cart_uv9) as add_to_cart_uv9 ,sum(add_to_cart_uv90) as add_to_cart_uv90 
 ,sum(add_to_cart_uv91) as add_to_cart_uv91 ,sum(add_to_cart_uv92) as add_to_cart_uv92 ,sum(add_to_cart_uv93) as add_to_cart_uv93 ,sum(add_to_cart_uv94) as add_to_cart_uv94 ,sum(add_to_cart_uv95) as add_to_cart_uv95 ,sum(add_to_cart_uv96) as add_to_cart_uv96 ,sum(add_to_cart_uv97) as add_to_cart_uv97
 into #temp1 
from (
	select distinct * 
	from DA_TopRanking.kpi_tracking_bylist
	where dt = @Update_Date
	and platform_type in ('app','mnp')
)t1 group by dt
;

select 24
if not object_id(N'Tempdb..#temp2') is null 
drop table #temp2
select dt
 ,sum(converted_uv1) as converted_uv1 ,sum(converted_uv10) as converted_uv10 ,sum(converted_uv11) as converted_uv11 ,sum(converted_uv12) as converted_uv12 ,sum(converted_uv13) as converted_uv13 ,sum(converted_uv14) as converted_uv14 ,sum(converted_uv15) as converted_uv15 
,sum(converted_uv16) as converted_uv16 ,sum(converted_uv17) as converted_uv17 ,sum(converted_uv18) as converted_uv18 ,sum(converted_uv19) as converted_uv19 ,sum(converted_uv2) as converted_uv2 ,sum(converted_uv20) as converted_uv20 ,sum(converted_uv21) as converted_uv21 
,sum(converted_uv22) as converted_uv22 ,sum(converted_uv23) as converted_uv23 ,sum(converted_uv24) as converted_uv24 ,sum(converted_uv25) as converted_uv25 ,sum(converted_uv26) as converted_uv26 ,sum(converted_uv27) as converted_uv27 ,sum(converted_uv28) as converted_uv28 
,sum(converted_uv29) as converted_uv29 ,sum(converted_uv3) as converted_uv3 ,sum(converted_uv30) as converted_uv30 ,sum(converted_uv31) as converted_uv31 ,sum(converted_uv32) as converted_uv32 ,sum(converted_uv33) as converted_uv33 ,sum(converted_uv34) as converted_uv34 
,sum(converted_uv35) as converted_uv35 ,sum(converted_uv36) as converted_uv36 ,sum(converted_uv37) as converted_uv37 ,sum(converted_uv38) as converted_uv38 ,sum(converted_uv39) as converted_uv39 ,sum(converted_uv4) as converted_uv4 ,sum(converted_uv40) as converted_uv40 
,sum(converted_uv41) as converted_uv41 ,sum(converted_uv42) as converted_uv42 ,sum(converted_uv43) as converted_uv43 ,sum(converted_uv44) as converted_uv44 ,sum(converted_uv45) as converted_uv45 ,sum(converted_uv46) as converted_uv46 ,sum(converted_uv47) as converted_uv47 
,sum(converted_uv48) as converted_uv48 ,sum(converted_uv49) as converted_uv49 ,sum(converted_uv5) as converted_uv5 ,sum(converted_uv50) as converted_uv50 ,sum(converted_uv51) as converted_uv51 ,sum(converted_uv52) as converted_uv52 ,sum(converted_uv53) as converted_uv53 
,sum(converted_uv54) as converted_uv54 ,sum(converted_uv55) as converted_uv55 ,sum(converted_uv56) as converted_uv56 ,sum(converted_uv57) as converted_uv57 ,sum(converted_uv58) as converted_uv58 ,sum(converted_uv59) as converted_uv59 ,sum(converted_uv6) as converted_uv6 
,sum(converted_uv60) as converted_uv60 ,sum(converted_uv61) as converted_uv61 ,sum(converted_uv62) as converted_uv62 ,sum(converted_uv63) as converted_uv63 ,sum(converted_uv64) as converted_uv64 ,sum(converted_uv65) as converted_uv65 ,sum(converted_uv66) as converted_uv66 
,sum(converted_uv67) as converted_uv67 ,sum(converted_uv68) as converted_uv68 ,sum(converted_uv69) as converted_uv69 ,sum(converted_uv7) as converted_uv7 ,sum(converted_uv70) as converted_uv70 ,sum(converted_uv71) as converted_uv71 ,sum(converted_uv72) as converted_uv72 
,sum(converted_uv73) as converted_uv73 ,sum(converted_uv74) as converted_uv74 ,sum(converted_uv75) as converted_uv75 ,sum(converted_uv76) as converted_uv76 ,sum(converted_uv77) as converted_uv77 ,sum(converted_uv78) as converted_uv78 ,sum(converted_uv79) as converted_uv79 
,sum(converted_uv8) as converted_uv8 ,sum(converted_uv80) as converted_uv80 ,sum(converted_uv81) as converted_uv81 ,sum(converted_uv82) as converted_uv82 ,sum(converted_uv83) as converted_uv83 ,sum(converted_uv84) as converted_uv84 ,sum(converted_uv85) as converted_uv85 
,sum(converted_uv86) as converted_uv86 ,sum(converted_uv87) as converted_uv87 ,sum(converted_uv88) as converted_uv88 ,sum(converted_uv89) as converted_uv89 ,sum(converted_uv9) as converted_uv9 ,sum(converted_uv90) as converted_uv90 ,sum(converted_uv91) as converted_uv91 
,sum(converted_uv92) as converted_uv92 ,sum(converted_uv93) as converted_uv93 ,sum(converted_uv94) as converted_uv94 ,sum(converted_uv95) as converted_uv95 ,sum(converted_uv96) as converted_uv96
 ,sum(converted_uv97) as converted_uv97
 into #temp2
from (
	select distinct * from DA_TopRanking.kpi_tracking_bylist
	where dt = @Update_Date
	and platform_type in ('app','mnp')
)t1 group by dt
;
select 25

if not object_id(N'Tempdb..#temp3') is null 
drop table #temp3
select dt
,sum(plp2pdp_pv1) as plp2pdp_pv1,sum(plp2pdp_pv10) as plp2pdp_pv10,sum(plp2pdp_pv11) as plp2pdp_pv11,sum(plp2pdp_pv12) as plp2pdp_pv12,sum(plp2pdp_pv13) as plp2pdp_pv13,sum(plp2pdp_pv14) as plp2pdp_pv14,sum(plp2pdp_pv15) as plp2pdp_pv15,sum(plp2pdp_pv16) as plp2pdp_pv16
,sum(plp2pdp_pv17) as plp2pdp_pv17,sum(plp2pdp_pv18) as plp2pdp_pv18,sum(plp2pdp_pv19) as plp2pdp_pv19,sum(plp2pdp_pv2) as plp2pdp_pv2,sum(plp2pdp_pv20) as plp2pdp_pv20,sum(plp2pdp_pv21) as plp2pdp_pv21,sum(plp2pdp_pv22) as plp2pdp_pv22,sum(plp2pdp_pv23) as plp2pdp_pv23
,sum(plp2pdp_pv24) as plp2pdp_pv24,sum(plp2pdp_pv25) as plp2pdp_pv25,sum(plp2pdp_pv26) as plp2pdp_pv26,sum(plp2pdp_pv27) as plp2pdp_pv27,sum(plp2pdp_pv28) as plp2pdp_pv28,sum(plp2pdp_pv29) as plp2pdp_pv29,sum(plp2pdp_pv3) as plp2pdp_pv3,sum(plp2pdp_pv30) as plp2pdp_pv30
,sum(plp2pdp_pv31) as plp2pdp_pv31,sum(plp2pdp_pv32) as plp2pdp_pv32,sum(plp2pdp_pv33) as plp2pdp_pv33,sum(plp2pdp_pv34) as plp2pdp_pv34,sum(plp2pdp_pv35) as plp2pdp_pv35,sum(plp2pdp_pv36) as plp2pdp_pv36,sum(plp2pdp_pv37) as plp2pdp_pv37,sum(plp2pdp_pv38) as plp2pdp_pv38
,sum(plp2pdp_pv39) as plp2pdp_pv39,sum(plp2pdp_pv4) as plp2pdp_pv4,sum(plp2pdp_pv40) as plp2pdp_pv40,sum(plp2pdp_pv41) as plp2pdp_pv41,sum(plp2pdp_pv42) as plp2pdp_pv42,sum(plp2pdp_pv43) as plp2pdp_pv43,sum(plp2pdp_pv44) as plp2pdp_pv44,sum(plp2pdp_pv45) as plp2pdp_pv45
,sum(plp2pdp_pv46) as plp2pdp_pv46,sum(plp2pdp_pv47) as plp2pdp_pv47,sum(plp2pdp_pv48) as plp2pdp_pv48,sum(plp2pdp_pv49) as plp2pdp_pv49,sum(plp2pdp_pv5) as plp2pdp_pv5,sum(plp2pdp_pv50) as plp2pdp_pv50,sum(plp2pdp_pv51) as plp2pdp_pv51,sum(plp2pdp_pv52) as plp2pdp_pv52
,sum(plp2pdp_pv53) as plp2pdp_pv53,sum(plp2pdp_pv54) as plp2pdp_pv54,sum(plp2pdp_pv55) as plp2pdp_pv55,sum(plp2pdp_pv56) as plp2pdp_pv56,sum(plp2pdp_pv57) as plp2pdp_pv57,sum(plp2pdp_pv58) as plp2pdp_pv58,sum(plp2pdp_pv59) as plp2pdp_pv59,sum(plp2pdp_pv6) as plp2pdp_pv6
,sum(plp2pdp_pv60) as plp2pdp_pv60,sum(plp2pdp_pv61) as plp2pdp_pv61,sum(plp2pdp_pv62) as plp2pdp_pv62,sum(plp2pdp_pv63) as plp2pdp_pv63,sum(plp2pdp_pv64) as plp2pdp_pv64,sum(plp2pdp_pv65) as plp2pdp_pv65,sum(plp2pdp_pv66) as plp2pdp_pv66,sum(plp2pdp_pv67) as plp2pdp_pv67
,sum(plp2pdp_pv68) as plp2pdp_pv68,sum(plp2pdp_pv69) as plp2pdp_pv69,sum(plp2pdp_pv7) as plp2pdp_pv7,sum(plp2pdp_pv70) as plp2pdp_pv70,sum(plp2pdp_pv71) as plp2pdp_pv71,sum(plp2pdp_pv72) as plp2pdp_pv72,sum(plp2pdp_pv73) as plp2pdp_pv73,sum(plp2pdp_pv74) as plp2pdp_pv74
,sum(plp2pdp_pv75) as plp2pdp_pv75,sum(plp2pdp_pv76) as plp2pdp_pv76,sum(plp2pdp_pv77) as plp2pdp_pv77,sum(plp2pdp_pv78) as plp2pdp_pv78,sum(plp2pdp_pv79) as plp2pdp_pv79,sum(plp2pdp_pv8) as plp2pdp_pv8,sum(plp2pdp_pv80) as plp2pdp_pv80,sum(plp2pdp_pv81) as plp2pdp_pv81
,sum(plp2pdp_pv82) as plp2pdp_pv82,sum(plp2pdp_pv83) as plp2pdp_pv83,sum(plp2pdp_pv84) as plp2pdp_pv84,sum(plp2pdp_pv85) as plp2pdp_pv85,sum(plp2pdp_pv86) as plp2pdp_pv86,sum(plp2pdp_pv87) as plp2pdp_pv87,sum(plp2pdp_pv88) as plp2pdp_pv88,sum(plp2pdp_pv89) as plp2pdp_pv89
,sum(plp2pdp_pv9) as plp2pdp_pv9,sum(plp2pdp_pv90) as plp2pdp_pv90,sum(plp2pdp_pv91) as plp2pdp_pv91,sum(plp2pdp_pv92) as plp2pdp_pv92,sum(plp2pdp_pv93) as plp2pdp_pv93,sum(plp2pdp_pv94) as plp2pdp_pv94,sum(plp2pdp_pv95) as plp2pdp_pv95,sum(plp2pdp_pv96) as plp2pdp_pv96
,sum(plp2pdp_pv97) as plp2pdp_pv97
 into #temp3
from (
	select distinct * from DA_TopRanking.kpi_tracking_bylist
	where dt = @Update_Date
	and platform_type in ('app','mnp')
)t1 group by dt
;
select 26
if not object_id(N'Tempdb..#temp4') is null 
drop table #temp4
select dt
, sum(plp2pdp_uv1) as plp2pdp_uv1, sum(plp2pdp_uv10) as plp2pdp_uv10, sum(plp2pdp_uv11) as plp2pdp_uv11, sum(plp2pdp_uv12) as plp2pdp_uv12, sum(plp2pdp_uv13) as plp2pdp_uv13, sum(plp2pdp_uv14) as plp2pdp_uv14, sum(plp2pdp_uv15) as plp2pdp_uv15, sum(plp2pdp_uv16) as plp2pdp_uv16, sum(plp2pdp_uv17) as plp2pdp_uv17
, sum(plp2pdp_uv18) as plp2pdp_uv18, sum(plp2pdp_uv19) as plp2pdp_uv19, sum(plp2pdp_uv2) as plp2pdp_uv2, sum(plp2pdp_uv20) as plp2pdp_uv20, sum(plp2pdp_uv21) as plp2pdp_uv21, sum(plp2pdp_uv22) as plp2pdp_uv22, sum(plp2pdp_uv23) as plp2pdp_uv23, sum(plp2pdp_uv24) as plp2pdp_uv24, sum(plp2pdp_uv25) as plp2pdp_uv25
, sum(plp2pdp_uv26) as plp2pdp_uv26, sum(plp2pdp_uv27) as plp2pdp_uv27, sum(plp2pdp_uv28) as plp2pdp_uv28, sum(plp2pdp_uv29) as plp2pdp_uv29, sum(plp2pdp_uv3) as plp2pdp_uv3, sum(plp2pdp_uv30) as plp2pdp_uv30, sum(plp2pdp_uv31) as plp2pdp_uv31, sum(plp2pdp_uv32) as plp2pdp_uv32, sum(plp2pdp_uv33) as plp2pdp_uv33
, sum(plp2pdp_uv34) as plp2pdp_uv34, sum(plp2pdp_uv35) as plp2pdp_uv35, sum(plp2pdp_uv36) as plp2pdp_uv36, sum(plp2pdp_uv37) as plp2pdp_uv37, sum(plp2pdp_uv38) as plp2pdp_uv38, sum(plp2pdp_uv39) as plp2pdp_uv39, sum(plp2pdp_uv4) as plp2pdp_uv4, sum(plp2pdp_uv40) as plp2pdp_uv40, sum(plp2pdp_uv41) as plp2pdp_uv41
, sum(plp2pdp_uv42) as plp2pdp_uv42, sum(plp2pdp_uv43) as plp2pdp_uv43, sum(plp2pdp_uv44) as plp2pdp_uv44, sum(plp2pdp_uv45) as plp2pdp_uv45, sum(plp2pdp_uv46) as plp2pdp_uv46, sum(plp2pdp_uv47) as plp2pdp_uv47, sum(plp2pdp_uv48) as plp2pdp_uv48, sum(plp2pdp_uv49) as plp2pdp_uv49, sum(plp2pdp_uv5) as plp2pdp_uv5
, sum(plp2pdp_uv50) as plp2pdp_uv50, sum(plp2pdp_uv51) as plp2pdp_uv51, sum(plp2pdp_uv52) as plp2pdp_uv52, sum(plp2pdp_uv53) as plp2pdp_uv53, sum(plp2pdp_uv54) as plp2pdp_uv54, sum(plp2pdp_uv55) as plp2pdp_uv55, sum(plp2pdp_uv56) as plp2pdp_uv56, sum(plp2pdp_uv57) as plp2pdp_uv57, sum(plp2pdp_uv58) as plp2pdp_uv58
, sum(plp2pdp_uv59) as plp2pdp_uv59, sum(plp2pdp_uv6) as plp2pdp_uv6, sum(plp2pdp_uv60) as plp2pdp_uv60, sum(plp2pdp_uv61) as plp2pdp_uv61, sum(plp2pdp_uv62) as plp2pdp_uv62, sum(plp2pdp_uv63) as plp2pdp_uv63, sum(plp2pdp_uv64) as plp2pdp_uv64, sum(plp2pdp_uv65) as plp2pdp_uv65, sum(plp2pdp_uv66) as plp2pdp_uv66
, sum(plp2pdp_uv67) as plp2pdp_uv67, sum(plp2pdp_uv68) as plp2pdp_uv68, sum(plp2pdp_uv69) as plp2pdp_uv69, sum(plp2pdp_uv7) as plp2pdp_uv7, sum(plp2pdp_uv70) as plp2pdp_uv70, sum(plp2pdp_uv71) as plp2pdp_uv71, sum(plp2pdp_uv72) as plp2pdp_uv72, sum(plp2pdp_uv73) as plp2pdp_uv73, sum(plp2pdp_uv74) as plp2pdp_uv74
, sum(plp2pdp_uv75) as plp2pdp_uv75, sum(plp2pdp_uv76) as plp2pdp_uv76, sum(plp2pdp_uv77) as plp2pdp_uv77, sum(plp2pdp_uv78) as plp2pdp_uv78, sum(plp2pdp_uv79) as plp2pdp_uv79, sum(plp2pdp_uv8) as plp2pdp_uv8, sum(plp2pdp_uv80) as plp2pdp_uv80, sum(plp2pdp_uv81) as plp2pdp_uv81, sum(plp2pdp_uv82) as plp2pdp_uv82
, sum(plp2pdp_uv83) as plp2pdp_uv83, sum(plp2pdp_uv84) as plp2pdp_uv84, sum(plp2pdp_uv85) as plp2pdp_uv85, sum(plp2pdp_uv86) as plp2pdp_uv86, sum(plp2pdp_uv87) as plp2pdp_uv87, sum(plp2pdp_uv88) as plp2pdp_uv88, sum(plp2pdp_uv89) as plp2pdp_uv89, sum(plp2pdp_uv9) as plp2pdp_uv9, sum(plp2pdp_uv90) as plp2pdp_uv90
, sum(plp2pdp_uv91) as plp2pdp_uv91, sum(plp2pdp_uv92) as plp2pdp_uv92, sum(plp2pdp_uv93) as plp2pdp_uv93, sum(plp2pdp_uv94) as plp2pdp_uv94, sum(plp2pdp_uv95) as plp2pdp_uv95, sum(plp2pdp_uv96) as plp2pdp_uv96, sum(plp2pdp_uv97) as plp2pdp_uv97
 into #temp4
from (
	select distinct * from DA_TopRanking.kpi_tracking_bylist
	where dt = @Update_Date
	and platform_type in ('app','mnp')
)t1 group by dt
;

select 27
if not object_id(N'Tempdb..#temp5') is null 
drop table #temp5
select dt
, sum(converted_sales1) as converted_sales1, sum(converted_sales10) as converted_sales10, sum(converted_sales11) as converted_sales11, sum(converted_sales12) as converted_sales12, sum(converted_sales13) as converted_sales13, sum(converted_sales14) as converted_sales14, sum(converted_sales15) as converted_sales15
, sum(converted_sales16) as converted_sales16, sum(converted_sales17) as converted_sales17, sum(converted_sales18) as converted_sales18, sum(converted_sales19) as converted_sales19, sum(converted_sales2) as converted_sales2, sum(converted_sales20) as converted_sales20, sum(converted_sales21) as converted_sales21
, sum(converted_sales22) as converted_sales22, sum(converted_sales23) as converted_sales23, sum(converted_sales24) as converted_sales24, sum(converted_sales25) as converted_sales25, sum(converted_sales26) as converted_sales26, sum(converted_sales27) as converted_sales27, sum(converted_sales28) as converted_sales28
, sum(converted_sales29) as converted_sales29, sum(converted_sales3) as converted_sales3, sum(converted_sales30) as converted_sales30, sum(converted_sales31) as converted_sales31, sum(converted_sales32) as converted_sales32, sum(converted_sales33) as converted_sales33, sum(converted_sales34) as converted_sales34
, sum(converted_sales35) as converted_sales35, sum(converted_sales36) as converted_sales36, sum(converted_sales37) as converted_sales37, sum(converted_sales38) as converted_sales38, sum(converted_sales39) as converted_sales39, sum(converted_sales4) as converted_sales4, sum(converted_sales40) as converted_sales40
, sum(converted_sales41) as converted_sales41, sum(converted_sales42) as converted_sales42, sum(converted_sales43) as converted_sales43, sum(converted_sales44) as converted_sales44, sum(converted_sales45) as converted_sales45, sum(converted_sales46) as converted_sales46, sum(converted_sales47) as converted_sales47
, sum(converted_sales48) as converted_sales48, sum(converted_sales49) as converted_sales49, sum(converted_sales5) as converted_sales5, sum(converted_sales50) as converted_sales50, sum(converted_sales51) as converted_sales51, sum(converted_sales52) as converted_sales52, sum(converted_sales53) as converted_sales53
, sum(converted_sales54) as converted_sales54, sum(converted_sales55) as converted_sales55, sum(converted_sales56) as converted_sales56, sum(converted_sales57) as converted_sales57, sum(converted_sales58) as converted_sales58, sum(converted_sales59) as converted_sales59, sum(converted_sales6) as converted_sales6
, sum(converted_sales60) as converted_sales60, sum(converted_sales61) as converted_sales61, sum(converted_sales62) as converted_sales62, sum(converted_sales63) as converted_sales63, sum(converted_sales64) as converted_sales64, sum(converted_sales65) as converted_sales65, sum(converted_sales66) as converted_sales66
, sum(converted_sales67) as converted_sales67, sum(converted_sales68) as converted_sales68, sum(converted_sales69) as converted_sales69, sum(converted_sales7) as converted_sales7, sum(converted_sales70) as converted_sales70, sum(converted_sales71) as converted_sales71, sum(converted_sales72) as converted_sales72
, sum(converted_sales73) as converted_sales73, sum(converted_sales74) as converted_sales74, sum(converted_sales75) as converted_sales75, sum(converted_sales76) as converted_sales76, sum(converted_sales77) as converted_sales77, sum(converted_sales78) as converted_sales78, sum(converted_sales79) as converted_sales79
, sum(converted_sales8) as converted_sales8, sum(converted_sales80) as converted_sales80, sum(converted_sales81) as converted_sales81, sum(converted_sales82) as converted_sales82, sum(converted_sales83) as converted_sales83, sum(converted_sales84) as converted_sales84, sum(converted_sales85) as converted_sales85
, sum(converted_sales86) as converted_sales86, sum(converted_sales87) as converted_sales87, sum(converted_sales88) as converted_sales88, sum(converted_sales89) as converted_sales89, sum(converted_sales9) as converted_sales9, sum(converted_sales90) as converted_sales90, sum(converted_sales91) as converted_sales91
, sum(converted_sales92) as converted_sales92, sum(converted_sales93) as converted_sales93, sum(converted_sales94) as converted_sales94, sum(converted_sales95) as converted_sales95, sum(converted_sales96) as converted_sales96, sum(converted_sales97) as converted_sales97
 into #temp5
from (
	select distinct * from DA_TopRanking.kpi_tracking_bylist
	where dt = @Update_Date
	and platform_type in ('app','mnp')
)t1 group by dt
;

select 28

insert into DA_TopRanking.kpi_tracking_bylist(dt, platform_type, total_plp_pv_b, add_to_cart_uv1, add_to_cart_uv10, add_to_cart_uv11, add_to_cart_uv12, add_to_cart_uv13, add_to_cart_uv14, add_to_cart_uv15, add_to_cart_uv16, add_to_cart_uv17, add_to_cart_uv18, add_to_cart_uv19, add_to_cart_uv2, add_to_cart_uv20, add_to_cart_uv21, add_to_cart_uv22, add_to_cart_uv23, add_to_cart_uv24, add_to_cart_uv25, add_to_cart_uv26, add_to_cart_uv27, add_to_cart_uv28, add_to_cart_uv29, add_to_cart_uv3, add_to_cart_uv30, add_to_cart_uv31, add_to_cart_uv32, add_to_cart_uv33, add_to_cart_uv34
, add_to_cart_uv35, add_to_cart_uv36, add_to_cart_uv37, add_to_cart_uv38, add_to_cart_uv39, add_to_cart_uv4, add_to_cart_uv40, add_to_cart_uv41, add_to_cart_uv42, add_to_cart_uv43, add_to_cart_uv44, add_to_cart_uv45, add_to_cart_uv46, add_to_cart_uv47, add_to_cart_uv48, add_to_cart_uv49, add_to_cart_uv5, add_to_cart_uv50, add_to_cart_uv51, add_to_cart_uv52, add_to_cart_uv53, add_to_cart_uv54, add_to_cart_uv55, add_to_cart_uv56, add_to_cart_uv57, add_to_cart_uv58, add_to_cart_uv59, add_to_cart_uv6, add_to_cart_uv60, add_to_cart_uv61
, add_to_cart_uv62, add_to_cart_uv63, add_to_cart_uv64, add_to_cart_uv65, add_to_cart_uv66, add_to_cart_uv67, add_to_cart_uv68, add_to_cart_uv69, add_to_cart_uv7, add_to_cart_uv70, add_to_cart_uv71, add_to_cart_uv72, add_to_cart_uv73, add_to_cart_uv74, add_to_cart_uv75, add_to_cart_uv76, add_to_cart_uv77, add_to_cart_uv78, add_to_cart_uv79, add_to_cart_uv8, add_to_cart_uv80, add_to_cart_uv81, add_to_cart_uv82, add_to_cart_uv83, add_to_cart_uv84, add_to_cart_uv85, add_to_cart_uv86, add_to_cart_uv87, add_to_cart_uv88, add_to_cart_uv89
, add_to_cart_uv9, add_to_cart_uv90, add_to_cart_uv91, add_to_cart_uv92, add_to_cart_uv93, add_to_cart_uv94, add_to_cart_uv95, add_to_cart_uv96, add_to_cart_uv97, converted_uv1, converted_uv10, converted_uv11, converted_uv12, converted_uv13, converted_uv14, converted_uv15, converted_uv16, converted_uv17, converted_uv18, converted_uv19, converted_uv2, converted_uv20, converted_uv21, converted_uv22, converted_uv23, converted_uv24, converted_uv25, converted_uv26, converted_uv27, converted_uv28, converted_uv29, converted_uv3, converted_uv30
, converted_uv31, converted_uv32, converted_uv33, converted_uv34, converted_uv35, converted_uv36, converted_uv37, converted_uv38, converted_uv39, converted_uv4, converted_uv40, converted_uv41, converted_uv42, converted_uv43, converted_uv44, converted_uv45, converted_uv46, converted_uv47, converted_uv48, converted_uv49, converted_uv5, converted_uv50, converted_uv51, converted_uv52, converted_uv53, converted_uv54, converted_uv55, converted_uv56, converted_uv57, converted_uv58, converted_uv59, converted_uv6, converted_uv60, converted_uv61
, converted_uv62, converted_uv63, converted_uv64, converted_uv65, converted_uv66, converted_uv67, converted_uv68, converted_uv69, converted_uv7, converted_uv70, converted_uv71, converted_uv72, converted_uv73, converted_uv74, converted_uv75, converted_uv76, converted_uv77, converted_uv78, converted_uv79, converted_uv8, converted_uv80, converted_uv81, converted_uv82, converted_uv83, converted_uv84, converted_uv85, converted_uv86, converted_uv87, converted_uv88, converted_uv89, converted_uv9, converted_uv90, converted_uv91, converted_uv92
, converted_uv93, converted_uv94, converted_uv95, converted_uv96, converted_uv97, plp2pdp_pv1, plp2pdp_pv10, plp2pdp_pv11, plp2pdp_pv12, plp2pdp_pv13, plp2pdp_pv14, plp2pdp_pv15, plp2pdp_pv16, plp2pdp_pv17, plp2pdp_pv18, plp2pdp_pv19, plp2pdp_pv2, plp2pdp_pv20, plp2pdp_pv21, plp2pdp_pv22, plp2pdp_pv23, plp2pdp_pv24, plp2pdp_pv25, plp2pdp_pv26, plp2pdp_pv27, plp2pdp_pv28, plp2pdp_pv29, plp2pdp_pv3, plp2pdp_pv30, plp2pdp_pv31, plp2pdp_pv32, plp2pdp_pv33, plp2pdp_pv34, plp2pdp_pv35, plp2pdp_pv36, plp2pdp_pv37, plp2pdp_pv38, plp2pdp_pv39
, plp2pdp_pv4, plp2pdp_pv40, plp2pdp_pv41, plp2pdp_pv42, plp2pdp_pv43, plp2pdp_pv44, plp2pdp_pv45, plp2pdp_pv46, plp2pdp_pv47, plp2pdp_pv48, plp2pdp_pv49, plp2pdp_pv5, plp2pdp_pv50, plp2pdp_pv51, plp2pdp_pv52, plp2pdp_pv53, plp2pdp_pv54, plp2pdp_pv55, plp2pdp_pv56, plp2pdp_pv57, plp2pdp_pv58, plp2pdp_pv59, plp2pdp_pv6, plp2pdp_pv60, plp2pdp_pv61, plp2pdp_pv62, plp2pdp_pv63, plp2pdp_pv64, plp2pdp_pv65, plp2pdp_pv66, plp2pdp_pv67, plp2pdp_pv68, plp2pdp_pv69, plp2pdp_pv7, plp2pdp_pv70, plp2pdp_pv71, plp2pdp_pv72, plp2pdp_pv73
, plp2pdp_pv74, plp2pdp_pv75, plp2pdp_pv76, plp2pdp_pv77, plp2pdp_pv78, plp2pdp_pv79, plp2pdp_pv8, plp2pdp_pv80, plp2pdp_pv81, plp2pdp_pv82, plp2pdp_pv83, plp2pdp_pv84, plp2pdp_pv85, plp2pdp_pv86, plp2pdp_pv87, plp2pdp_pv88, plp2pdp_pv89, plp2pdp_pv9, plp2pdp_pv90, plp2pdp_pv91, plp2pdp_pv92, plp2pdp_pv93, plp2pdp_pv94, plp2pdp_pv95, plp2pdp_pv96, plp2pdp_pv97, plp2pdp_uv1, plp2pdp_uv10, plp2pdp_uv11, plp2pdp_uv12, plp2pdp_uv13, plp2pdp_uv14, plp2pdp_uv15, plp2pdp_uv16, plp2pdp_uv17, plp2pdp_uv18, plp2pdp_uv19, plp2pdp_uv2
, plp2pdp_uv20, plp2pdp_uv21, plp2pdp_uv22, plp2pdp_uv23, plp2pdp_uv24, plp2pdp_uv25, plp2pdp_uv26, plp2pdp_uv27, plp2pdp_uv28, plp2pdp_uv29, plp2pdp_uv3, plp2pdp_uv30, plp2pdp_uv31, plp2pdp_uv32, plp2pdp_uv33, plp2pdp_uv34, plp2pdp_uv35, plp2pdp_uv36, plp2pdp_uv37, plp2pdp_uv38, plp2pdp_uv39, plp2pdp_uv4, plp2pdp_uv40, plp2pdp_uv41, plp2pdp_uv42, plp2pdp_uv43, plp2pdp_uv44, plp2pdp_uv45, plp2pdp_uv46, plp2pdp_uv47, plp2pdp_uv48, plp2pdp_uv49, plp2pdp_uv5, plp2pdp_uv50, plp2pdp_uv51, plp2pdp_uv52, plp2pdp_uv53, plp2pdp_uv54
, plp2pdp_uv55, plp2pdp_uv56, plp2pdp_uv57, plp2pdp_uv58, plp2pdp_uv59, plp2pdp_uv6, plp2pdp_uv60, plp2pdp_uv61, plp2pdp_uv62, plp2pdp_uv63, plp2pdp_uv64, plp2pdp_uv65, plp2pdp_uv66, plp2pdp_uv67, plp2pdp_uv68, plp2pdp_uv69, plp2pdp_uv7, plp2pdp_uv70, plp2pdp_uv71, plp2pdp_uv72, plp2pdp_uv73, plp2pdp_uv74, plp2pdp_uv75, plp2pdp_uv76, plp2pdp_uv77, plp2pdp_uv78, plp2pdp_uv79, plp2pdp_uv8, plp2pdp_uv80, plp2pdp_uv81, plp2pdp_uv82, plp2pdp_uv83, plp2pdp_uv84, plp2pdp_uv85, plp2pdp_uv86, plp2pdp_uv87, plp2pdp_uv88, plp2pdp_uv89
, plp2pdp_uv9, plp2pdp_uv90, plp2pdp_uv91, plp2pdp_uv92, plp2pdp_uv93, plp2pdp_uv94, plp2pdp_uv95, plp2pdp_uv96, plp2pdp_uv97
, converted_sales1, converted_sales10, converted_sales11, converted_sales12, converted_sales13, converted_sales14, converted_sales15, converted_sales16, converted_sales17, converted_sales18, converted_sales19, converted_sales2
, converted_sales20, converted_sales21, converted_sales22, converted_sales23, converted_sales24, converted_sales25, converted_sales26, converted_sales27, converted_sales28, converted_sales29, converted_sales3, converted_sales30, converted_sales31, converted_sales32, converted_sales33, converted_sales34, converted_sales35, converted_sales36, converted_sales37, converted_sales38, converted_sales39, converted_sales4, converted_sales40, converted_sales41, converted_sales42, converted_sales43, converted_sales44, converted_sales45, converted_sales46, converted_sales47, converted_sales48, converted_sales49, converted_sales5, converted_sales50, converted_sales51, converted_sales52, converted_sales53, converted_sales54
, converted_sales55, converted_sales56, converted_sales57, converted_sales58, converted_sales59, converted_sales6, converted_sales60, converted_sales61, converted_sales62, converted_sales63, converted_sales64, converted_sales65, converted_sales66, converted_sales67, converted_sales68, converted_sales69, converted_sales7, converted_sales70, converted_sales71, converted_sales72, converted_sales73, converted_sales74, converted_sales75, converted_sales76, converted_sales77, converted_sales78, converted_sales79, converted_sales8, converted_sales80, converted_sales81, converted_sales82, converted_sales83, converted_sales84, converted_sales85, converted_sales86, converted_sales87, converted_sales88, converted_sales89
, converted_sales9, converted_sales90, converted_sales91, converted_sales92, converted_sales93, converted_sales94, converted_sales95, converted_sales96, converted_sales97)

select t1.dt, 'total' as platform_type, total_plp_pv_b, add_to_cart_uv1, add_to_cart_uv10, add_to_cart_uv11, add_to_cart_uv12, add_to_cart_uv13, add_to_cart_uv14, add_to_cart_uv15, add_to_cart_uv16, add_to_cart_uv17, add_to_cart_uv18, add_to_cart_uv19, add_to_cart_uv2, add_to_cart_uv20, add_to_cart_uv21, add_to_cart_uv22, add_to_cart_uv23, add_to_cart_uv24, add_to_cart_uv25, add_to_cart_uv26, add_to_cart_uv27, add_to_cart_uv28, add_to_cart_uv29, add_to_cart_uv3, add_to_cart_uv30, add_to_cart_uv31, add_to_cart_uv32, add_to_cart_uv33, add_to_cart_uv34
, add_to_cart_uv35, add_to_cart_uv36, add_to_cart_uv37, add_to_cart_uv38, add_to_cart_uv39, add_to_cart_uv4, add_to_cart_uv40, add_to_cart_uv41, add_to_cart_uv42, add_to_cart_uv43, add_to_cart_uv44, add_to_cart_uv45, add_to_cart_uv46, add_to_cart_uv47, add_to_cart_uv48, add_to_cart_uv49, add_to_cart_uv5, add_to_cart_uv50, add_to_cart_uv51, add_to_cart_uv52, add_to_cart_uv53, add_to_cart_uv54, add_to_cart_uv55, add_to_cart_uv56, add_to_cart_uv57, add_to_cart_uv58, add_to_cart_uv59, add_to_cart_uv6, add_to_cart_uv60, add_to_cart_uv61
, add_to_cart_uv62, add_to_cart_uv63, add_to_cart_uv64, add_to_cart_uv65, add_to_cart_uv66, add_to_cart_uv67, add_to_cart_uv68, add_to_cart_uv69, add_to_cart_uv7, add_to_cart_uv70, add_to_cart_uv71, add_to_cart_uv72, add_to_cart_uv73, add_to_cart_uv74, add_to_cart_uv75, add_to_cart_uv76, add_to_cart_uv77, add_to_cart_uv78, add_to_cart_uv79, add_to_cart_uv8, add_to_cart_uv80, add_to_cart_uv81, add_to_cart_uv82, add_to_cart_uv83, add_to_cart_uv84, add_to_cart_uv85, add_to_cart_uv86, add_to_cart_uv87, add_to_cart_uv88, add_to_cart_uv89
, add_to_cart_uv9, add_to_cart_uv90, add_to_cart_uv91, add_to_cart_uv92, add_to_cart_uv93, add_to_cart_uv94, add_to_cart_uv95, add_to_cart_uv96, add_to_cart_uv97, converted_uv1, converted_uv10, converted_uv11, converted_uv12, converted_uv13, converted_uv14, converted_uv15, converted_uv16, converted_uv17, converted_uv18, converted_uv19, converted_uv2, converted_uv20, converted_uv21, converted_uv22, converted_uv23, converted_uv24, converted_uv25, converted_uv26, converted_uv27, converted_uv28, converted_uv29, converted_uv3, converted_uv30
, converted_uv31, converted_uv32, converted_uv33, converted_uv34, converted_uv35, converted_uv36, converted_uv37, converted_uv38, converted_uv39, converted_uv4, converted_uv40, converted_uv41, converted_uv42, converted_uv43, converted_uv44, converted_uv45, converted_uv46, converted_uv47, converted_uv48, converted_uv49, converted_uv5, converted_uv50, converted_uv51, converted_uv52, converted_uv53, converted_uv54, converted_uv55, converted_uv56, converted_uv57, converted_uv58, converted_uv59, converted_uv6, converted_uv60, converted_uv61
, converted_uv62, converted_uv63, converted_uv64, converted_uv65, converted_uv66, converted_uv67, converted_uv68, converted_uv69, converted_uv7, converted_uv70, converted_uv71, converted_uv72, converted_uv73, converted_uv74, converted_uv75, converted_uv76, converted_uv77, converted_uv78, converted_uv79, converted_uv8, converted_uv80, converted_uv81, converted_uv82, converted_uv83, converted_uv84, converted_uv85, converted_uv86, converted_uv87, converted_uv88, converted_uv89, converted_uv9, converted_uv90, converted_uv91, converted_uv92
, converted_uv93, converted_uv94, converted_uv95, converted_uv96, converted_uv97, plp2pdp_pv1, plp2pdp_pv10, plp2pdp_pv11, plp2pdp_pv12, plp2pdp_pv13, plp2pdp_pv14, plp2pdp_pv15, plp2pdp_pv16, plp2pdp_pv17, plp2pdp_pv18, plp2pdp_pv19, plp2pdp_pv2, plp2pdp_pv20, plp2pdp_pv21, plp2pdp_pv22, plp2pdp_pv23, plp2pdp_pv24, plp2pdp_pv25, plp2pdp_pv26, plp2pdp_pv27, plp2pdp_pv28, plp2pdp_pv29, plp2pdp_pv3, plp2pdp_pv30, plp2pdp_pv31, plp2pdp_pv32, plp2pdp_pv33, plp2pdp_pv34, plp2pdp_pv35, plp2pdp_pv36, plp2pdp_pv37, plp2pdp_pv38, plp2pdp_pv39
, plp2pdp_pv4, plp2pdp_pv40, plp2pdp_pv41, plp2pdp_pv42, plp2pdp_pv43, plp2pdp_pv44, plp2pdp_pv45, plp2pdp_pv46, plp2pdp_pv47, plp2pdp_pv48, plp2pdp_pv49, plp2pdp_pv5, plp2pdp_pv50, plp2pdp_pv51, plp2pdp_pv52, plp2pdp_pv53, plp2pdp_pv54, plp2pdp_pv55, plp2pdp_pv56, plp2pdp_pv57, plp2pdp_pv58, plp2pdp_pv59, plp2pdp_pv6, plp2pdp_pv60, plp2pdp_pv61, plp2pdp_pv62, plp2pdp_pv63, plp2pdp_pv64, plp2pdp_pv65, plp2pdp_pv66, plp2pdp_pv67, plp2pdp_pv68, plp2pdp_pv69, plp2pdp_pv7, plp2pdp_pv70, plp2pdp_pv71, plp2pdp_pv72, plp2pdp_pv73
, plp2pdp_pv74, plp2pdp_pv75, plp2pdp_pv76, plp2pdp_pv77, plp2pdp_pv78, plp2pdp_pv79, plp2pdp_pv8, plp2pdp_pv80, plp2pdp_pv81, plp2pdp_pv82, plp2pdp_pv83, plp2pdp_pv84, plp2pdp_pv85, plp2pdp_pv86, plp2pdp_pv87, plp2pdp_pv88, plp2pdp_pv89, plp2pdp_pv9, plp2pdp_pv90, plp2pdp_pv91, plp2pdp_pv92, plp2pdp_pv93, plp2pdp_pv94, plp2pdp_pv95, plp2pdp_pv96, plp2pdp_pv97, plp2pdp_uv1, plp2pdp_uv10, plp2pdp_uv11, plp2pdp_uv12, plp2pdp_uv13, plp2pdp_uv14, plp2pdp_uv15, plp2pdp_uv16, plp2pdp_uv17, plp2pdp_uv18, plp2pdp_uv19, plp2pdp_uv2
, plp2pdp_uv20, plp2pdp_uv21, plp2pdp_uv22, plp2pdp_uv23, plp2pdp_uv24, plp2pdp_uv25, plp2pdp_uv26, plp2pdp_uv27, plp2pdp_uv28, plp2pdp_uv29, plp2pdp_uv3, plp2pdp_uv30, plp2pdp_uv31, plp2pdp_uv32, plp2pdp_uv33, plp2pdp_uv34, plp2pdp_uv35, plp2pdp_uv36, plp2pdp_uv37, plp2pdp_uv38, plp2pdp_uv39, plp2pdp_uv4, plp2pdp_uv40, plp2pdp_uv41, plp2pdp_uv42, plp2pdp_uv43, plp2pdp_uv44, plp2pdp_uv45, plp2pdp_uv46, plp2pdp_uv47, plp2pdp_uv48, plp2pdp_uv49, plp2pdp_uv5, plp2pdp_uv50, plp2pdp_uv51, plp2pdp_uv52, plp2pdp_uv53, plp2pdp_uv54
, plp2pdp_uv55, plp2pdp_uv56, plp2pdp_uv57, plp2pdp_uv58, plp2pdp_uv59, plp2pdp_uv6, plp2pdp_uv60, plp2pdp_uv61, plp2pdp_uv62, plp2pdp_uv63, plp2pdp_uv64, plp2pdp_uv65, plp2pdp_uv66, plp2pdp_uv67, plp2pdp_uv68, plp2pdp_uv69, plp2pdp_uv7, plp2pdp_uv70, plp2pdp_uv71, plp2pdp_uv72, plp2pdp_uv73, plp2pdp_uv74, plp2pdp_uv75, plp2pdp_uv76, plp2pdp_uv77, plp2pdp_uv78, plp2pdp_uv79, plp2pdp_uv8, plp2pdp_uv80, plp2pdp_uv81, plp2pdp_uv82, plp2pdp_uv83, plp2pdp_uv84, plp2pdp_uv85, plp2pdp_uv86, plp2pdp_uv87, plp2pdp_uv88, plp2pdp_uv89
, plp2pdp_uv9, plp2pdp_uv90, plp2pdp_uv91, plp2pdp_uv92, plp2pdp_uv93, plp2pdp_uv94, plp2pdp_uv95, plp2pdp_uv96, plp2pdp_uv97
, converted_sales1, converted_sales10, converted_sales11, converted_sales12, converted_sales13, converted_sales14, converted_sales15, converted_sales16, converted_sales17, converted_sales18, converted_sales19, converted_sales2
, converted_sales20, converted_sales21, converted_sales22, converted_sales23, converted_sales24, converted_sales25, converted_sales26, converted_sales27, converted_sales28, converted_sales29, converted_sales3, converted_sales30, converted_sales31, converted_sales32, converted_sales33, converted_sales34, converted_sales35, converted_sales36, converted_sales37, converted_sales38, converted_sales39, converted_sales4, converted_sales40, converted_sales41, converted_sales42, converted_sales43, converted_sales44, converted_sales45, converted_sales46, converted_sales47, converted_sales48, converted_sales49, converted_sales5, converted_sales50, converted_sales51, converted_sales52, converted_sales53, converted_sales54
, converted_sales55, converted_sales56, converted_sales57, converted_sales58, converted_sales59, converted_sales6, converted_sales60, converted_sales61, converted_sales62, converted_sales63, converted_sales64, converted_sales65, converted_sales66, converted_sales67, converted_sales68, converted_sales69, converted_sales7, converted_sales70, converted_sales71, converted_sales72, converted_sales73, converted_sales74, converted_sales75, converted_sales76, converted_sales77, converted_sales78, converted_sales79, converted_sales8, converted_sales80, converted_sales81, converted_sales82, converted_sales83, converted_sales84, converted_sales85, converted_sales86, converted_sales87, converted_sales88, converted_sales89
, converted_sales9, converted_sales90, converted_sales91, converted_sales92, converted_sales93, converted_sales94, converted_sales95, converted_sales96, converted_sales97
from #temp1 t1 
left join #temp2 t2 on t1.dt=t2.dt
left join #temp3 t3 on t1.dt=t3.dt
left join #temp4 t4 on t1.dt=t4.dt
left join #temp5 t5 on t1.dt=t5.dt
;
select 29
insert into DA_TopRanking.coding_prod_label(project,detail,start_time,update_date)
select 'UseCase2 Kpi','Use Case Phase II , TopRanking Kpi End....',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

END 

GO
