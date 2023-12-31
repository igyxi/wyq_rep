/****** Object:  StoredProcedure [DA_Tagging].[SP_T2_4_Time_Filter_Update]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T2_4_Time_Filter_Update] @datadate [date] AS
BEGIN



/*注： 
@datadate： 前一天的日期
时间筛选数据源索引：
===========================================================================================================================================================================
	序号 |	数据源表						| 业务主键ID											|时间筛选标签范围						|	更新方式	| Status
---------|----------------------------------|-------------------------------------------------------|---------------------------------------|---------------|------------
	1	 |DA_Tagging.dwd_time_filter_noprod	| sensor_id												|神策相关标签--浏览行为/浏览关联下单行为| daily insert 	|	1
	2	 |DA_Tagging.v_events_media_session	| sensor_id												|神策相关标签--媒体引流					| daily insert 	|	1
	3	 |DA_Tagging.dwd_time_filter		| sensor_id												|神策相关标签--产品相关(点击 加购 购买)	| daily insert 	|	1
	4	 |DA_Tagging.dwd_time_filter_search	| sensor_id												|神策相关标签--搜索相关行为				| daily insert 	|	1
	5	 |DA_Tagging.v_events_session		| sensor_id												|神策相关标签--计算停留时间				| daily insert 	|	1
	6	 |DA_Tagging.oms_time_filter		| sales_member_id										|OMS相关标签--线上订单衍生标签(sku)		| daily insert 	|	1
	6	 |DA_Tagging.oms_time_filter_basic	| sales_member_id										|OMS相关标签--线上订单衍生标签(basic)	| daily insert 	|	1
	6	 |DA_Tagging.oms_time_filter_vb		| sales_member_id										|OMS相关标签--线上订单衍生标签(vb)		| daily insert 	|	1
	7	 |DA_Tagging.crm_time_filter		| crm_account_id										|CRM相关标签--全渠道订单衍生标签		| daily insert 	|	1
---------|----------------------------------|-------------------------------------------------------|---------------------------------------|----------------------------
	8	 |DA_Tagging.oms_time_filter_media	|ss_os in ('IOS','Android'): ss_device_id				|TD相关标签--媒体 * 转化				| daily insert	|	1
		 |									|ss_os in ('web','MiniProgram','mobile'):member_card	|										|				|
===========================================================================================================================================================================*/


--DA_Tagging.crm_time_filter CRM时间筛选数据源
---=========================================================================================================================================
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_4','crm_time_filter insert start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

delete from DA_Tagging.crm_time_filter
where trans_date = @datadate;

-- daily新增crm时间筛选数据
insert into  DA_Tagging.crm_time_filter(crm_account_id,trans_id,trans_time,trans_date,channel
  ,sales,op_code,sku_code,brand,brand_type,category,subcategory,thirdcategory,range,segment,skincare_function_basic
  ,makeup_function,fragrances_stereotype,kol_theme,qtys,is_eb_store)

  select account_id as crm_account_id ,trans_id  ,trans_time  ,trans_date  , member_register_channel as channel , sales   
  , product_id as op_code , sku_code , brand , brand_type,category, subcategory, thirdcategory 
  , [range], segment, skincare_function_basic, makeup_function, fragrances_stereotype , kol_theme,qtys,is_eb_store
from(
	  select t1.account_id, t1.trans_id, t1.sales ,t1.sap_time as trans_time,convert(date,t1.sap_time) as trans_date
		,t2.sku_code,t1.product_id,t2.brand,t2.brand_type,t2.category,t2.subcategory,t2.thirdcategory,t2.range
		,t2.segment,t2.skincare_function_basic,t2.makeup_function,t2.fragrances_stereotype,t2.kol_theme
		,t3.member_register_channel,qtys,is_eb_store
		from (
				select account_id,trans_id,sales,sap_time,product_id,store_id ,qtys 
				from ODS_CRM.FactTrans
				where account_id<>0 and sales>0 and qtys>0 and sales/qtys<20000 and valid_flag='true'
				and convert(date,sap_time)= @datadate   --<='2021-12-26' 
		  )t1  left outer join (
				select t21.sku_code
				,t21.product_id, t21.brand, t21.brand_type,t21.range,t21.segment, t22.category, t22.subcategory, t22.thirdcategory
				,t22.skincare_function_basic, t22.makeup_function, t22.fragrances_stereotype, t22.kol_theme
				from ODS_CRM.DimProduct t21  left outer join DA_Tagging.sephoraproductlist t22 on t21.sku_code=t22.sku_code collate Chinese_PRC_CS_AI_WS
		  )t2 on t1.product_id=t2.product_id
		  left outer join (
				select store_id,store_code,t32.member_register_channel,is_eb_store from ODS_CRM.DimStore t31
				left outer join [DA_Tagging].[crm_store] t32 on t31.store_code = t32.register_store_code
		  )t3 on t1.store_id=t3.store_id
		  where t1.product_id is not null
)tt1



-- 2021-12-24 取消提供master_id
--insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
--select 'T2_4','crm_time_filter update start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

--update DA_Tagging.crm_time_filter
--set master_id = tt2.master_id
--  ,sephora_card_no = tt2.sephora_card_no
--from DA_Tagging.crm_time_filter tt1
--join (
--  select master_id,crm_account_id,sephora_card_no
--  from DA_Tagging.id_mapping where crm_account_id is not null 
--  and invalid_date = '9999-12-31'
--)tt2
--on tt1.crm_account_id = tt2.crm_account_id



--DA_Tagging.oms_time_filter OMS时间筛选数据源
---=========================================================================================================================================
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_4','oms_time_filter insert start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

delete from DA_Tagging.oms_time_filter
where place_date = @datadate;

-- daily新增oms时间筛选数据
-- SKU Level Order
-- truncate table DA_Tagging.oms_time_filter
insert into DA_Tagging.oms_time_filter(sales_member_id,sephora_card_no,sales_order_number,channel,platform,place_time
,place_date,sales,qtys,op_code,sku_code,brand,brand_type,adjustment_amount,category,subcategory,thirdcategory
,range,segment,skincare_function_basic,makeup_function,fragrances_stereotype,kol_theme,payed_amount)
select sales_member_id
  , member_card as sephora_card_no
  , sales_order_number as sales_order_number
  , channel as channel
  , store as platform
  , place_time as place_time
  , place_date as place_date
  , item_apportion_amount as sales
  , item_quantity as qtys
  , item_product_id as op_code
  , item_sku_cd as sku_code
  , brand as brand
  , brand_type as brand_type
  , item_adjustment_amount as adjustment_amount
  , category as category
  , subcategory as subcategory
  , thirdcategory as thirdcategory
  , item_range as range
  , item_segment as segment
  , skincare_function_basic as skincare_function_basic
  , makeup_function as makeup_function
  , fragrances_stereotype as fragrances_stereotype
  , kol_theme as kol_theme
  , payed_amount
from (
      select t1.member_card ,t1.member_id,sales_order_number
      ,case when t3.member_id COLLATE SQL_Latin1_General_CP1_CI_AS  is not null then t3.member_card COLLATE SQL_Latin1_General_CP1_CI_AS else t1.member_id end as sales_member_id
      ,place_time,place_date,item_sku_cd
      ,store,channel,item_apportion_amount, item_quantity, item_product_id, brand, brand_type,item_adjustment_amount
      ,category,subcategory,thirdcategory,item_range,item_segment,skincare_function_basic
      ,makeup_function,fragrances_stereotype,kol_theme,payed_amount
      from(
			select member_card,member_id,place_time ,place_date,item_sku_cd,item_quantity,item_product_id,sales_order_number
			,item_apportion_amount,item_adjustment_amount,t02.store COLLATE SQL_Latin1_General_CP1_CI_AS as store,t02.channel COLLATE SQL_Latin1_General_CP1_CI_AS as channel,item_range,item_segment,brand,brand_type,payed_amount
			from (
				select REPLACE(member_card,'JD','') as member_card,member_id,store_cd,channel_cd
					  ,place_time ,place_date,item_sku_cd,item_quantity,item_product_id,sales_order_number,item_apportion_amount,item_adjustment_amount
					  ,UPPER(SUBSTRING(item_range,1,1))+LOWER(SUBSTRING(item_range,2,( SELECT LEN(item_range))))  as item_range
					  ,UPPER(SUBSTRING(item_segment,1,1))+LOWER(SUBSTRING(item_segment,2,( SELECT LEN(item_segment))))  as item_segment
					  ,UPPER(SUBSTRING(item_brand_name,1,1))+LOWER(SUBSTRING(item_brand_name,2,( SELECT LEN(item_brand_name))))  as brand
					  ,UPPER(SUBSTRING(item_brand_type,1,1))+LOWER(SUBSTRING(item_brand_type,2,( SELECT LEN(item_brand_type))))  as brand_type
					  ,payed_amount
				from [DW_OMS].[V_Sales_Order_SKU_Level] 
				where is_placed_flag=1 and item_apportion_amount>0 
				and place_date = @datadate -- 取每天增量订单数据
			) t01 
        left outer join [DA_Tagging].[channel_store] t02 on t01.store_cd = t02.store_cd COLLATE SQL_Latin1_General_CP1_CI_AS and t01.channel_cd=t02.channel_cd COLLATE SQL_Latin1_General_CP1_CI_AS ) t1  
		left outer join ( select sku_code,category,subcategory,thirdcategory,skincare_function_basic,makeup_function,fragrances_stereotype,kol_theme from DA_Tagging.sephoraproductlist ) t2 on t1.item_sku_cd=t2.sku_code COLLATE SQL_Latin1_General_CP1_CI_AS
		left outer join ( select member_id,member_card from DA_Tagging.sales_member_id ) t3 on t1.member_id=t3.member_id COLLATE SQL_Latin1_General_CP1_CI_AS
)tt1


-- 2021-12-24 取消提供master_id
--insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
--select 'T2_4','oms_time_filter update start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

--update DA_Tagging.oms_time_filter
--set master_id = tt2.master_id
--from DA_Tagging.oms_time_filter tt1
--join (
--  select master_id,sales_member_id
--  from DA_Tagging.sales_id_mapping
--)tt2 
--on tt1.sales_member_id =  tt2.sales_member_id



-- Basic Level Order
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

delete from DA_Tagging.oms_time_filter_basic
where convert(date,place_time) = @datadate;


insert into DA_Tagging.oms_time_filter_basic(sales_order_number,sales_member_id,store,channel,item_vb_quantity,is_placed_flag
											,product_amount,place_time,place_date,adjustment_amount,city,district,member_card_grade)
select t1.sales_order_number
,case when t3.member_id  COLLATE SQL_Latin1_General_CP1_CI_AS is not null then t3.member_card  COLLATE SQL_Latin1_General_CP1_CI_AS else t1.member_id end as sales_member_id
,t2.store COLLATE SQL_Latin1_General_CP1_CI_AS,t2.channel COLLATE SQL_Latin1_General_CP1_CI_AS,t1.item_vb_quantity,t1.is_placed_flag,t1.product_amount
,t1.place_time,convert(date,t1.place_time) as place_date,t1.adjustment_amount,t1.city,t1.district,t1.member_card_grade
from(
   select sales_order_number,member_id,city,district
   ,case when member_card_grade in ('PINK','WHITE','BLACK','GOLD') 
   then UPPER(SUBSTRING(member_card_grade,1,1))+LOWER(SUBSTRING(member_card_grade,2,( SELECT LEN(member_card_grade)))) 
   else null end as member_card_grade
   ,store_cd,channel_cd,item_vb_quantity,is_placed_flag,product_amount,place_time,adjustment_amount
   from DW_OMS.V_Sales_Order_Basic_Level
   where is_placed_flag=1 and product_amount>0
   and  convert(date,place_time)= @datadate -- 取每天增量订单数据
   )t1
left outer join DA_Tagging.channel_store t2 on t1.store_cd = t2.store_cd  COLLATE SQL_Latin1_General_CP1_CI_AS and t1.channel_cd=t2.channel_cd COLLATE SQL_Latin1_General_CP1_CI_AS
left outer join DA_Tagging.sales_member_id t3 on t1.member_id = t3.member_id  COLLATE SQL_Latin1_General_CP1_CI_AS


-- VB Level Order
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
delete from DA_Tagging.oms_time_filter_vb
where convert(date,place_time) = @datadate;

insert into DA_Tagging.oms_time_filter_vb(
  sales_order_number,sales_member_id,store,channel,item_category,item_brand_type,item_quantity,item_brand_name
  ,item_brand_name_cn,item_sku_cd,is_placed_flag,item_apportion_amount,place_time,place_hour,wd_name,item_name,item_product_id,kol_theme)
select sales_order_number,case when t2.member_id  COLLATE SQL_Latin1_General_CP1_CI_AS is not null then t2.member_card COLLATE SQL_Latin1_General_CP1_CI_AS else t1.member_id end as sales_member_id
   ,t3.store COLLATE SQL_Latin1_General_CP1_CI_AS,t3.channel COLLATE SQL_Latin1_General_CP1_CI_AS,item_category,item_brand_type,item_quantity,item_brand_name
   ,item_brand_name_cn,item_sku_cd,is_placed_flag,item_apportion_amount,place_time,datepart( hour,place_time) as place_hour,wd_name,item_name,item_product_id,t4.kol_theme COLLATE SQL_Latin1_General_CP1_CI_AS
from(
       select sales_order_number,member_id,item_name,item_product_id,store_cd,channel_cd
           ,case when item_category='MAKE UP' then 'Makeup'
           else UPPER(SUBSTRING(item_category,1,1))+LOWER(SUBSTRING(item_category,2,( SELECT LEN(item_category)))) end as item_category
           ,UPPER(SUBSTRING(item_brand_type,1,1))+LOWER(SUBSTRING(item_brand_type,2,( SELECT LEN(item_brand_type))))  as item_brand_type
           ,UPPER(SUBSTRING(item_brand_name,1,1))+LOWER(SUBSTRING(item_brand_name,2,( SELECT LEN(item_brand_name))))  as item_brand_name
           ,datename(weekday, place_time) as wd_name
           ,item_quantity,item_brand_name_cn,item_sku_cd,is_placed_flag,item_apportion_amount,place_time
       from DW_OMS.V_Sales_Order_VB_Level 
	   where is_placed_flag=1 and item_apportion_amount>0
	   and convert(date,place_time)= @datadate -- 取每天增量订单数据
       )t1
left outer join DA_Tagging.sales_member_id t2 on t1.member_id=t2.member_id  COLLATE SQL_Latin1_General_CP1_CI_AS
left outer join DA_Tagging.channel_store t3 on t1.store_cd = t3.store_cd COLLATE SQL_Latin1_General_CP1_CI_AS and t1.channel_cd=t3.channel_cd  COLLATE SQL_Latin1_General_CP1_CI_AS
left outer join (
      select distinct sku_code,kol_theme 
      from DA_Tagging.sephoraproductlist
      where kol_theme is not null and kol_theme<>'' and kol_theme<>'null'
) t4 on t1.item_sku_cd=t4.sku_code COLLATE SQL_Latin1_General_CP1_CI_AS


--DA_Tagging.dwd_time_filter dwd-prod时间筛选数据源
---=========================================================================================================================================
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_4','dwd_time_filter insert start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

delete from DA_Tagging.dwd_time_filter
where dt = @datadate;

insert into  DA_Tagging.dwd_time_filter(
sensor_id,dt,time,op_code,behavior,brand,brand_type,category,subcategory,thirdcategory,range,segment
,product_line,skincare_function_basic,makeup_function,fragrances_stereotype,kol_theme
)
select sensor_id as sensor_id, dt, time, op_code, behavior, brand, brand_type, category, subcategory, thirdcategory, [range], segment, productline
 , skincare_function_basic  , makeup_function , fragrances_stereotype, kol_theme 
from(
    select sensor_id, dt, time,op_code, behavior,brand,brand_type,category,subcategory,thirdcategory,range,segment,productline,
        skincare_function_basic,makeup_function,fragrances_stereotype,kol_theme 
        from(
                select distinct user_id as sensor_id, dt, time, op_code, event
                ,case when event='viewCommodityDetail' then 'click'
                when event in ('addToShoppingcart','buyNow') then 'add'
                when event='submitOrder' then 'order'
                else null end as behavior
                from [STG_Sensor].[V_Events]
                where event in ('viewCommodityDetail','addToShoppingcart','submitOrder','buyNow') 
                and dt = @datadate
                ) t1 
        left outer join(
                select product_id,brand,brand_type,category,subcategory,thirdcategory,range,segment,productline,
                skincare_function_basic,makeup_function,fragrances_stereotype,kol_theme
                from DA_Tagging.sephoraproductlist
                ) t2 on t1.op_code=t2.product_id
)tt1


--insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
--select 'T2_4','dwd_time_filter update start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

--update DA_Tagging.dwd_time_filter
--set master_id = tt2.master_id
--from DA_Tagging.dwd_time_filter tt1
--join (
--  select master_id,sensor_id
--  from DA_Tagging.id_mapping where invalid_date = '9999-12-31'
--  and update_date = @datadate 
--)tt2 
--on tt1.sensor_id =  tt2.sensor_id
--where dt = @datadate
--;


--DA_Tagging.dwd_time_filter_noprod dwd-view时间筛选数据源
---=========================================================================================================================================

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_4','dwd_time_filter_noprod insert start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

delete from DA_Tagging.dwd_time_filter_noprod
where dt = @datadate;

insert into DA_Tagging.dwd_time_filter_noprod(sensor_id,dt,[time],op_code,page_type_detail,platform_type,[event],orderid,banner_content,beauty_article_id)
select sensor_id,  dt,[time], op_code,page_type_detail,platform_type ,[event],orderid,banner_content,beauty_article_id
from (
	  select user_id as sensor_id,dt,time,op_code,page_type_detail,platform_type,[event],orderid ,banner_content,beauty_article_id
	  from [STG_Sensor].[V_Events]
	  where dt = @datadate
		and (event in ('$pageview','$MPViewScreen','$AppViewScreen'--浏览相关Tag
						,'submitOrder' --浏览*转化 Tag
						,'viewCommodityDetail' -- campagin tag
						,'beautyIN_blog_view' ,'beautyIN_bottom_tab_click') --美印相关Tag
			or (banner_content LIKE N'%beautyIN%' or banner_content LIKE N'%美印%'))
	   
)tt1
;



--insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
--select 'T2_4','dwd_time_filter_noprod update start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

--update DA_Tagging.dwd_time_filter_noprod
--set master_id = tt2.master_id
--from DA_Tagging.dwd_time_filter_noprod tt1
--join (
--  select master_id,sensor_id
--  from DA_Tagging.id_mapping where invalid_date = '9999-12-31'
--  and update_date = @datadate 
--)tt2 
--on tt1.sensor_id =  tt2.sensor_id
--where dt = @datadate
--;


--DA_Tagging.dwd_time_filter_search dwd-search时间筛选数据源
---=========================================================================================================================================

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_4','dwd time filter search insert start..',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

delete from [DA_Tagging].[dwd_time_filter_search]
where dt = @datadate 
;

insert into [DA_Tagging].[dwd_time_filter_search](sensor_id,event, dt, time, banner_content)
select sensor_id, event, dt, time, banner_content
from(
	select  user_id as sensor_id,event,dt,time,banner_content
	from STG_Sensor.V_Events
	where banner_belong_area = 'searchview'
	and event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  
	and dt = @datadate 
	and banner_content is not NULL
)t1 
;


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_4','dwd time filter search insert end..',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;



--DA_Tagging.oms_time_filter_media TB-media时间筛选数据源
---=========================================================================================================================================
insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_4','oms time filter media insert start..',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;


delete from [DA_Tagging].[oms_time_filter_media]
where order_date = @datadate 
;


--t1.ss_device_id=id_mapping.device_id_IDFA 
insert into [DA_Tagging].[oms_time_filter_media](sephora_user_id, ss_os, ss_device_id, sales_order_number, member_card, androidId, idfa
, store_cd, channel_cd, ss_utm_source, ss_utm_medium, campaign_name, channel_name, payed_amount,order_date,order_time)
select sephora_user_id,ss_os,ss_device_id,sales_order_number,member_card
,androidId, idfa, store_cd, channel_cd,ss_utm_source,ss_utm_medium,campaign_name,channel_name,payed_amount,order_date,order_time
	from(
		select null as sephora_user_id, 'IOS' as ss_os, idfa as ss_device_id, OrderID as sales_order_number
		, null as member_card, null as androidId, idfa as idfa,null as store_cd, 'app' as channel_cd
		, null as ss_utm_source , null as ss_utm_medium
		, CampaignName as campaign_name,ChannelName as channel_name, PayedAmount as payed_amount
		, cast(left(convert(nvarchar(100),datekey),4)+'-'+substring(convert(nvarchar(100),datekey),5,2)+'-'+right(convert(nvarchar(100),datekey),2) as date)  as order_date
		, null as order_time
		from [DW_TD].[Tb_Fact_IOS_Ascribe]
		where PayedAmount>0 and PayedAmount  is not null and IsPlacedFlag=1
		and cast(left(convert(nvarchar(100),datekey),4)+'-'+substring(convert(nvarchar(100),datekey),5,2)+'-'+right(convert(nvarchar(100),datekey),2) as date) =@datadate 
	)t1


--ss_device_id=id_mapping.device_id_IMEI
insert into [DA_Tagging].[oms_time_filter_media](sephora_user_id, ss_os, ss_device_id, sales_order_number, member_card, androidId, idfa
	, store_cd, channel_cd, ss_utm_source, ss_utm_medium, campaign_name, channel_name, payed_amount,order_date,order_time)
select sephora_user_id,ss_os,ss_device_id,sales_order_number,member_card
,androidId, idfa, store_cd, channel_cd,ss_utm_source,ss_utm_medium,campaign_name,channel_name,payed_amount,order_date,order_time
	from(
		select null as sephora_user_id, 'Android' as ss_os, AndroidId as ss_device_id, OrderID as sales_order_number
		, null as member_card, AndroidId as androidId, null as idfa,null as store_cd, 'app' as channel_cd
		, null as ss_utm_source , null as ss_utm_medium
		, CampaignName as campaign_name,ChannelName as channel_name, PayedAmount as payed_amount
		, cast(left(convert(nvarchar(100),datekey),4)+'-'+substring(convert(nvarchar(100),datekey),5,2)+'-'+right(convert(nvarchar(100),datekey),2) as date) as order_date
		, null as order_time
		from [DW_TD].[Tb_Fact_Android_Ascribe]
		where PayedAmount>0 and PayedAmount  is not null and IsPlacedFlag=1
		and cast(left(convert(nvarchar(100),datekey),4)+'-'+substring(convert(nvarchar(100),datekey),5,2)+'-'+right(convert(nvarchar(100),datekey),2) as date) =  @datadate 
	)t1 


--id_mapping.sephora_card_no=member_card
insert into [DA_Tagging].[oms_time_filter_media](sephora_user_id, ss_os, ss_device_id, sales_order_number, member_card, androidId, idfa
	, store_cd, channel_cd, ss_utm_source, ss_utm_medium, campaign_name, channel_name, payed_amount,order_date,order_time)
select sephora_user_id,ss_os,ss_device_id,sales_order_number,member_card
,androidId, idfa, store_cd, channel_cd,ss_utm_source,ss_utm_medium,campaign_name,channel_name,payed_amount,order_date,order_time
from(
	select sephora_user_id, channel_cd as ss_os, null as ss_device_id, sales_order_number, member_card, null as androidId, null as idfa
	, store_cd, channel_cd, ss_utm_source, ss_utm_medium, null as campaign_name, null as channel_name
	, payed_amount, order_date, order_time 
	from [DW_Sensor].[DWS_Sensor_Order_UTM_Attribution]
	where attribution_type='1D' and payed_amount>0 and payed_amount is not null and is_placed_flag=1
	and order_date = @datadate 
)t1
left join DA_Tagging.coding_media_source t2  on t1.ss_utm_medium=t2.medium  COLLATE SQL_Latin1_General_CP1_CI_AS

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_4','oms time filter media insert end..',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
;

END
GO
