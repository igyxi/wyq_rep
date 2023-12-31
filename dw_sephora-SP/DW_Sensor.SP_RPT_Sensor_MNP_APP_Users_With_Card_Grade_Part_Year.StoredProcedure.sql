/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Users_With_Card_Grade_Part_Year]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Users_With_Card_Grade_Part_Year] AS
begin
--TRUNCATE table DW_Sensor.RPT_Sensor_MNP_APP_Users_With_Card_Grade_Part_Year;
-- app和MNP共有用户基础视图
with view_screen as 
(
    SELECT distinct
        a.user_id,
        a.date,
        coalesce(a.vip_card,b.vip_card) as card_no
    from
    (
        SELECT
            user_id,
            date,
            vip_card
        from
            STG_Sensor.Events with (nolock)
        -- where
        --     dt between '2020-01-01' and '2022-05-31'
        where 
            --dt between cast(cast(@dt as varchar(7))+'-01' as date) and @dt
            dt between cast(DATEADD(mm, DATEDIFF(mm,0,'2022-06-30')-5, 0) as date) and '2022-06-30'
           and event in('$pageview','$AppViewScreen')
           and lower(platform_type)='app'
           and user_id is not null
    )a
    inner join
    (
        SELECT
            user_id,
            date,
            vip_card
        from
            STG_Sensor.Events with (nolock)
        -- where
        --     dt between '2020-01-01' and '2022-05-31'
        where 
           --dt between cast(cast(@dt as varchar(7))+'-01' as date) and @dt
           dt between cast(DATEADD(mm, DATEDIFF(mm,0,'2022-06-30')-5, 0) as date) and '2022-06-30'
           and event in('$pageview','$MPViewScreen')
           and platform_type='MiniProgram'
           and user_id is not null
    )b 
    on a.user_id = b.user_id 
    --and year(a.date)=year(b.date) and month(a.date)=month(b.date)
),

--app和MNP共有用户基础表
mnp_app_user_part_year as 
(
    SELECT 
        distinct
        --cast(a.date as varchar(7)) as statics_month,
        CONCAT_WS('~',cast(DATEADD(mm, DATEDIFF(mm,0,'2022-06-30')-5, 0) as date),'2022-06-30') as part_year,
        a.user_id as cross_user_id, 
        coalesce(c.card_level,d.card_level,'Unknown') as card_grade,
        current_timestamp as insert_timestamp
        --a.date as dt
    from 
        view_screen a 
    left join
    (
        select distinct
            ss_user_id,
            user_id,
            dt
        from
            DW_Sensor.DWS_Sensor_User_Info with (nolock)
        -- where 
        --     dt = '2020-01-01'
        where 
            --dt between cast(cast(@dt as varchar(7))+'-01' as date) and @dt
            dt between cast(DATEADD(mm, DATEDIFF(mm,0,'2022-06-30')-5, 0) as date) and '2022-06-30'
    )b
    on a.user_id = b.ss_user_id and a.date = b.dt
    left join DW_User.DWS_User_Info c
    on b.user_id = c.user_id
    left join DW_User.DWS_User_Info d
    on a.card_no collate Chinese_PRC_CS_AI_WS = d.card_no
)

insert into DW_Sensor.RPT_Sensor_MNP_APP_Users_With_Card_Grade_Part_Year
    SELECT distinct
        part_year,
        count(distinct cross_user_id) as cross_buyers,
        card_grade,
        current_timestamp as insert_timestamp
        --dt as dt
    from 
    (
        SELECT
            part_year,
            cross_user_id,
            case 
                 when card_level = 1 then 'PINK'
                 when card_level = 2 then 'WHITE'
                 when card_level = 3 then 'BLACK'
                 when card_level = 4 then 'GOLD'
                 when card_level = 0 then 'Unknown'
            end as card_grade
            --dt
        FROM
        (
            SELECT
                part_year,
                cross_user_id,
                max(card_level) as card_level
                --dt
            from
            (
                SELECT
                    part_year,
                    cross_user_id,
                    card_grade,
                    case 
                        when card_grade = 'PINK' then 1
                        when card_grade = 'WHITE'  then 2
                        when card_grade = 'BLACK' then 3
                        when card_grade = 'GOLD' then 4
                        when card_grade = 'Unknown' then 0
                    end as card_level
                    --dt
                FROM
                    mnp_app_user_part_year
                --where 
                    --dt=@dt
            )a
            group by 
                part_year,
                cross_user_id
                --dt
        )b
    )c
    group by 
        part_year,
        card_grade
;
end

GO
