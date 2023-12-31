/****** Object:  StoredProcedure [TEST].[SP_DWS_Sensor_CRM_Page_Last_View_Detail]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_DWS_Sensor_CRM_Page_Last_View_Detail] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.DWS_Sensor_CRM_Page_Last_View_Detail where dt = @dt;
insert into DW_Sensor.DWS_Sensor_CRM_Page_Last_View_Detail 
SELECT
    card_no,
    card_type,
    trans_id,
    trans_time,
    platform_type as last_view_platform_type,
    view_time as last_view_time,
    sales,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    SELECT
        card_no,
        card_type,
        trans_id,
        trans_time,
        platform_type,
        view_time,
        sales,
        row_number() over (partition by trans_id order by view_time desc) as rnk
    from
        DW_Sensor.DWS_Sensor_CRM_Page_View_Detail
    where
        dt = @dt
)a 
where rnk=1;
END
GO
