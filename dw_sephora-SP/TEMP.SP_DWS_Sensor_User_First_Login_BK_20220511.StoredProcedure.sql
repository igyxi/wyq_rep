/****** Object:  StoredProcedure [TEMP].[SP_DWS_Sensor_User_First_Login_BK_20220511]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Sensor_User_First_Login_BK_20220511] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.DWS_Sensor_User_First_Login where dt = @dt;
insert into DW_Sensor.DWS_Sensor_User_First_Login
SELECT
    a.user_id as user_id,
    a.card_no,
    a.platform_type,
    a.first_date,
    a.first_time,
    current_timestamp as insert_timestamp,
    @dt as dt
FROM
(
    select
        user_id,
        vip_card as card_no,
        case when lower(platform_type) ='miniprogram' then 'MiniProgram'
             when lower(platform_type) ='app' then 'APP'
        end as platform_type,
        min(date) as first_date,
        min(time) as first_time
    from
        STG_Sensor.Events with (nolock)
    where
        lower(platform_type) in('miniprogram','app')
    and 
        vip_card is not null
    and
        dt=@dt
    group by 
        user_id,
        vip_card,
        case when lower(platform_type) ='miniprogram' then 'MiniProgram'
             when lower(platform_type) ='app' then 'APP'
        end
)a
left join
(
    select
        ss_user_id,
        card_no,
        platform_type,
        first_date,
        first_time
    from
        [DW_Sensor].[DWS_Sensor_User_First_Login]
    where 
        dt = dateadd(day,-1,@dt) 
)b
on a.user_id = b.ss_user_id
and a.platform_type = b.platform_type
where b.ss_user_id is null
union all
select
    ss_user_id,
    card_no,
    platform_type,
    first_date,
    first_time,
    current_timestamp as insert_timestamp,
    @dt as dt
from
    [DW_Sensor].[DWS_Sensor_User_First_Login]
where 
    dt = dateadd(day,-1,@dt)
;
end
GO
