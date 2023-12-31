/****** Object:  StoredProcedure [TEST].[sp_visit_kiehls_page_20220809]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_kiehls_page_20220809] @days [int] AS
begin
delete from test.visit_kiehls_page_20220809 where query_days = @days ;
delete from test.search_kiehls_20220809 where query_days = @days ;
delete from test.browse_kiehls_20220809 where query_days = @days ;
-- 搜索科颜氏的用户
insert 	into test.search_kiehls_20220809
select 	t2.master_id
		,t2.sephora_user_id
		,t2.sephora_card_no
		,t1.user_id
		,t1.banner_content
		,t1.search_cnt
		,@days as query_days
from
(
	select	user_id,
			banner_content,
			count(1) as search_cnt
	from	STG_Sensor.V_Events
	--CROSS   APPLY STRING_SPLIT(banner_content, N'|')     -- 对banner_content进行分列处理 value
	where	banner_belong_area = 'searchview'
	and 	banner_content like '%科颜氏%' -- DA_Tagging.coding_synonyms_match 没有科颜氏，就直接查看搜索内容（banner_content），如果有科颜氏，则算
	and 	event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  -- 对platform_type,event做相应限制
	and 	[date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
	group 	by user_id,banner_content
) t1
left join
(
    select 	sensor_id
			,master_id
			,sephora_user_id
			,sephora_card_no
	from 	DA_Tagging.id_mapping where invalid_date='9999-12-31'
) t2
on 		t1.user_id = t2.sensor_id
;


-- 浏览科颜氏的用户
insert 	into test.browse_kiehls_20220809
select 	p1.master_id
		,p1.sephora_user_id
		,p1.sephora_card_no
		,p.user_id
		,p.brand_name
		,p.browse_cnt
		,@days as query_days
from
(
	select user_id,
			lower(brand) as brand_name,
			count(1) as browse_cnt
	from 	[DA_Tagging].v_events_session
	where 	event = 'viewCommodityDetail'
	and 	dt between convert(date,DATEADD(hour,8,getdate()) - @days) and convert(date,DATEADD(hour,8,getdate()) - 1)
	group 	by user_id,brand
) p
left 	join
(
    select 	sensor_id
			,master_id
			,sephora_user_id
			,sephora_card_no
	from 	DA_Tagging.id_mapping where invalid_date='9999-12-31'
) p1
on 		p.user_id = p1.sensor_id
where 	p.brand_name = 'kiehls'
;

-- 合并，取出非粉卡用户
insert  into test.visit_kiehls_page_20220809
select 	p1.sephora_user_id
		,p1.sephora_card_no
		,p2.card_level
		,p1.user_id
		,p1.search_cnt
		,p1.browse_cnt
		,@days query_days
from
(
	select 	p.sephora_user_id
			,p.sephora_card_no
			,p.user_id
			,sum(p.search_cnt) as search_cnt
			,sum(p.browse_cnt) as browse_cnt
	from
	(
		select 	sephora_user_id
				,sephora_card_no
				,user_id
				,search_cnt
				,0 as browse_cnt
		from 	test.search_kiehls_20220809
		where 	query_days = @days
		union 	all
		select 	sephora_user_id
				,sephora_card_no
				,user_id
				,0 as search_cnt
				,browse_cnt
		from 	test.browse_kiehls_20220809
		where 	query_days = @days
	) p
	group 	by p.sephora_user_id,p.sephora_card_no,p.user_id
) p1
left 	join dw_user.dws_user_info p2
on 		p1.sephora_card_no = p2.card_no
where 	p2.card_level <> 'PINK'
-- 	p2.card_level in ('BLACK','GOLD','WHITE')
;
end
GO
