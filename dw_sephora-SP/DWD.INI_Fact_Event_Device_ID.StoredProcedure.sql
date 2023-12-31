/****** Object:  StoredProcedure [DWD].[INI_Fact_Event_Device_ID]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[INI_Fact_Event_Device_ID] @month [varchar](10) AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-18       Tali           Initial Version
-- ========================================================================================
delete from [DWD].[Fact_Event_Device_ID] where substring(dt,1,7) = @month;
insert into [DWD].[Fact_Event_Device_ID]
select
    distinct_id,
    platform_type,
    ss_device_id,
    vip_card as member_card,
    min(time) as start_time,
    max(time) as last_time,
    'SHENCE' as source,
    CURRENT_TIMESTAMP as insert_timestamp,
    dt
from 
    STG_Sensor.Events
where
    substring(dt,1,7) = @month
group by 
    distinct_id,
    ss_device_id,
    platform_type,
    vip_card,
    dt
end
GO
