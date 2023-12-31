/****** Object:  StoredProcedure [TEST].[sp_visit_lauder_page_20220809]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_lauder_page_20220809] @days [int] AS
begin
delete from test.visit_lauder_page_20220809 where query_days = @days ;
delete from test.search_top_lauder_20220809 where query_days = @days ;
delete from test.browse_top_lauder_20220809 where query_days = @days ;

-- 搜索雅诗兰黛最多的用户（1个用户搜索次数最多的品牌为雅诗兰黛）
insert 	into test.search_top_lauder_20220809
select 	t4.master_id
		,t4.sephora_user_id
		,t4.sephora_card_no
		,t3.user_id
		,t3.search_content
		,t3.brand_name
		,t3.type
		,t3.search_cnt
		,@days as query_days
from
(
	select	t1.user_id,
			t1.search_content,           -- banner_content 拆分出来的名称
			t2.name as brand_name,      		-- coding_synonyms_match 中的名称
			t2.[type],
			t1.search_cnt,
			rank() over(partition by t1.user_id,t2.name order by t1.search_cnt desc) rank_num
	from
	(
		select	user_id,
				value as search_content,
				count(1) over(partition by user_id,banner_content) as search_cnt
		from	stg_sensor.v_events
		cross   apply string_split(banner_content, N'|')     -- 对banner_content进行分列处理 value
		where	banner_belong_area = 'searchview'
		and 	event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  -- 对platform_type,event做相应限制
		and 	[date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
	) t1
	left    join	da_tagging.coding_synonyms_match t2
	on 	 	t1.search_content = t2.synoyms collate chinese_prc_cs_ai_ws
) t3
left join
(
    select 	sensor_id
			,master_id
			,sephora_user_id
			,sephora_card_no
	from 	da_tagging.id_mapping
	where   invalid_date='9999-12-31'
) t4
on 		t3.user_id = t4.sensor_id
where 	t3.brand_name = N'雅诗兰黛'
and 	t3.rank_num = 1
;

-- 浏览雅诗兰黛最多的用户（1个用户浏览次数最多的品牌为雅诗兰黛）
insert 	into test.browse_top_lauder_20220809
select 	distinct
		p2.master_id
		,p2.sephora_user_id
		,p2.sephora_card_no
		,p1.user_id
		,p1.brand_name
		,p1.browse_cnt
		,@days as query_days
from
(
	select 	p.user_id
			,p.brand_name
			,p.browse_cnt
			,rank() over(partition by p.user_id,p.brand_name order by p.browse_cnt desc) rank_num
	from
	(
		select user_id,
				lower(brand) as brand_name,
				count(1) as browse_cnt
		from 	[da_tagging].v_events_session
		where 	event = 'viewCommodityDetail'
		and 	dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1)
		group 	by user_id,brand
	) p
) p1
left 	join
(
    select 	sensor_id
			,master_id
			,sephora_user_id
			,sephora_card_no
	from 	da_tagging.id_mapping where invalid_date='9999-12-31'
) p2
on 		p1.user_id = p2.sensor_id
where 	p1.brand_name = 'estee lauder'
and 	p1.rank_num = 1
;

-- 暂时注释掉，数据已经写进去了
-- 1年内购买过一次  这部分数据已经写入了，不用分180天和365天都去执行存储过程了
--insert into test.buy_one_count_20220809
--select  member_card
--        ,sephora_user_id
--        ,count(1) as cnt
--from    [dw_oms].[rpt_sales_order_sku_level]
--where   item_brand_name_cn = n'雅诗兰黛'
--and     [payment_time] between convert(date, dateadd(hour,8,getdate()) - 365) and convert(date,dateadd(hour,8,getdate()) - 1)
----and     member_card_grade <> 'pink' -- 卡别以最后身份为准
--and     member_card <> ''
--and     member_card is not null
--and     sephora_user_id <> ''
--and     sephora_user_id is not null
--group   by member_card, sephora_user_id
--having  count(1) >= 1 -- 等于1次的，只有12.4万人， >= 1时，24.2w
--;

insert  into test.visit_lauder_page_20220809
select	p2.sephora_user_id
		,p2.sephora_card_no
		,p2.user_id
		,p4.card_level
		,p2.search_cnt
		,p2.browse_cnt
		,@days query_days
from
(
	select 	p1.sephora_user_id
			,p1.sephora_card_no
			,p1.user_id
			,sum(p1.search_cnt) search_cnt
			,sum(p1.browse_cnt) browse_cnt
	from
	(
		select 	sephora_user_id
				,sephora_card_no
				,user_id
				,search_cnt
				,0 as browse_cnt
		from 	test.search_top_lauder_20220809
		where 	query_days = @days
		union 	all
		select 	sephora_user_id
				,sephora_card_no
				,user_id
				,0 as search_cnt
				,browse_cnt
		from 	test.browse_top_lauder_20220809
		where 	query_days = @days
	) p1
	group by p1.sephora_user_id,p1.sephora_card_no,user_id
) p2
inner   join test.buy_one_count p3 -- 购买雅诗兰黛一次以上的非粉卡用户(涉及到会员升级，是不)
on 	    p2.sephora_user_id = p3.sephora_user_id
and     p2.sephora_card_no = p3.member_card
left 	join dw_user.dws_user_info p4
on 		p2.sephora_card_no = p4.card_no
where 	p4.card_level <> 'PINK'
;
end
GO
