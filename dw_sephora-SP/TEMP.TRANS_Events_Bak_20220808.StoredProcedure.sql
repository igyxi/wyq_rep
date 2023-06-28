/****** Object:  StoredProcedure [TEMP].[TRANS_Events_Bak_20220808]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_Events_Bak_20220808] @dt [VARCHAR](10) AS
BEGIN
delete from STG_Sensor.Events_Bak_20220808 where dt = @dt;
insert into STG_Sensor.Events_Bak_20220808
select
        *
from
    STG_Sensor.Events
where dt = @dt
END
GO
