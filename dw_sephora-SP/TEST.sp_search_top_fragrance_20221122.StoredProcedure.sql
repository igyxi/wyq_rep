/****** Object:  StoredProcedure [TEST].[sp_search_top_fragrance_20221122]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_search_top_fragrance_20221122] @days [int] AS 
begin
delete from test.search_top_fragrance_20221122 where query_days=@days
insert 	into test.search_top_fragrance_20221122
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
			t2.name as category_name,      		-- coding_synonyms_match 中的名称
			t2.[type]
	from
	(
		select	user_id,
				value as search_content
		from	stg_sensor.v_events
		cross   apply string_split(banner_content, N'|')     -- 对banner_content进行分列处理 value
		where	banner_belong_area = 'searchview'
		and 	event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  -- 对platform_type,event做相应限制
		and 	[date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
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
	where   invalid_date='9999-12-31'
) t4
on 		t3.user_id = t4.sensor_id
left    join 
	DWD.DIM_Member_Info t
on      
	t4.sephora_card_no = t.member_card COLLATE Chinese_PRC_CS_AI_WS
where 	t3.category_name = N'香水'
group by 
    t4.sephora_user_id,
    t4.sephora_card_no,
    case when t.card_type=0 then 'PINK'
        when t.card_type=1 then 'WHITE'
        when t.card_type=2 then 'BLACK'
        when t.card_type=3 then 'GOLD'
    end
;
END
GO
