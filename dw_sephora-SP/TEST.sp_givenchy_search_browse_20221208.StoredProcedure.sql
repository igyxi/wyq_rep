/****** Object:  StoredProcedure [TEST].[sp_givenchy_search_browse_20221208]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_givenchy_search_browse_20221208] AS 
begin

--浏览过Givenchy的用户
delete from test.givenchy_search_browse_20221208 where view_type='browse';

insert into test.givenchy_search_browse_20221208
select  
       p1.sephora_user_id,
       p1.sephora_card_no,
       case when t.card_type=0 then 'PINK'
           when t.card_type=1 then 'WHITE'
           when t.card_type=2 then 'BLACK'
           when t.card_type=3 then 'GOLD'
       end as card_level,
       'browse' as view_type,
       CURRENT_TIMESTAMP as insert_timestamp
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
            and     date>convert(date,dateadd(dd,-90,getdate())) --时间限制：半年人数太多，90天限制
            and     op_code is not null
            group   by user_id,op_code
        ) p
        inner join
        (
            select distinct eb_product_id as product_id,
                        eb_category 
               from DWD.DIM_SKU_Info
            where lower(eb_brand_name) = 'givenchy' and eb_category='MAKE UP'
        ) t
        on  p.product_id = t.product_id
        group by p.user_id,t.eb_category
    )   t1
) t2
left join
(
    select  sensor_id
            ,sephora_user_id
            ,sephora_card_no
    from    DA_Tagging.id_mapping
    where   invalid_date='9999-12-31'
     and sephora_card_no is not null
) p1
on  cast(t2.user_id as nvarchar) = p1.sensor_id    -- 为了取丝芙兰user_id
left join 
   dwd.dim_member_info t
on      
    p1.sephora_card_no = t.member_card COLLATE Chinese_PRC_CS_AI_WS 
group by 
        p1.sephora_user_id,
        p1.sephora_card_no,
        case when t.card_type=0 then 'PINK'
            when t.card_type=1 then 'WHITE'
            when t.card_type=2 then 'BLACK'
            when t.card_type=3 then 'GOLD'
        end
;

--搜索过Givenchy的用户

delete from test.givenchy_search_browse_20221208 where view_type='search';

insert  into test.givenchy_search_browse_20221208
select
        t4.sephora_user_id
        ,t4.sephora_card_no
        ,case when t.card_type=0 then 'PINK'
            when t.card_type=1 then 'WHITE'
            when t.card_type=2 then 'BLACK'
            when t.card_type=3 then 'GOLD'
        end as card_level
       ,'search' as view_type
       ,CURRENT_TIMESTAMP as insert_timestamp
 
from
(
    select  
           distinct
            t1.user_id,
            t1.search_content,           -- banner_content 拆分出来的名称
            t2.name as category_name,              -- coding_synonyms_match 中的名称
            t2.[type]
    from
    (
        select user_id,
               value as search_content
        from   stg_sensor.v_events
        cross  apply string_split(banner_content, N'|')     -- 对banner_content进行分列处理 value
        where  banner_belong_area = 'searchview'
        and    event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  -- 对platform_type,event做相应限制
        and    date>convert(date,dateadd(dd,-90,getdate()))--时间限制：半年人数太多，90天限制
    ) t1
    inner join 
    (select distinct synoyms,type,name from da_tagging.coding_synonyms_match where name= N'纪梵希') t2
    on t1.search_content = t2.synoyms collate chinese_prc_cs_ai_ws
) t3

left join
(
    select     
            sensor_id
            ,master_id
            ,sephora_user_id
            ,sephora_card_no
    from     
        da_tagging.id_mapping
    where   invalid_date='9999-12-31'
    and sephora_card_no is not null
) t4
on  t3.user_id = t4.sensor_id

left join 
    dwd.dim_member_info t
on      
    t4.sephora_card_no = t.member_card COLLATE Chinese_PRC_CS_AI_WS

group by 
    t4.sephora_user_id,
    t4.sephora_card_no,
    case when t.card_type=0 then 'PINK'
        when t.card_type=1 then 'WHITE'
        when t.card_type=2 then 'BLACK'
        when t.card_type=3 then 'GOLD'
    end
;

--结果数据
delete from test.givenchy_search_browse_20221208 where view_type='all';

insert into test.givenchy_search_browse_20221208
select 
sephora_user_id,
sephora_card_no,
card_level,
'all' as view_type,
CURRENT_TIMESTAMP as insert_timestamp
from 
test.givenchy_search_browse_20221208
where sephora_card_no is not null
and card_level is not null
and card_level<>'PINK'
and view_type in ('search','browse')
group by sephora_user_id,sephora_card_no,card_level;

END  
GO
