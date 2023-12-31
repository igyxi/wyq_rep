/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_SmartBA_PV_UV_Daily]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_SmartBA_PV_UV_Daily] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.RPT_SmartBA_PV_UV_Daily where dt = @dt;
insert into DW_Sensor.RPT_SmartBA_PV_UV_Daily
SELECT 
    count(1) as pv,
    count(distinct user_id) as uv,
    current_timestamp as insert_timestamp,
    dt
from 
    STG_Sensor.Events 
where 
    event = '$MPViewScreen'
    and CHARINDEX('ba=',ss_url_query) > 0
    and dt = @dt
group by 
    dt        
;
end
GO
