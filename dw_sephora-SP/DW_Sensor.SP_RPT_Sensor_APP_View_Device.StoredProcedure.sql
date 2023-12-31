/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_APP_View_Device]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_APP_View_Device] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.RPT_Sensor_APP_View_Device where dt = @dt;
insert into DW_Sensor.RPT_Sensor_APP_View_Device
select 
    device_id,
    ss_os,
    trigger_date,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        case
            when ss_os = 'iOS' and ((ISNUMERIC(ss_device_id) = 0 and len(ss_device_id) <= 10) or (len(ss_device_id) > 10)) then ss_device_id
            when ss_os = 'iOS' and (CHARINDEX('-',distinct_id) = 9 and CHARINDEX('-',distinct_id,10) = 14 and CHARINDEX('-',distinct_id,15) = 19 and CHARINDEX('-',distinct_id,20) = 24 and PATINDEX('%[^A-Z0-9-]%',distinct_id) = 0) then distinct_id
            when ss_os = 'Android' and len(lower(ss_device_id)) between 13 and 16 and PATINDEX('%[^a-f0-9]%',lower(ss_device_id)) = 0 then ss_device_id
            when ss_os = 'Android' and len(lower(distinct_id)) between 13 and 16 and PATINDEX('%[^a-f0-9]%',lower(distinct_id)) = 0 then distinct_id
            else null
        end as device_id,    
        ss_os,
        [date] as trigger_date
    from
        [STG_Sensor].[Events]
    where
        dt = @dt
        and event = '$AppViewScreen'
        and platform_type = 'app'
) t1 
where
    device_id is not null
group by
    device_id,
    ss_os,
    trigger_date;
END
GO
