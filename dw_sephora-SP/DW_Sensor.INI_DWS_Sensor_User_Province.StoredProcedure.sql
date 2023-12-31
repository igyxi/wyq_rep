/****** Object:  StoredProcedure [DW_Sensor].[INI_DWS_Sensor_User_Province]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[INI_DWS_Sensor_User_Province] AS 
BEGIN
truncate table [DW_Sensor].[DWS_Sensor_User_Province];
insert into [DW_Sensor].[DWS_Sensor_User_Province]
select
    ss_user_id,
    ss_province,
    ss_city,
    cast(substring(ss_time,1,19) as datetime),
    cast(substring(insert_timestamp,1,19) as datetime)
from 
    [DW_Sensor].[DWS_Sensor_User_Province_History]
where ss_user_id is not null;
end
GO
