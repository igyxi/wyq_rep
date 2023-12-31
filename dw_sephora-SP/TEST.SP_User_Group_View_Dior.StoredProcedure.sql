/****** Object:  StoredProcedure [TEST].[SP_User_Group_View_Dior]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_User_Group_View_Dior] AS 
BEGIN
truncate table [DA_Tagging].[user_group_view_dior];

with prod_cnt_temp as (
    select user_id as sensor_id,brand,category,count(0) as cnt
    from [DW_Sephora].[DA_Tagging].v_events_session
    where (brand is not null or category is not null)
        and event = 'viewCommodityDetail'
        and dt between convert(date,DATEADD(hour,8,getdate()) - 180) and convert(date,DATEADD(hour,8,getdate()) - 1)
    group by user_id,brand,category
)

insert into [DA_Tagging].[user_group_view_dior](master_id,sephora_user_id,sephora_card_no,sensor_id)
select t2.master_id,t2.sephora_user_id,t2.sephora_card_no,t1.sensor_id
from(
    select sensor_id,brand as most_visited_brand
    from (
        select sensor_id,brand,row_number() over(partition by sensor_id order by cacnt desc) as ranking
        from (
            select sensor_id,brand,sum(cnt) as cacnt
            from prod_cnt_temp
            group by sensor_id,brand
            ) as t1
        ) as t2
    where ranking = 1
    and brand in ( N'Dior',N'DIOR')
)t1 left join (
    select * 
    from DA_Tagging.id_mapping
    where invalid_date='9999-12-31'
    ) t2 on t1.sensor_id = t2.sensor_id
;
END
GO
