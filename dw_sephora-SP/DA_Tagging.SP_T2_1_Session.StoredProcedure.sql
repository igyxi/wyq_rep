/****** Object:  StoredProcedure [DA_Tagging].[SP_T2_1_Session]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DA_Tagging].[SP_T2_1_Session] @datadate [date] AS
BEGIN

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','session start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

/** Engagement Tagging **/

-- Step1,user_tagging_engagement_initial,只建表一次，增量处理

--truncate table [DW_Sephora].[DA_Tagging].v_events_session
--go

-- Step2,user_tagging_engagement_daily,daily处理，给 event 打 session

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, lastdaty insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

truncate table [DW_Sephora].[DA_Tagging].v_events_lastday
-- go

insert into [DW_Sephora].[DA_Tagging].v_events_lastday(
    event,user_id,time,hour_name,week_name,ss_city,ss_province
    ,ss_title,ss_element_content,ss_url,ss_app_version
	,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
    ,banner_type,banner_content,banner_current_url,banner_current_page_type
    ,banner_belong_area,banner_to_url,banner_to_page_type,banner_ranking
    ,campaign_code,op_code,platform_type,orderid
    ,beauty_article_title,page_type_detail,page_type
    ,key_words,key_word_type,key_word_type_details
    ,product_id,brand,category,subcategory,thirdcategory,segment,productline,productfunction
    ,sephora_user_id,open_id,dt,behavior_type_coding,banner_coding,seqidtag,seqid
)
select event,user_id,time,hour_name,week_name,ss_city,ss_province
,ss_title,ss_element_content,ss_url,ss_app_version
,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
,banner_type,banner_content,banner_current_url,banner_current_page_type
,banner_belong_area,banner_to_url,banner_to_page_type,banner_ranking
,campaign_code,op_code,platform_type,orderid
,beauty_article_title,page_type_detail,page_type
,key_words,key_word_type,key_word_type_details
,product_id,brand,category,subcategory,thirdcategory,segment,productline,productfunction
,sephora_user_id,open_id,dt,behavior_type_coding,banner_coding,1 as seqidtag
,row_number() over(partition by platform_type,user_id order by time,eventID ) as seqid
from(
    select event,user_id,time
    ,case hour_name when 0 then '[0-1)' when 1 then '[1-2)' when 2 then '[2-3)' when 3 then '[3-4)' when 4 then '[4-5)'
                        when 5 then '[5-6)' when 6 then '[6-7)' when 7 then '[7-8)' when 8 then '[8-9)' when 9 then '[9-10)'
                        when 10 then '[10-11)' when 11 then '[11-12)' when 12 then '[12-13)' when 13 then '[13-14)' when 14 then '[14-15)'
                        when 15 then '[15-16)' when 16 then '[16-17)' when 17 then '[17-18)' when 18 then '[18-19)' when 19 then '[19-20)'
                        when 20 then '[20-21)' when 21 then '[21-22)' when 22 then '[22-23)' when 23 then '[23-0)' end as hour_name
    --,case when pmod(datediff(time, '1920-01-01') - 3, 7) = 1 then 'Monday'
    --        when pmod(datediff(time, '1920-01-01') - 3, 7) = 2 then 'Tuesday'
    --        when pmod(datediff(time, '1920-01-01') - 3, 7) = 3 then 'Wednesday'
    --        when pmod(datediff(time, '1920-01-01') - 3, 7) = 4 then 'Thursday'
    --        when pmod(datediff(time, '1920-01-01') - 3, 7) = 5 then 'Friday'
    --        when pmod(datediff(time, '1920-01-01') - 3, 7) = 6 then 'Saturday'
    --        else 'Sunday' end as week_name
	,week_name
    ,ss_city,ss_province,ss_title,ss_element_content,ss_url,ss_app_version
	,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
    ,banner_type,banner_content,banner_current_url,banner_current_page_type
    ,banner_belong_area,banner_to_url,banner_to_page_type,banner_ranking
    ,campaign_code,op_code,platform_type,orderid
    ,beauty_article_title,page_type_detail,page_type
    ,key_words,key_word_type,key_word_type_details
    ,t2.product_id,t3.brand_name as brand,t2.category,t2.subcategory,t2.thirdcategory,t2.segment,t2.productline
    ,case when t2.skincare_function_basic is not null then t2.skincare_function_basic else t2.makeup_function end as productfunction
    ,sephora_user_id,open_id,dt,behavior_type_coding,banner_coding,eventID
    ,row_number() over(partition by event,user_id,time,ss_city,ss_province,ss_title,ss_element_content,ss_url,ss_app_version
    ,banner_type,banner_content,banner_current_url,banner_current_page_type,banner_belong_area,banner_to_url
    ,banner_to_page_type,banner_ranking,campaign_code,op_code,platform_type,orderid,beauty_article_title
    ,page_type_detail,page_type,key_words,key_word_type,key_word_type_details
    ,sephora_user_id,open_id,dt order by time) as rn
    from(
        select event,user_id,dt,time,hour_name,week_name,ss_city,distinct_id
            ,ss_province,ss_title,ss_element_content,ss_url,ss_app_version
			,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
            ,banner_type,banner_content,banner_current_url,banner_current_page_type
            ,banner_belong_area,banner_to_url,banner_to_page_type,banner_ranking
            ,campaign_code
            ,case when event = 'viewCommodityDetail' and op_code is null then lead(coding_op_code,1) over(partition by user_id order by time)
                else op_code end as op_code
            ,platform_type,orderid
            ,beauty_article_title,page_type_detail,page_type
            ,key_words,key_word_type,key_word_type_details,sephora_user_id,open_id,behavior_type_coding,banner_coding
			,case when platform_type='app'  then 
						case event when '$AppStart' then 1 when '$AppViewScreen' then 2 when '$AppEnd' then 4 else 3 end
				  when platform_type='MiniProgram' then 
						case event when '$MPLaunch' then 1 when '$MPShow' then 2 when '$MPViewScreen' then 3 when '$MPHide' then 5 else 4 end
		     end as eventID
        from(
            select case when event='$AppStartPassively' then '$AppStart' else event end as event
					,user_id,dt,time,datename(hour,time) as hour_name,datename(weekday,[time]) as week_name,ss_city,distinct_id
                    ,ss_province,ss_title,ss_element_content,ss_url,ss_app_version
					,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
                    ,banner_type,banner_content,banner_current_url,banner_current_page_type
                    ,banner_belong_area,banner_to_url,banner_to_page_type,banner_ranking
                    ,campaign_code,op_code,platform_type,orderid
                    ,beauty_article_title,page_type_detail,page_type
                    ,key_words,key_word_type,key_word_type_details
					--,regexp_extract(ss_url,'([0-9]+)',0) as coding_op_code
					,case when ss_url like '%/product/%.html%' then left(substring(ss_url,charindex('/product/',ss_url) + 9,len(ss_url)),charindex('.html',substring(ss_url,charindex('/product/',ss_url) + 9,len(ss_url))) - 1) else null end as coding_op_code
					--,case when distinct_id rlike '^\\d+$' then distinct_id else null end as sephora_user_id
					,case when isnumeric(distinct_id) = 1 then distinct_id else null end as sephora_user_id
					,case when distinct_id like 'oCOkA%' then distinct_id else null end as open_id
					--,case when event like '%Click%' or event like '%click%' then 'Click' else null end as behavior_type_coding
					,case when event like '%click%' then 'Click' else null end as behavior_type_coding
					,case when platform_type='app' then
						case when (event='$AppViewScreen' or event='$pageview') and page_type_detail='campaign_page' then N'榜单页'
								when (event='$AppViewScreen' or event='$pageview') and page_type_detail like 'category%' then N'分类'
								when event like'beautyIN_%' or (event ='$pageview' and page_type_detail='beautyCommunity') then N'美in'
								when (event='$AppViewScreen' or event='$pageview') and (page_type_detail='brand_list'
								or page_type_detail='brand_navigation') then N'全部品牌'
								when (event='$AppViewScreen' or event='$pageview') and (page_type_detail='search'
								or page_type_detail='search-navigation') then N'搜索'
						end
					when platform_type='MiniProgram' then
						case when event='$MPViewScreen' and page_type_detail='miniprogram_campaign' then N'榜单页'
								when event='$MPViewScreen' and page_type_detail like 'category%' then N'分类'
								when event like'beautyIN_%' then N'美in'
								when event='$MPViewScreen' and (page_type_detail='brand_list'
								or page_type_detail='brand_navigation') then N'全部品牌'
								when event='$MPViewScreen' and page_type_detail='search-navigation' then N'搜索'
							end
					end as banner_coding
			from
            DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
            where dt = @datadate
        ) as t0
    )t1
    left join [DW_Sephora].[DA_Tagging].sephoraproductlist t2
    on t1.op_code=t2.product_id
	-- 20211207，brand修改为从[DW_Product].[V_SKU_Profile]取数
	left join (
		select distinct case brand_name when 'ACQUA DI PARMA SRL' then 'ACQUA DI PARMA'
										when 'BEAUTYBLENDER' then 'BEAUTY BLENDER'
										when 'DR.JART+' then 'DR. JART+'
										when 'ESTEELAUDER' then 'ESTEE LAUDER'
										when 'FRESH SAS' then 'FRESH'
										when 'LAUDER' then 'ESTEE LAUDER'
										when 'MSNAIL' then 'MS NAIL'
										when 'NUFACE (CAROLE COLE CPANY)' then 'NUFACE'
										when 'SHU' then 'SHUUEMURA'
										when 'SKII' then 'SK-II'
										when 'YA-MAN' then 'YAMAN'
										when 'YVES ST LAURENT' then 'YSL'
										when 'ANNASUI' then 'ANNA SUI'
										when 'ATELIERCOLOGNE' then 'ATELIER COLOGNE'
										when 'BOBBIBROWN' then 'BOBBI BROWN'
										when 'CALVINKLEIN' then 'CALVIN KLEIN'
										when 'DOLCE&GABBANA' then 'DOLCE & GABBANA'
										when 'GIORGIOARMANI' then 'ARMANI'
										when 'DRJART' then 'DR. JART+'
										when 'HUGOBOSS' then 'HUGO BOSS'
										when 'LABSERIES' then 'LAB SERIES'
										when 'LOLITALEMPICKA' then 'LOLITA LEMPICKA'
										when 'MAKEUPFOREVER' then 'MAKE UP FOR EVER'
										when 'MENARDSP' then 'MENARD SP'
										when 'PACORABANNE' then 'PACO RABANNE'
										when 'VAN CLEEF & ARPELS' then 'VAN CLEEF'
										when 'WEI' then 'WEI BEAUTY'
										else brand_name end as brand_name,convert(nvarchar(255),product_id) as product_id
		from [DW_Sephora].[DW_Product].[V_SKU_Profile]
	) t3
	on t1.op_code=t3.product_id
) as temp
where rn=1
-- go

--print( CONVERT(varchar(100), DATEADD(hour,8,getdate()), 21) + ' Event Session, banner_coding update Start...')
--go

--update [DW_Sephora].[DA_Tagging].v_events_lastday
--set banner_coding = case when platform_type='app' then
--						case when (event='$AppViewScreen' or event='$pageview') and page_type_detail='campaign_page' then N'榜单页'
--								when (event='$AppViewScreen' or event='$pageview') and page_type_detail like 'category%' then N'分类'
--								when event like'beautyIN_%' or (event ='$pageview' and page_type_detail='beautyCommunity') then N'美in'
--								when (event='$AppViewScreen' or event='$pageview') and (page_type_detail='brand_list'
--								or page_type_detail='brand_navigation') then N'全部品牌'
--								when (event='$AppViewScreen' or event='$pageview') and (page_type_detail='search'
--								or page_type_detail='search-navigation') then N'搜索'
--						end
--					when platform_type='MiniProgram' then
--						case when event='$MPViewScreen' and page_type_detail='miniprogram_campaign' then N'榜单页'
--								when event='$MPViewScreen' and page_type_detail like 'category%' then N'分类'
--								when event like'beautyIN_%' then N'美in'
--								when event='$MPViewScreen' and (page_type_detail='brand_list'
--								or page_type_detail='brand_navigation') then N'全部品牌'
--								when event='$MPViewScreen' and page_type_detail='search-navigation' then N'搜索'
--							end
--					end
--go

--print( CONVERT(varchar(100), DATEADD(hour,8,getdate()), 21) + ' Event Session, behavior_type_coding update Start...')
--go

--update [DW_Sephora].[DA_Tagging].v_events_lastday
--set behavior_type_coding = case when event like '%Click%' or event like '%click%' then 'Click' else null end
--go

--print( CONVERT(varchar(100), DATEADD(hour,8,getdate()), 21) + ' Event Session, seqidtag update Start...')
--go

--update [DW_Sephora].[DA_Tagging].v_events_lastday
--set seqidtag = 1
--go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, event add 1 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].v_events_lastday(
    event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type
    ,sephora_user_id,open_id,dt,seqidtag
)
select case when platform_type='app' then '$AppStart'
            when platform_type='MiniProgram' then '$MPLaunch' end as event
,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type
,sephora_user_id,open_id,dt, 0 as seqidtag
from [DW_Sephora].[DA_Tagging].v_events_lastday
where (seqid=1 and event!='$AppStart' and platform_type='app')
    or (seqid=1 and event!='$MPLaunch' and platform_type='MiniProgram')
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, event add 2 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].v_events_lastday(
    event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type
    ,sephora_user_id,open_id,dt,seqid,seqidtag)
select case when platform_type='app' then '$AppEnd'
            when platform_type='MiniProgram' then '$MPHide' end as event
,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type
,sephora_user_id,open_id,dt ,seqid+1 as seqid, 2 as seqidtag
from(
    select user_id,event,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid
    ,max(seqid) over(partition by platform_type,USER_ID) mid
    from [DW_Sephora].[DA_Tagging].v_events_lastday
)temp
where (seqid=mid and event!='$AppEnd' and platform_type='app')
    or (seqid=mid and event!='$MPHide' and platform_type='MiniProgram') 
	-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, event add 3 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

insert into [DW_Sephora].[DA_Tagging].v_events_lastday(
event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type
,sephora_user_id,open_id,dt,seqidtag)
select case when t1.platform_type='app' then '$AppEnd'
            when t1.platform_type='MiniProgram' then '$MPHide' end as event
,t1.user_id,t2.time,t2.hour_name,t2.week_name,t2.ss_city,t2.ss_province,t2.platform_type
,t2.sephora_user_id,t2.open_id,t2.dt,2 as seqidtag
from(
    select event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid
    from [DW_Sephora].[DA_Tagging].v_events_lastday
    where event='$AppStart' or event='$MPLaunch'
)t1
left join(
    select event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid
    from [DW_Sephora].[DA_Tagging].v_events_lastday
)t2
on t1.platform_type=t2.platform_type and t1.user_id=t2.user_id and t1.seqid=t2.seqid+1
where t2.event is not null
and t2.event!='$AppEnd'
and t2.event!='$MPHide'
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, seqid update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

IF OBJECT_ID(N'tempdb..#v_events_lastday_temp1', N'U') IS NOT NULL 
DROP TABLE #v_events_lastday_temp1
-- go

CREATE TABLE #v_events_lastday_temp1(
    event nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    user_id bigint,
    hour_name nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    week_name nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    time datetime,
    ss_city nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_province nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_title nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_element_content nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_url nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_app_version nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
	ss_utm_medium nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
	ss_utm_source nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
	ss_os nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
	ss_device_id nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_content nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_current_url nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_current_page_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_belong_area nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_to_url nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_to_page_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_ranking nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_coding nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    behavior_type_coding nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    campaign_code nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    op_code nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    platform_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    orderid nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    beauty_article_title nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    page_type_detail nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    page_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    key_words nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    key_word_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    key_word_type_details nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    product_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    brand nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    category nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    subcategory nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    thirdcategory nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    segment nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    productline nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    productfunction nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    sephora_user_id nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    open_id nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    dt nvarchar(10) collate Chinese_PRC_CS_AI_WS,
    seqid int,
    seqidtag int
)
-- go

insert into #v_events_lastday_temp1
select event,user_id,hour_name,week_name,time,ss_city,ss_province,ss_title,ss_element_content,ss_url,ss_app_version,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
,banner_type,banner_content,banner_current_url,banner_current_page_type,banner_belong_area,banner_to_url,banner_to_page_type
,banner_ranking,banner_coding,behavior_type_coding,campaign_code,op_code,platform_type,orderid,beauty_article_title,page_type_detail
,page_type,key_words,key_word_type,key_word_type_details,product_id,brand,category,subcategory,thirdcategory,segment,productline
,productfunction,sephora_user_id,open_id,dt
,row_number() over(partition by platform_type,user_id order by time,seqidtag,seqid) as seqid,1 as seqidtag
from [DW_Sephora].[DA_Tagging].v_events_lastday
-- go

--update [DW_Sephora].[DA_Tagging].v_events_lastday
--set seqid = t2.seqid_new,
--	seqidtag = 1
--from [DW_Sephora].[DA_Tagging].v_events_lastday as t1
--join (
--	select rid,row_number() over(partition by platform_type,user_id order by time,seqidtag,seqid) as seqid_new
--	from [DW_Sephora].[DA_Tagging].v_events_lastday
--) as t2
--on t1.rid = t2.rid
--go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, event add 4 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

-- 'AppEnd' 的下一个事件如果不是'$AppStart' ,插入一行'$Appstart' event_time=next_event_time
insert into #v_events_lastday_temp1
(event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type
,sephora_user_id,open_id,dt,seqidtag)
select case when t1.platform_type='app' then '$AppStart'
            when t1.platform_type='MiniProgram' then '$MPLaunch' end as event
,t1.user_id,t2.time,t2.hour_name,t2.week_name,t2.ss_city,t2.ss_province,t2.platform_type
,t2.sephora_user_id,t2.open_id,t2.dt ,0 as seqidtag
from(
    select event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid
    from #v_events_lastday_temp1
    where event='$AppEnd' or event='$MPHide'
)t1
left join(
    select event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid
    from #v_events_lastday_temp1
)t2
on t1.platform_type=t2.platform_type and t1.user_id=t2.user_id and t1.seqid=t2.seqid-1
where t2.event is not null
and t2.event!='$AppStart'
and t2.event!='$MPLaunch'
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, seqid update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go


--===========================================================================================================
IF OBJECT_ID(N'tempdb..#v_events_lastday_temp2', N'U') IS NOT NULL 
DROP TABLE #v_events_lastday_temp2
CREATE TABLE #v_events_lastday_temp2(
    event nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    user_id bigint,
    hour_name nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    week_name nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    time datetime,
    ss_city nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_province nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_title nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_element_content nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_url nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_app_version nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_utm_medium nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_utm_source nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_os nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    ss_device_id nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_content nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_current_url nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_current_page_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_belong_area nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_to_url nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_to_page_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_ranking nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    banner_coding nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    behavior_type_coding nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    campaign_code nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    op_code nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    platform_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    orderid nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    beauty_article_title nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    page_type_detail nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    page_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    key_words nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    key_word_type nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    key_word_type_details nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    product_id nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    brand nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    category nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    subcategory nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    thirdcategory nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    segment nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    productline nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    productfunction nvarchar(255) collate Chinese_PRC_CS_AI_WS,
    sephora_user_id nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    open_id nvarchar(4000) collate Chinese_PRC_CS_AI_WS,
    dt nvarchar(10) collate Chinese_PRC_CS_AI_WS,
    seqid int,
    seqidtag int
)


insert into #v_events_lastday_temp2
select event,user_id,hour_name,week_name,time,ss_city,ss_province,ss_title,ss_element_content,ss_url,ss_app_version,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
,banner_type,banner_content,banner_current_url,banner_current_page_type,banner_belong_area,banner_to_url,banner_to_page_type
,banner_ranking,banner_coding,behavior_type_coding,campaign_code,op_code,platform_type,orderid,beauty_article_title,page_type_detail
,page_type,key_words,key_word_type,key_word_type_details,product_id,brand,category,subcategory,thirdcategory,segment,productline
,productfunction,sephora_user_id,open_id,dt
,row_number() over(partition by platform_type,user_id order by time,seqidtag,seqid) as seqid,1 as seqidtag
from #v_events_lastday_temp1



-- Insert Append/MPHide where seqtime>30min
 insert into #v_events_lastday_temp2(event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid,seqidtag)
    select case when platform_type='app' then '$AppEnd' when platform_type='MiniProgram' then '$MPHide' end as event
    ,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid, 2 as seqidtag
    from(
        select user_id,event,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid
        ,(DATEDIFF(SS,'1970-1-1 00:00:00',lead(time,1,time) over(partition by platform_type,user_id order by seqid))- DATEDIFF(SS,'1970-1-1 00:00:00',time)) /60.0 nn
        from #v_events_lastday_temp2
    )temp where (nn>30 and event!='$AppEnd' and platform_type='app')  or (nn>30 and event!='$MPHide' and platform_type='MiniProgram') ;



-- Insert Appstart/MPLaunch where seqtime>30min
insert into #v_events_lastday_temp2(event,user_id,time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,dt,seqid,seqidtag)
    select case when platform_type='app' then '$AppStart' when platform_type='MiniProgram' then '$MPLaunch' end as event
    ,user_id,next_time as time,hour_name,week_name,ss_city,ss_province,platform_type,sephora_user_id,open_id,next_dt,seqid+1 as seqid, 0 as seqidtag
    from(
        select user_id,event,lead(time,1,time) over(partition by platform_type,user_id order by seqid) next_time
        ,lead(hour_name,1,hour_name) over(partition by platform_type,user_id order by seqid) hour_name
        ,lead(week_name,1,week_name) over(partition by platform_type,user_id order by seqid) week_name
        ,ss_city,ss_province,platform_type,sephora_user_id,open_id
        ,lead(dt,1,dt) over(partition by platform_type,user_id order by seqid) next_dt,seqid       
        ,(DATEDIFF(SS,'1970-1-1 00:00:00',lead(time,1,time) over(partition by platform_type,user_id order by seqid)) - DATEDIFF(SS,'1970-1-1 00:00:00',time)) /60.0 nn
        ,(lead(event,1,event) over(partition by platform_type,user_id order by seqid)) Nevent
        from #v_events_lastday_temp2
    )temp where (nn>30 and event = '$AppEnd' and Nevent!='$AppStart' and platform_type='app') or (nn>30 and event= '$MPHide'and Nevent!='$MPLaunch' and platform_type='MiniProgram') ;
;



truncate table [DW_Sephora].[DA_Tagging].v_events_lastday
-- go



insert into [DW_Sephora].[DA_Tagging].v_events_lastday
select event,user_id,hour_name,week_name,time,ss_city,ss_province,ss_title,ss_element_content,ss_url,ss_app_version
,banner_type,banner_content,banner_current_url,banner_current_page_type,banner_belong_area,banner_to_url,banner_to_page_type
,banner_ranking,banner_coding,behavior_type_coding,campaign_code,op_code,platform_type,orderid,beauty_article_title,page_type_detail
,page_type,key_words,key_word_type,key_word_type_details,product_id,brand,category,subcategory,thirdcategory,segment,productline
,productfunction,sephora_user_id,open_id,dt
,row_number() over(partition by platform_type,user_id order by time,seqidtag,seqid) as seqid,1 as seqidtag
,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
from #v_events_lastday_temp2
-- go

--update [DW_Sephora].[DA_Tagging].v_events_lastday
--set seqid = t2.seqid_new,
--	seqidtag = 1
--from [DW_Sephora].[DA_Tagging].v_events_lastday as t1
--join (
--	select rid,row_number() over(partition by platform_type,user_id order by time,seqidtag,seqid) as seqid_new
--	from [DW_Sephora].[DA_Tagging].v_events_lastday
--) as t2
--on t1.rid = t2.rid
---- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, lastday_session_temp Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

truncate table [DW_Sephora].[DA_Tagging].v_events_lastday_session_temp
-- go

insert into [DW_Sephora].[DA_Tagging].v_events_lastday_session_temp
select  platform_type,user_id,event,seqid,time
        ,rank()over(partition by platform_type,user_id order by seqid) rn
        ,lag(event,1) over(partition by platform_type,user_id order by seqid) as Levent
        ,LEAD(event,1) over(partition by platform_type,user_id order by seqid) as Hevent
        ,LEAD(seqid,1) over(partition by platform_type,user_id order by seqid) as Hseqid
        ,LEAD(seqid,2) over(partition by platform_type,user_id order by seqid) as Hseqid_2
        ,LEAD(time,1) over(partition by platform_type,user_id order by seqid) as Htime
        ,LEAD(time,2) over(partition by platform_type,user_id order by seqid) as Htime_2
from [DW_Sephora].[DA_Tagging].v_events_lastday
where event in('$AppStart','$AppEnd','$MPLaunch','$MPHide')
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, session_temp0 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

truncate table [DW_Sephora].[DA_Tagging].session_temp0
-- go

insert into [DW_Sephora].[DA_Tagging].session_temp0
select * ,datediff(ss,Ltime,Htime)/60.0 as sessiontime --(unix_timestamp(Htime) - unix_timestamp(Ltime))/60.0 as sessiontime
,rank()over(partition by platform_type,user_id order by Lseqid) rk
from(
        select platform_type,user_id, EVENT,RN
            ,case when platform_type='app' and Levent ='$AppStart' then null 
                    when platform_type='MiniProgram' and Levent ='$MPLaunch' then null 
                    else seqid end as Lseqid
            ,case when platform_type='app' and event='$AppStart' and Hevent ='$AppStart' then Hseqid_2
                    when platform_type='MiniProgram' and event='$MPLaunch' and Hevent ='$MPLaunch' then Hseqid_2
                    else Hseqid end Hseqid
            ,case when platform_type='app' and Levent ='$AppStart' then null 
                    when platform_type='MiniProgram' and Levent ='$MPLaunch' then null 
                    else time end as Ltime
            ,case when platform_type='app' and event='$AppStart' and Hevent ='$AppStart' then Htime_2 
                    when platform_type='MiniProgram' and event='$MPLaunch' and Hevent ='$MPLaunch' then Htime_2
                    else Htime end Htime
    from [DW_Sephora].[DA_Tagging].v_events_lastday_session_temp
)t2
where (event ='$AppStart' and platform_type='app' and Lseqid is not null)
    or (event ='$MPLaunch' and platform_type='MiniProgram' and Lseqid is not null)
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, session_temp1 Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

truncate table [DW_Sephora].[DA_Tagging].session_temp1
-- go

insert into [DW_Sephora].[DA_Tagging].session_temp1
select platform_type,user_id,max(sessionid) as maxsessionid
from [DW_Sephora].[DA_Tagging].v_events_session
group by platform_type,user_id
-- go


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, result insert Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

delete from [DW_Sephora].[DA_Tagging].v_events_session
where dt = @datadate

insert into [DW_Sephora].[DA_Tagging].v_events_session(
    event,user_id,time,hour_name,week_name,ss_city,ss_province
    ,ss_title,ss_element_content,ss_url,ss_app_version
	,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
    ,banner_type,banner_content,banner_current_url,banner_current_page_type
    ,banner_belong_area,banner_to_url,banner_to_page_type,banner_ranking,banner_coding,behavior_type_coding
    ,campaign_code,op_code,platform_type,orderid
    ,beauty_article_title,page_type_detail,page_type
    ,key_words,key_word_type,key_word_type_details
    ,product_id,brand,category,subcategory,thirdcategory,segment,productline,productfunction
    ,sephora_user_id,open_id,dt,sessionid,seqid
    ,sessiontime
)
select event,tb1.user_id,time,hour_name,week_name,ss_city,ss_province
    ,ss_title,ss_element_content,ss_url,ss_app_version
	,ss_utm_medium,ss_utm_source,ss_os,ss_device_id
    ,banner_type,banner_content,banner_current_url,banner_current_page_type
    ,banner_belong_area,banner_to_url,banner_to_page_type,banner_ranking,banner_coding,behavior_type_coding
    ,campaign_code,op_code,tb1.platform_type,orderid
    ,beauty_article_title,page_type_detail,page_type
    ,key_words,key_word_type,key_word_type_details
    ,product_id,brand,category,subcategory,thirdcategory,segment,productline,productfunction
    ,sephora_user_id,open_id,dt,sessionid+case when maxsessionid is null then 0 else maxsessionid end,seqid
    ,sessiontime
from (
    select tt1.event,tt1.user_id,tt1.time,tt1.hour_name,tt1.week_name,tt1.ss_city,tt1.ss_province
        ,tt1.ss_title,tt1.ss_element_content,tt1.ss_url,tt1.ss_app_version
		,tt1.ss_utm_medium,tt1.ss_utm_source,tt1.ss_os,tt1.ss_device_id
        ,tt1.banner_type,tt1.banner_content,tt1.banner_current_url,tt1.banner_current_page_type
        ,tt1.banner_belong_area,tt1.banner_to_url,tt1.banner_to_page_type,tt1.banner_ranking,tt1.banner_coding,tt1.behavior_type_coding
        ,tt1.campaign_code,tt1.op_code,tt1.platform_type,tt1.orderid
        ,tt1.beauty_article_title,tt1.page_type_detail,tt1.page_type
        ,tt1.key_words,tt1.key_word_type,tt1.key_word_type_details
        ,tt1.product_id,tt1.brand,tt1.category,tt1.subcategory,tt1.thirdcategory,tt1.segment,tt1.productline,tt1.productfunction
        ,tt1.sephora_user_id,tt1.open_id,tt1.dt
        ,tt2.rk as sessionid,RANK()over(partition by tt1.platform_type,tt1.user_id,rk order by seqid) seqid
        ,cast(tt2.sessiontime as decimal(18,2)) sessiontime
    from [DW_Sephora].[DA_Tagging].v_events_lastday tt1
    join [DW_Sephora].[DA_Tagging].session_temp0 tt2
    on tt1.platform_type=tt2.platform_type and tt1.user_id=tt2.user_id	
    where tt1.seqid between Lseqid and Hseqid 
)tb1
left join [DW_Sephora].[DA_Tagging].session_temp1 tb2
on tb1.user_id=tb2.user_id and tb1.platform_type=tb2.platform_type
-- go

insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','Event Session, result update Start',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())

;with Updatetemp as (
	select user_id,platform_type,event,time,test_version,vip_card,vip_card_type,ss_is_first_day
	from DW_Sephora.[STG_Sensor].[V_Events] with(nolock)
	where dt = @datadate	
	group by user_id,platform_type,event,time,test_version,vip_card,vip_card_type,ss_is_first_day
)

update [DW_Sephora].[DA_Tagging].v_events_session
set test_version = b.test_version
	,vip_card = b.vip_card
	,vip_card_type = b.vip_card_type
	,ss_is_first_day = b.ss_is_first_day
--select a.user_id,a.platform_type,a.event,a.time,b.user_id,b.platform_type,b.event,b.time,b.test_version,b.vip_card,b.vip_card_type,b.ss_is_first_day
from [DW_Sephora].[DA_Tagging].v_events_session as a
join Updatetemp as b
on a.user_id = b.user_id and a.platform_type = b.platform_type and a.event = b.event and a.time = b.time and a.dt = @datadate


insert into [DW_Sephora].DA_Tagging.Execution_Log(project,detail,start_time,update_date)
select 'T2_1','session end',DATEADD(hour,8,getdate()),DATEADD(hour,8,getdate())
-- go

END
GO
