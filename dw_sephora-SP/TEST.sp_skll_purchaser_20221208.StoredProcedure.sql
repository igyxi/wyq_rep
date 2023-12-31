/****** Object:  StoredProcedure [TEST].[sp_skll_purchaser_20221208]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_skll_purchaser_20221208] AS 
begin
truncate table test.skll_purchaser_20221208;
insert into test.skll_purchaser_20221208
select 
t.sephora_user_id,
t.member_card as sephora_card_no,
case when t1.card_type=0 then 'PINK'
     when t1.card_type=1 then 'WHITE'
     when t1.card_type=2 then 'BLACK'
     when t1.card_type=3 then 'GOLD'
end as card_level,
CURRENT_TIMESTAMP as insert_timestamp
from 
(
select
member_card,
sephora_user_id,
--max(case when ro=1 then member_card_grade end) as member_card_grade,
count(1) as cnts
from 
(
select   member_card
        ,sephora_user_id
        ,member_card_grade
        --,row_number() over(partition by member_card,sephora_user_id order by payment_time desc) as ro
from    [DW_OMS].[RPT_Sales_Order_SKU_Level]
where   format(payment_time,'yyyy-MM-dd')>=convert(date,dateadd(dd,-240,getdate())) --半年人群数据只有3.7W，时间放宽到8个月
and     member_card <> ''
and     member_card is not null
and     sephora_user_id <> ''
and     sephora_user_id is not null
and     item_brand_name='SKII' 
) t 
group by member_card,
        sephora_user_id
) t 
left join 
dwd.dim_member_info t1 
on t.member_card=t1.member_card
;
end
GO
