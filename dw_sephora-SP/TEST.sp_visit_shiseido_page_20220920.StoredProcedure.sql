/****** Object:  StoredProcedure [TEST].[sp_visit_shiseido_page_20220920]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_shiseido_page_20220920] @days [int] AS
begin
delete from test.visit_shiseido_page_20220920 where query_days = @days ;
delete from test.search_top_shiseido_20220920 where query_days = @days ;
delete from test.browse_top_shiseido_20220920 where query_days = @days ;
delete from test.buy_shiseido_one_count_20220920 where query_days = @days ;
;
 -- 浏览Shisedo 最多
insert into test.browse_top_shiseido_20220920
select  t2.user_id
		,t2.browse_cnt
		,@days as query_days
from
(
	select  t1.user_id
           ,t1.sap_brand_name
           ,t1.eb_level3_name
			,t1.browse_cnt
			,row_number() over(partition by t1.user_id order by t1.browse_cnt desc) as row_num
	from
	(
		select  p.user_id
				,t.sap_brand_name
				,t.eb_level3_name
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
			select eb_product_id as product_id,sap_brand_name,eb_level3_name from DWD.DIM_SKU_Info
			--where lower(sap_brand_name) = 'shiseido'
		) t
		on  p.product_id = t.product_id
		group by p.user_id,t.sap_brand_name,t.eb_level3_name
	)   t1
) t2
where 	(lower(t2.sap_brand_name) = 'shiseido'
or      eb_level3_name in (N'面部精华', N'眼部精华'))
and 	t2.row_num = 1
;
--

-- 搜索雅诗兰黛最多的用户（1个用户搜索次数最多的品牌为雅诗兰黛）
insert 	into test.search_top_shiseido_20220920
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
			t2.Synoyms,
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
--where 	t3.brand_name = N'资生堂'
where lower(t3.Synoyms) in (N'眼部精华', N'面部精华', N'资生堂', 'shiseido')
and 	t3.rank_num = 1
;


-- 半年内购买过一次 shiseido的非粉卡消费者, 这部分数据已经写入了，不用分180天和365天都去执行存储过程了
insert into test.buy_shiseido_one_count_20220920
select  member_card
        ,sephora_user_id
        ,count(1) as cnt
        , @days as query_days
from    [DW_OMS].[RPT_Sales_Order_SKU_Level]
where   item_brand_name_cn = N'资生堂'
and     [payment_time] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1)
--and     member_card_grade <> 'PINK'
and     member_card <> ''
and     member_card is not null
and     sephora_user_id <> ''
and     sephora_user_id is not null
group   by member_card, sephora_user_id
having  count(1) >= 1 -- 等于1次的，只有12.4万人， >= 1时，24.2W
;


with tmp as
(
    select  t.sephora_user_id
            ,t.sephora_card_no
            ,sum(t.search_cnt) as search_cnt
            ,sum(t.browse_cnt) as browse_cnt
            ,sum(t.buy_cnt) as buy_cnt
    from
    (

        select  p1.sephora_user_id
                ,p1.sephora_card_no
                ,sum(p.search_cnt) search_cnt
                ,sum(p.browse_cnt) browse_cnt
                ,0 buy_cnt
        from
        (
            -- select  p.user_id
            --         ,p.search_cnt
            --         ,t.browse_cnt
            -- from    test.search_top_shiseido_20220920 p
            -- inner 	join test.browse_top_shiseido_20220920 t
            -- on 		p.user_id = t.user_id
            -- and 	p.query_days = t.query_days
            -- where 	p.query_days = @days
            -- and		t.query_days = @days

			select 	user_id
					,search_cnt
					,0 as browse_cnt
			from 	test.search_top_shiseido_20220920
			where 	query_days = @days
			union  	all
			select 	user_id
					,0 as search_cnt
					,browse_cnt
			from 	test.browse_top_shiseido_20220920
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
                ,cnt as buy_cnt
        from    test.buy_shiseido_one_count_20220920
        where   query_days = @days
    ) t
    group   by t.sephora_user_id,t.sephora_card_no
)


-- 结果数据
insert   into  test.visit_shiseido_page_20220920
select  distinct
        p.sephora_user_id
        ,p.sephora_card_no
        ,t.card_level
        ,p.search_cnt
        ,p.browse_cnt
        ,p.buy_cnt
        ,@days as query_days
        ,current_timestamp insert_time
from    tmp p
left    join dw_user.dws_user_info t
on      p.sephora_card_no = t.card_no
where   t.card_level in ('BLACK','GOLD','WHITE')
;
end
GO
