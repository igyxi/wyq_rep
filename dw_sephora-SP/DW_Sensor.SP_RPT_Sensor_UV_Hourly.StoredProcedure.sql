/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_UV_Hourly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_UV_Hourly] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.RPT_Sensor_UV_Hourly where dt = @dt;
insert into DW_Sensor.RPT_Sensor_UV_Hourly
select
    date as statistic_date,
    DATENAME(HOUR, time) as statistic_hour,
    'Dragon' as store,
    case when platform_type in ('Mini Program','MiniProgram') then 'MiniProgram'
         when platform_type in ('app','APP') then 'APP'
    end as platform,
    count(distinct user_id) as uv,
    current_timestamp as insert_timestamp,
    @dt as dt
from
    STG_Sensor.Events with (nolock)
where
    dt = @dt
and 
    event in('$AppViewScreen','$MPViewScreen')
and
    platform_type in('Mini Program','MiniProgram','app','APP')
group by 
    date,
    DATENAME(HOUR, time),
    case when platform_type in ('Mini Program','MiniProgram') then 'MiniProgram'
         when platform_type in ('app','APP') then 'APP'
    end
union all
select
    date as statistic_date,
    DATENAME(HOUR, time) as statistic_hour,
    'Dragon' as store,
    case when platform_type in ('mobile') then 'Mobile'
         when platform_type in ('web') then 'WEB'
    end as platform,
    count(distinct user_id) as uv,
    current_timestamp as insert_timestamp,
    @dt as dt
from
    STG_Sensor.Events with (nolock)
where
    dt = @dt
and 
    event ='$pageview'
and
    platform_type in('mobile','web')
group by 
    date,
    DATENAME(HOUR, time),
    case when platform_type in ('mobile') then 'Mobile'
         when platform_type in ('web') then 'WEB'
    end
;
END
GO
