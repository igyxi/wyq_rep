/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_PDP_7D_PV]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_PDP_7D_PV] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.RPT_Sensor_PDP_7D_PV where dt = @dt;
insert into DW_Sensor.RPT_Sensor_PDP_7D_PV
--2021-12-31之前逻辑
-- select 
--     op_code,
--     count(1) as pv,
--     current_timestamp as insert_timestamp,
--     @dt as dt
-- from 
--     STG_Sensor.Events with (nolock)
-- where 
-- --dt='2020-01-14'
--     dt between dateadd(day,-6,@dt) and @dt
--     and event='viewCommodityDetail'
--     and op_code <> '0'
-- 	and PATINDEX('%[^0-9]%',op_code) = 0
-- group by 
--     op_code
--2021-12-31 修改
select
    product_id as op_code,
    count(1) as pv,
    current_timestamp as insert_timestamp,
     @dt as dt
from
    DW_Sensor.DWS_Product_Detail_Page_View
where
    dt between dateadd(day,-6,@dt) and @dt
and 
    product_id > 0
group by 
    product_id
;
end
GO
