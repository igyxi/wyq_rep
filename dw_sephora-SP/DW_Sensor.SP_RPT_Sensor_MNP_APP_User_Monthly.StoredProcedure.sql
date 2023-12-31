/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_MNP_APP_User_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_MNP_APP_User_Monthly] @dt [VARCHAR](10) AS
begin
delete from DW_Sensor.RPT_Sensor_MNP_APP_User_Monthly where dt = @dt; --example: dt = '2021-11-30'
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
        --     dt between '2020-01-01' and '2021-05-31'
        where 
            dt between cast(cast(@dt as varchar(7))+'-01' as date) and @dt
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
        --     dt between '2020-01-01' and '2021-05-31'
        where 
           dt between cast(cast(@dt as varchar(7))+'-01' as date) and @dt
           and event in('$pageview','$MPViewScreen')
           and platform_type='MiniProgram'
           and user_id is not null
    )b 
    on a.user_id = b.user_id and year(a.date)=year(b.date) and month(a.date)=month(b.date)
)
--app和MNP共有用户基础表
insert into DW_Sensor.RPT_Sensor_MNP_APP_User_Monthly
SELECT distinct
    cast(a.date as varchar(7)) as statics_month,
    a.user_id,
    coalesce(c.card_level,d.card_level,'Unknown') as card_level,
    current_timestamp as insert_timestamp,
    @dt as dt
from view_screen a 
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
        dt between cast(cast(@dt as varchar(7))+'-01' as date) and @dt
)b
on a.user_id = b.ss_user_id and a.date = b.dt
left join DW_User.DWS_User_Info c
on b.user_id = c.user_id
left join DW_User.DWS_User_Info d
on a.card_no collate Chinese_PRC_CS_AI_WS = d.card_no
;
end 

GO
