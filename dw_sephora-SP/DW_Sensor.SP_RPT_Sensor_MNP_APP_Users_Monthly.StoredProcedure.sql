/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Users_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_MNP_APP_Users_Monthly] @dt [VARCHAR](10) AS
begin
--统计app和MNP共有用户人数总数
delete from DW_Sensor.RPT_Sensor_MNP_APP_Users_Monthly where dt = @dt;
insert into DW_Sensor.RPT_Sensor_MNP_APP_Users_Monthly
SELECT distinct
    statics_month,
    count(distinct cross_user_id) as cross_buyers,
    current_timestamp as insert_timestamp,
    @dt as dt
from DW_Sensor.RPT_Sensor_MNP_APP_User_Monthly
where dt=@dt
group by 
    statics_month
;
end 
GO
