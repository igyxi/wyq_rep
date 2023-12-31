/****** Object:  StoredProcedure [TEST].[SP_User_Group_Search_Dior]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_User_Group_Search_Dior] AS 
BEGIN
truncate table [DA_Tagging].[user_group_search_dior];
with v_events_search_value_temp as (
    select user_id,dt,time, tt.query as query,t2.name as standard_query , t2.[type]
    from(
        select user_id,dt,time ,value as query
        from STG_Sensor.V_Events
        CROSS APPLY  String_Split(banner_content, N'|')     -- 对banner_content进行分列处理
        where banner_belong_area = 'searchview'
        and event in ('clickBanner_App_Mob','clickBanner_MP','clickBanner_web')  -- 对platform_type,event做相应限制
        and dt between convert(date,dateadd(hour,8,getdate()) - 180) and convert(date,dateadd(hour,8,getdate()) - 1) -- 时间限制：近180天
    )tt 
    left join DA_Tagging.coding_synonyms_match t2 on tt.query = t2.Synoyms collate Chinese_PRC_CS_AI_WS
)

insert into [DA_Tagging].[user_group_search_dior](master_id,sephora_user_id,sephora_card_no,sensor_id)
select t2.master_id,t2.sephora_user_id,t2.sephora_card_no,t1.sensor_id
from(
    select distinct user_id as sensor_id
    from(
        select user_id,standard_query,rn
        from(
            select user_id,standard_query
            ,row_number() over (partition by user_id order by query_cnt desc) rn 
            from(
                select user_id,standard_query, count(0) as query_cnt
                from v_events_search_value_temp
                where standard_query is not null 
                and type='Brand' -- 搜索词种类限制为品牌词 
                group by user_id,standard_query
                )t1 
            )tt1 
    )t1 where rn = 1 and standard_query = N'迪奥'
)t1 left join (
    select * 
    from DA_Tagging.id_mapping
    where invalid_date='9999-12-31'
    ) t2 on t1.sensor_id = t2.sensor_id
;
END
GO
