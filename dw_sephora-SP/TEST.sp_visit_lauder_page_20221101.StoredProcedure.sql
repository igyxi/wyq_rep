/****** Object:  StoredProcedure [TEST].[sp_visit_lauder_page_20221101]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_lauder_page_20221101] @days [int] AS
begin
delete from test.visit_lauder_page_20221101 where query_days = @days ;
delete from test.search_top_lauder_20221101 where query_days = @days ;
delete from test.browse_top_lauder_20221101 where query_days = @days ;
delete from test.buy_lauder_20221101 ;
;
-- 浏览lauder 最多
insert into test.browse_top_lauder_20221101
select  t2.user_id
		,t2.browse_cnt
		,@days as query_days
from
(
	select  t1.user_id
--            ,t1.sap_brand_name
            ,t1.eb_brand_name
			,t1.browse_cnt
			,row_number() over(partition by t1.user_id order by t1.browse_cnt desc) as row_num
	from
	(
		select  p.user_id
--				,t.sap_brand_name
                ,t.eb_brand_name
				,sum(browse_cnt)  browse_cnt
		from
		(
			select  user_id
					--,date
					,try_cast(trim(op_code) as bigint) product_id
					,count(1) as browse_cnt
			from    STG_Sensor.Events
			where   event = 'viewCommodityDetail'
			and     [date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
			and     op_code is not null
			group   by user_id,op_code
		) p
		left   join
		(
			select eb_product_id as product_id,eb_brand_name,sap_brand_name from DWD.DIM_SKU_Info
			--where lower(sap_brand_name) = 'lauder'
		) t
		on  p.product_id = t.product_id
--		group by p.user_id,t.sap_brand_name
        group by p.user_id, t.eb_brand_name
	)   t1
) t2
where 	lower(t2.eb_brand_name) = 'lauder'
and 	t2.row_num = 1
;


-- 搜索兰蔻lauder最多的用户（1个用户搜索次数最多的品牌为兰蔻）
insert 	into test.search_top_lauder_20221101
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
			rank() over(partition by t1.user_id order by t1.search_cnt desc) rank_num
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
where 	t3.brand_name = N'兰蔻'
and 	t3.rank_num = 1
;

-- 半年内未购买过lauder，但一年半内购买过lauder且AB>1000的人群
insert into test.buy_lauder_20221101
select  p.member_card
		,p.sephora_user_id
		,p.half_year_cnt
		,p.half_year_amount
		,p.one_year_ago_amount
		,p.one_year_ago_cnt
        ,round(p.one_year_ago_amount / one_year_ago_cnt, 2) as avg_amount
from
(
	select  member_card
			,sephora_user_id
			,count(case when payment_date >= '2022-05-01' then item_apportion_amount end ) as half_year_cnt
			,sum(case when payment_date >= '2022-05-01' then item_apportion_amount else 0 end ) as half_year_amount
			,sum(case when payment_date >= '2021-05-01' and payment_date <= '2022-05-01' then item_apportion_amount else 0 end ) as one_year_ago_amount -- One and a half years
			,count(case when payment_date >= '2021-05-01' and payment_date <= '2022-05-01' then item_apportion_amount end ) as one_year_ago_cnt -- One and a half years
	from    [DW_OMS].[RPT_Sales_Order_SKU_Level]
	where   item_brand_name_cn = N'兰蔻'
	and     [payment_time] between convert(date, dateadd(hour,8,getdate()) - 545) and convert(date,dateadd(hour,8,getdate()) - 1) --545 一年半
	and     is_placed_flag = 1
	--and     member_card_grade <> 'PINK'
	and     member_card <> ''
	and     member_card is not null
	and     sephora_user_id <> ''
	and     sephora_user_id is not null
	group   by member_card, sephora_user_id
) p
where p.half_year_cnt = 0
and   p.one_year_ago_cnt >= 1
;


with tmp as
(
    select  t.sephora_user_id
            ,t.sephora_card_no
            ,sum(t.search_cnt) as search_cnt
            ,sum(t.browse_cnt) as browse_cnt
            ,sum(t.one_year_ago_amount) as one_year_ago_amount
            ,sum(t.one_year_ago_cnt) as one_year_ago_cnt
            ,sum(t.average_amount) as average_amount
    from
    (

        select  p1.sephora_user_id
                ,p1.sephora_card_no
                ,sum(p.search_cnt) search_cnt
                ,sum(p.browse_cnt) browse_cnt
                ,0 as one_year_ago_amount
                ,0 as one_year_ago_cnt
                ,0 as average_amount
        from
        (
            -- select  p.user_id
            --         ,p.search_cnt
            --         ,t.browse_cnt
            -- from    test.search_top_lauder_20221101 p
            -- inner 	join test.browse_top_lauder_20221101 t
            -- on 		p.user_id = t.user_id
            -- and 	p.query_days = t.query_days
            -- where 	p.query_days = @days
            -- and		t.query_days = @days

			select 	user_id
					,search_cnt
					,0 as browse_cnt
			from 	test.search_top_lauder_20221101
			where 	query_days = @days
			union  	all
			select 	user_id
					,0 as search_cnt
					,browse_cnt
			from 	test.browse_top_lauder_20221101
			where 	query_days = @days
        ) p
        left    join
        (
            select  sensor_id
                    ,sephora_user_id
                    ,sephora_card_no
            from    DA_Tagging.id_mapping
            where   invalid_date='9999-12-31'
        ) p1
        on      cast(p.user_id as nvarchar) = p1.sensor_id -- 为了取丝芙兰user_id
		group  	by p1.sephora_user_id,p1.sephora_card_no
        union   all
        select   sephora_user_id
                ,member_card  COLLATE Chinese_PRC_CS_AI_WS member_card
                ,0 as search_cnt
                ,0 as browse_cnt
                ,one_year_ago_amount
                ,one_year_ago_cnt
                ,average_amount
        from    test.buy_lauder_20221101
        where   average_amount >= 1000
    ) t
    group   by t.sephora_user_id,t.sephora_card_no
)


-- 结果数据
insert   into  test.visit_lauder_page_20221101
select  distinct
        p.sephora_user_id
        ,p.sephora_card_no
        ,t.card_level
        ,p.search_cnt
        ,p.browse_cnt
        ,p.one_year_ago_amount
        ,p.one_year_ago_cnt
        ,p.average_amount
        ,@days as query_days
        ,current_timestamp insert_time
from    tmp p
left    join dw_user.dws_user_info t
on      p.sephora_card_no = t.card_no
and     t.card_level in ('BLACK','GOLD','WHITE')
;
end
GO
