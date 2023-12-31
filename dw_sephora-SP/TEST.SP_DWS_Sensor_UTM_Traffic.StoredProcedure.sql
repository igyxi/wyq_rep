/****** Object:  StoredProcedure [TEST].[SP_DWS_Sensor_UTM_Traffic]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_DWS_Sensor_UTM_Traffic] @dt [VARCHAR](10) AS
BEGIN
delete from TEST.DWS_Sensor_UTM_Traffic where dt = @dt
insert into TEST.DWS_Sensor_UTM_Traffic
SELECT
    a.statics_date,
    a.platform_type,
    a.ss_utm_source,
    a.ss_utm_medium,
	a.ss_utm_content,
    a.uv,
    a.pv,
    b.pdp_uv,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        statics_date,
        platform_type,
        ss_utm_source,
        ss_utm_medium,
		ss_utm_content,
        count(distinct user_id) as uv,
        count(1) as pv,
        @dt as dt
    from
    (
        select
            @dt as statics_date,
            user_id,
            event,
            case when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
                 when platform_type in ('mobile') then 'mobile'
                 when platform_type in ('web') then 'web'
            end as platform_type,
            coalesce(ss_utm_source,'isnull') as ss_utm_source,
            coalesce(ss_utm_medium,'isnull') as ss_utm_medium,
			coalesce(ss_utm_content,'isnull') as ss_utm_content,
            dt,
            current_timestamp as insert_timestamp
        from
            STG_Sensor.Events with (nolock)
        where
            dt = @dt
        and 
            ((event in('$pageview') and platform_type in('mobile','web'))
        or (event in('$MPViewScreen') and platform_type in('MiniProgram','Mini Program')))
    )t
    group by 
        statics_date,
        platform_type,
        ss_utm_source,
        ss_utm_medium,
		ss_utm_content
)a
left join
(
    select
        statics_date,
        platform_type,
        ss_utm_source,
        ss_utm_medium,
		ss_utm_content,
        count(distinct user_id) as pdp_uv
    from
    (
        select 
            @dt as statics_date,
            user_id,
            case when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
                 when platform_type in ('mobile') then 'mobile'
                 when platform_type in ('web') then 'web'
            end as platform_type,
            coalesce(ss_utm_source,'isnull') as ss_utm_source,
            coalesce(ss_utm_medium,'isnull') as ss_utm_medium,
			coalesce(ss_utm_content,'isnull') as ss_utm_content
        from 
            STG_Sensor.Events with (nolock)
        where 
        --dt='2020-01-14'
            dt=@dt
            and event='viewCommodityDetail'
            and platform_type in('mobile','web','MiniProgram','Mini Program')
    )t
    group by 
        statics_date,
        platform_type,
        ss_utm_source,
        ss_utm_medium,
		ss_utm_content
)b 
on 
    a.statics_date = b.statics_date
and
    a.platform_type = b.platform_type
and
    a.ss_utm_source = b.ss_utm_source
and
    a.ss_utm_medium = b.ss_utm_medium
and 
	a.ss_utm_content= b.ss_utm_content
END
GO
