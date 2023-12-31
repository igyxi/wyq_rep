/****** Object:  StoredProcedure [TEST].[sp_visit_lauder_page_20220808]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_visit_lauder_page_20220808] @days [int] AS
begin
delete from test.visit_lauder_page_20220808 where query_days = @days ;
delete from test.search_top_lauder where query_days = @days ;
delete from test.browse_top_lauder where query_days = @days ;
insert into test.search_top_lauder
select  t2.user_id
		,t2.search_cnt
		,@days as query_days
from
(
	select  t1.user_id
			,t1.search_cnt
			,row_number() over(partition by t1.user_id order by t1.search_cnt desc) as row_num
	from
	(
		select  p.user_id
				,sum(search_cnt) search_cnt
		from
		(
			select  user_id
					--,date
					,try_cast(trim(op_code) as bigint) product_id
					,count(1) as search_cnt
			from    STG_Sensor.Events
			where   banner_belong_area = 'searchview'
			and     event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')
			and     [date] between convert(date, dateadd(hour,8,getdate()) - @days) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
			and     op_code is not null
			group   by user_id,op_code
		) p
		inner   join
		(
			select eb_product_id as product_id from DWD.DIM_SKU_Info
			where lower(sap_brand_name) = 'lauder'
		) t
		on  p.product_id = t.product_id
		group by p.user_id
	)   t1
) t2
where t2.row_num = 1
;
-- 半年/1年内浏览次数最多为lauder
insert into test.browse_top_lauder
select  t2.user_id
		,t2.browse_cnt
		,@days as query_days
from
(
	select  t1.user_id
			,t1.browse_cnt
			,row_number() over(partition by t1.user_id order by t1.browse_cnt desc) as row_num
	from
	(
		select  p.user_id
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
		inner   join
		(
			select eb_product_id as product_id from DWD.DIM_SKU_Info
			where lower(sap_brand_name) = 'lauder'
		) t
		on  p.product_id = t.product_id
		group by p.user_id
	)   t1
) t2
where t2.row_num = 1
;

-- 1年内购买过一次 lauder的非粉卡消费者, 这部分数据已经写入了，不用分180天和365天都去执行存储过程了
--insert into test.buy_one_count
--select  member_card
--        ,sephora_user_id
--        ,count(1) as cnt
--        --,365 as query_days
--from    [DW_OMS].[RPT_Sales_Order_SKU_Level]
--where   item_brand_name_cn = N'雅诗兰黛'
--and     [payment_time] between convert(date, dateadd(hour,8,getdate()) - 365) and convert(date,dateadd(hour,8,getdate()) - 1)
----and     member_card_grade <> 'PINK'
--and     member_card <> ''
--and     member_card is not null
--and     sephora_user_id <> ''
--and     sephora_user_id is not null
--group   by member_card, sephora_user_id
--having  count(1) >= 1 -- 等于1次的，只有12.4万人， >= 1时，24.2W
--;


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
                ,p.search_cnt
                ,p.browse_cnt
                ,0 buy_cnt
        from
        (
            select  p.user_id
                    ,p.search_cnt
                    ,t.browse_cnt
            from    test.search_top_lauder p
            inner 	join test.browse_top_lauder t
            on 		p.user_id = t.user_id
            and 	p.query_days = t.query_days
            where 	p.query_days = @days
            and		t.query_days = @days
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
        union   all
        select   sephora_user_id
                ,member_card  COLLATE Chinese_PRC_CS_AI_WS member_card
                ,0 as search_cnt
                ,0 as browse_cnt
                ,cnt as buy_cnt
        from    test.buy_one_count
    ) t
    group   by t.sephora_user_id,t.sephora_card_no
)


-- 结果数据
insert   into  test.visit_lauder_page_20220808
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
and     t.card_level <> 'PINK'
;
end
GO
