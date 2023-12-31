/****** Object:  StoredProcedure [TEST].[SP_DWS_Sensor_CRM_Page_View_Summary]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_DWS_Sensor_CRM_Page_View_Summary] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.DWS_Sensor_CRM_Page_View_Summary where dt = @dt;
insert into DW_Sensor.DWS_Sensor_CRM_Page_View_Summary 
SELECT
    cast(trans_time as date) as date,
    card_type,
    last_view_platform_type as platform_type,
    count(distinct card_no) as buyers,
    count(distinct trans_id) as orders,
    sum(sales) as sales,
    current_timestamp as insert_timestamp,
    @dt as dt
from
    DW_Sensor.DWS_Sensor_CRM_Page_Last_View_Detail
WHERE
    dt = @dt
group by 
    cast(trans_time as date),
    card_type,
    last_view_platform_type
END
GO
