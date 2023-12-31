/****** Object:  StoredProcedure [DWD].[SP_Fact_Online_Traffic]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Online_Traffic] @dt [varchar](10) AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-05       Tali           Initial Version
-- ========================================================================================
delete from [DWD].[Fact_Online_Traffic] where statistic_date = @dt;
insert into [DWD].[Fact_Online_Traffic]
select 
    date as statistic_date, 
    count(1) as pv, 
    count(distinct user_id) as uv, 
    'Sensor' as Source,
    CURRENT_TIMESTAMP
from 
    stg_sensor.events
where 
    dt = @dt
group by date;
END
GO
