/****** Object:  StoredProcedure [TEST].[sp_visit_shiseido_page_20221212]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_shiseido_page_20221212] @days [int] AS 
begin
delete from test.browse_top_shiseido_20221212 where query_days=@days;
delete from test.search_top_shiseido_20221212 where query_days=@days;
delete from test.visit_shiseido_page_20221212 where query_days=@days;

---------------------------半年内浏览过3次及以上shiseido的人群
insert into test.browse_top_shiseido_20221212
select  
		p1.sephora_user_id,
        p1.sephora_card_no,
        case when t.card_type=0 then 'PINK'
            when t.card_type=1 then 'WHITE'
            when t.card_type=2 then 'BLACK'
            when t.card_type=3 then 'GOLD'
        end as card_level,
		@days as query_days
from
(
	select  t1.user_id
            ,t1.eb_brand_name
            ,t1.browse_cnt
            -- ,row_number() over(partition by t1.user_id order by t1.browse_cnt desc) as row_num
	from
	(
		select  p.user_id
				,t.eb_brand_name
                ,sum(browse_cnt) as browse_cnt
		from
		(
			select  user_id
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
			select eb_product_id as product_id,eb_brand_name from DWD.DIM_SKU_Info
		) t
		on  p.product_id = t.product_id
		group by p.user_id,t.eb_brand_name
	)   t1
) t2
left    join
(
    select  sensor_id
            ,sephora_user_id
            ,sephora_card_no
    from    DA_Tagging.id_mapping
    where   invalid_date='9999-12-31' and sephora_card_no is not null
) p1
on      cast(t2.user_id as nvarchar) = p1.sensor_id    -- 为了取丝芙兰user_id
left    join 
	DWD.DIM_Member_Info t
on      
	p1.sephora_card_no = t.member_card COLLATE Chinese_PRC_CS_AI_WS
where   lower(t2.eb_brand_name) = 'shiseido'
and     t2.browse_cnt>=3
group by 
        p1.sephora_user_id,
        p1.sephora_card_no,
        case when t.card_type=0 then 'PINK'
            when t.card_type=1 then 'WHITE'
            when t.card_type=2 then 'BLACK'
            when t.card_type=3 then 'GOLD'
        end

------------------------半年内搜索过3次及以上shiseido的人群
insert 	into test.search_top_shiseido_20221212
select
		t4.sephora_user_id
		,t4.sephora_card_no
        ,case when t.card_type=0 then 'PINK'
            when t.card_type=1 then 'WHITE'
            when t.card_type=2 then 'BLACK'
            when t.card_type=3 then 'GOLD'
        end as card_level
		,@days as query_days
from
(
	select	t1.user_id,
			t1.search_content,           -- banner_content 拆分出来的名称
			t2.name as brand_name,      		-- coding_synonyms_match 中的名称
			t2.[type],
            t1.search_cnt
            -- rank() over(partition by t1.user_id order by t1.search_cnt desc) rank_num
	from
	(
		select	user_id,
				value as search_content,
                count(1) as search_cnt
		from	stg_sensor.v_events
		cross   apply string_split(banner_content, N'|')     -- 对banner_content进行分列处理 value
		where	banner_belong_area = 'searchview'
		and 	event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  -- 对platform_type,event做相应限制
		and 	[date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
        group   by user_id,[value]
	) t1
	left    join	da_tagging.coding_synonyms_match t2
	on 	 	t1.search_content = t2.synoyms collate chinese_prc_cs_ai_ws
) t3
left    join
(
    select 	
    		sensor_id
			,master_id
			,sephora_user_id
			,sephora_card_no
	from 	
		da_tagging.id_mapping
	where   invalid_date='9999-12-31' and sephora_card_no is not null
) t4
on 		t3.user_id = t4.sensor_id
left    join 
	DWD.DIM_Member_Info t
on      
	t4.sephora_card_no = t.member_card COLLATE Chinese_PRC_CS_AI_WS
where 	t3.brand_name = N'资生堂'
and     t3.search_cnt>=3
group by 
    t4.sephora_user_id,
    t4.sephora_card_no,
    case when t.card_type=0 then 'PINK'
        when t.card_type=1 then 'WHITE'
        when t.card_type=2 then 'BLACK'
        when t.card_type=3 then 'GOLD'
    end

--结果数据

insert into  test.visit_shiseido_page_20221212
select  
    p.sephora_user_id
    ,p.sephora_card_no
    ,p.card_level
    ,@days as query_days
    ,current_timestamp as insert_timestamp
from
(
    select  sephora_user_id,
            sephora_card_no,
            card_level
	from 	test.search_top_shiseido_20221212
	where 	query_days = @days
	union
    select  sephora_user_id,
            sephora_card_no,
            card_level
	from 	test.browse_top_shiseido_20221212
	where 	query_days = @days
) p
where   
	p.card_level in ('BLACK','GOLD','WHITE')
;
END 
GO
