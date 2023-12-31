/****** Object:  StoredProcedure [TEST].[sp_browse_top_fragrance_20221122]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_browse_top_fragrance_20221122] @days [int] AS 
begin
truncate table test.browse_top_fragrance_20221122
insert into test.browse_top_fragrance_20221122
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
            ,t1.eb_category
	from
	(
		select  p.user_id
				,t.eb_category
		from
		(
			select  user_id
					,try_cast(trim(op_code) as bigint) product_id
			from    STG_Sensor.Events
			where   event = 'viewCommodityDetail'
			and     [date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
			and     op_code is not null
			group   by user_id,op_code
		) p
		left   join
		(
			select eb_product_id as product_id,eb_category from DWD.DIM_SKU_Info
		) t
		on  p.product_id = t.product_id
		group by p.user_id,t.eb_category
	)   t1
) t2
left    join
(
    select  sensor_id
            ,sephora_user_id
            ,sephora_card_no
    from    DA_Tagging.id_mapping
    where   invalid_date='9999-12-31'
) p1
on      cast(t2.user_id as nvarchar) = p1.sensor_id    -- 为了取丝芙兰user_id
left    join 
	DWD.DIM_Member_Info t
on      
	p1.sephora_card_no = t.member_card COLLATE Chinese_PRC_CS_AI_WS
where 	lower(t2.eb_category) = 'fragrance'
group by 
        p1.sephora_user_id,
        p1.sephora_card_no,
        case when t.card_type=0 then 'PINK'
            when t.card_type=1 then 'WHITE'
            when t.card_type=2 then 'BLACK'
            when t.card_type=3 then 'GOLD'
        end
;
end
GO
