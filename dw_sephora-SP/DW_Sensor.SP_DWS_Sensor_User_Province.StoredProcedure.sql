/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Sensor_User_Province]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Sensor_User_Province] @dt [VARCHAR](10) AS
begin
delete from [DW_Sensor].[DWS_Sensor_User_Province] where ss_user_id in (
    select 
        distinct user_id 
    from 
        [STG_Sensor].[Events] 
    where 
        dt = @dt 
    and (ss_province is not null or ss_city is not null)
);

insert into [DW_Sensor].[DWS_Sensor_User_Province] 
select 
    t.ss_user_id,
    t.ss_province,
    t.ss_city,
    t.sensor_time as ss_time,
    CURRENT_TIMESTAMP as insert_timestamp
from
(
    select 
        [user_id]as ss_user_id,
        [time] as sensor_time,
        ss_province,
        ss_city,
        row_number() over(partition by user_id order by [time] desc) as rownum
    from 
        [STG_Sensor].[Events]
    where 
        dt = @dt
    and (ss_province is not null or ss_city is not null)
) t
where t.rownum = 1
;
end

GO
