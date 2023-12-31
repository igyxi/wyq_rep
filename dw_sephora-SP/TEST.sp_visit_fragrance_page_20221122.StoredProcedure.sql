/****** Object:  StoredProcedure [TEST].[sp_visit_fragrance_page_20221122]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_fragrance_page_20221122] @days [int] AS 
begin
delete from test.visit_fragrance_page_20221122 where query_days=@days;

----------------------最近两个月在Dragon上有过购买的用户
with tmp as
(
	select  member_card
	        ,sephora_user_id
	        ,count(1) as cnt
	        ,@days as query_days
	from    [DW_OMS].[RPT_Sales_Order_SKU_Level]
	where   store_cd='S001' 
	and     [payment_time] between convert(date, dateadd(hour,8,getdate()) - 60) and convert(date,dateadd(hour,8,getdate()) - 1)
	--and     member_card_grade <> 'PINK'
	and     member_card <> ''
	and     member_card is not null
	and     sephora_user_id <> ''
	and     sephora_user_id is not null
	group   by member_card, sephora_user_id
	having  count(1) >= 1
)


-------- 结果数据
insert into  test.visit_fragrance_page_20221122
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
	from 	test.search_top_fragrance_20221122
	where 	query_days = @days
	union
    select  sephora_user_id,
            sephora_card_no,
            card_level
	from 	test.browse_top_fragrance_20221122
	where 	query_days = @days
) p
left join 
	tmp t
on p.sephora_user_id=t.sephora_user_id and p.sephora_card_no=t.member_card
where   
	p.card_level in ('BLACK','GOLD','WHITE')
	and t.sephora_user_id is null 
	and t.member_card is null
;
END 
GO
