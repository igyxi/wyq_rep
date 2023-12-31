/****** Object:  StoredProcedure [DWD].[SP_Fact_Online_Event_Statistics]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Online_Event_Statistics] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-22       tali           Initial Version
-- ========================================================================================
delete from DWD.Fact_Online_Event_Statistics where dt = @dt;
insert into DWD.Fact_Online_Event_Statistics
select 
    date as statistic_date, 
    vip_card as member_card,
    count(1) as times,
    min(time) as start_time,
    max(time) as last_time,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
    STG_Sensor.Events
where
    dt = @dt
    and vip_card is not null
group by 
    date,
    vip_card   
END

GO
