/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Sensor_God_Policy_Clock]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Sensor_God_Policy_Clock] AS
BEGIN
truncate table DW_Sensor.DWS_Sensor_God_Policy_Clock ;
insert into DW_Sensor.DWS_Sensor_God_Policy_Clock
--创建码表
select distinct 
    page_id,
    action_id,
    banner_belong_area,
    banner_current_page_type,
    current_timestamp as insert_timestamp,
    dt 
from STG_Sensor.Events
where date >= '2022-01-01'
and page_id = 'APP_1000001'
and platform_type in ('app','App')
;
End
GO
