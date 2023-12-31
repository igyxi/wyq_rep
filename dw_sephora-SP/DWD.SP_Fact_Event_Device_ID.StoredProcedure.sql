/****** Object:  StoredProcedure [DWD].[SP_Fact_Event_Device_ID]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Event_Device_ID] @dt [varchar](10) AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-18       Tali           Initial Version
-- ========================================================================================
truncate table [DWD].[Fact_Event_Device_ID];
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
    @dt
from 
    STG_Sensor.Events
where
    dt = @dt
group by 
    distinct_id,
    ss_device_id,
    platform_type,
    vip_card
end



select * from [DWD].[Fact_Event_Device_ID] where dt = '2022-02-17'
GO
