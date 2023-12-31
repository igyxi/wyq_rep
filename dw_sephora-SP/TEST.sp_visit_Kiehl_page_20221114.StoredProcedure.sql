/****** Object:  StoredProcedure [TEST].[sp_visit_Kiehl_page_20221114]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_Kiehl_page_20221114] @days [int] AS
begin
delete from test.visit_Kiehl_page_20221114 where query_days = @days ;
delete from test.search_top_Kiehl_20221114 where query_days = @days ;
delete from test.browse_top_Kiehl_20221114 where query_days = @days ;
delete from test.buy_Kiehl_20221114 ;
;
-- 浏览Kiehl 最多
insert into test.browse_top_Kiehl_20221114
select  t2.user_id
		,t2.browse_cnt
		,@days as query_days
from
(
	select  t1.user_id
--            ,t1.sap_brand_name
            ,t1.eb_brand_name
            ,t1.segment
			,t1.browse_cnt
			,row_number() over(partition by t1.user_id order by t1.browse_cnt desc) as row_num
	from
	(
		select  p.user_id
--				,t.sap_brand_name
                ,t.eb_brand_name
                ,t.segment
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
			select eb_product_id as product_id,eb_brand_name,sap_brand_name,segment from DWD.DIM_SKU_Info
			--where lower(eb_brand_name) = 'Kiehl'
		) t
		on  p.product_id = t.product_id
--		group by p.user_id,t.sap_brand_name
        group by p.user_id, t.eb_brand_name,t.segment
	)   t1
) t2
where 	lower(t2.eb_brand_name) = 'kiehls'
--and     lower(t2.segment) in ('cream', 'serum')
--and 	t2.row_num = 1
group   by t2.user_id, t2.browse_cnt
;


-- 搜索Kiehls最多的用户（1个用户搜索次数最多的Kiehls）
insert 	into test.search_top_Kiehl_20221114
select 	t4.master_id
		,t4.sephora_user_id
		,t4.sephora_card_no
		,t3.user_id
		,t3.search_content
		,t3.brand_name
--        ,t3.product_id
		,t3.type
		,t3.search_cnt
		,@days as query_days
from
(
	select	t1.user_id,
			t1.search_content,           -- banner_content 拆分出来的名称
--			t2.name as brand_name,      		-- coding_synonyms_match 中的名称
--			t2.[type],
            '' as brand_name,
--            t1.product_id,
            '' as [type],
			t1.search_cnt,
			rank() over(partition by t1.user_id order by t1.search_cnt desc) rank_num
	from
	(
		select	user_id,
				value as search_content,
				count(1) as search_cnt
--				count(1) over(partition by user_id,banner_content) as search_cnt
		from	stg_sensor.v_events
		cross   apply string_split(banner_content, N'|')     -- 对banner_content进行分列处理 value
		where	banner_belong_area = 'searchview'
		and 	event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  -- 对platform_type,event做相应限制
		and 	[date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
		group   by user_id,value
	) t1
--	left    join	da_tagging.coding_synonyms_match t2
--	on 	 	t1.search_content = t2.synoyms collate chinese_prc_cs_ai_ws
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
where 	t3.search_content in (N'科颜氏', 'cream', 'serum', 'Kiehls', 'Kiehl')
-- and 	t3.rank_num = 1
;


-- 结果数据
insert  into  test.visit_Kiehl_page_20221114
select  distinct
        p2.sephora_user_id
        ,p2.sephora_card_no
        ,t1.card_level
        ,p2.search_cnt
        ,p2.browse_cnt
        ,p2.query_days
        ,current_timestamp insert_time
from
(
    select p1.sephora_user_id
            ,p1.sephora_card_no
            ,p1.user_id
            ,sum(p1.search_cnt) as search_cnt
			,sum(p1.browse_cnt) as browse_cnt
            ,p1.query_days
    from
    (
        select  sephora_user_id
                ,sephora_card_no  collate chinese_prc_ci_as sephora_card_no
                ,user_id
				,search_cnt
                ,0 as browse_cnt
                ,query_days
        from    test.search_top_Kiehl_20221114
        where   query_days = @days
		union   all
		select  t.sephora_user_id
                ,t.sephora_card_no
                ,p.user_id
                ,0 as search_cnt
				,p.browse_cnt
                ,query_days
		from    test.browse_top_Kiehl_20221114 p
        left    join
        (
            select  sensor_id
                    ,sephora_user_id
                    ,sephora_card_no
            from    DA_Tagging.id_mapping
            where   invalid_date='9999-12-31'
        ) t
        on      p.user_id = t.sensor_id
        where   p.query_days = @days
    ) p1
    group by p1.sephora_user_id,p1.sephora_card_no,p1.user_id,p1.query_days
) p2
left    join dw_user.dws_user_info t1
on      p2.sephora_card_no = t1.card_no
where   t1.card_level in ('BLACK','GOLD','WHITE')
;
end
GO
