/****** Object:  StoredProcedure [TEMP].[SP_DWS_Events_Session_Cutby30m_Bak_20220808]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Events_Session_Cutby30m_Bak_20220808] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.DWS_Events_Session_Cutby30m_Bak_20220808 where dt = @dt; -- 一定要注意修改表名
insert into DW_Sensor.DWS_Events_Session_Cutby30m_Bak_20220808                 -- 一定要注意修改表名
select
        *
from
    DW_Sensor.DWS_Events_Session_Cutby30m                                      -- 一定要注意修改表名
where dt = @dt
END
GO
