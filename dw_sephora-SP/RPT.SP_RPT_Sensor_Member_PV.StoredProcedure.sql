/****** Object:  StoredProcedure [RPT].[SP_RPT_Sensor_Member_PV]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sensor_Member_PV] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-01       wangzhichun    Initial Version
-- ========================================================================================
delete from RPT.RPT_Sensor_Member_PV where dt = @dt
insert into RPT.RPT_Sensor_Member_PV
select
    t.[date] as statistic_date,
    t.vip_card as member_card,
    s.sku_code as item_sku_code,
    t.platform_type,
    count(1) as pv,
    @dt as dt,
    current_timestamp as insert_timestamp
from
    [DW_Sensor].[DWS_Product_Detail_Page_View] t
left join
	DWD.DIM_SKU_Info s
on
    t.sku_id=s.eb_sku_id
where t.dt=@dt
and t.vip_card is not null 
group by 
	t.[date],
	t.vip_card,
	s.sku_code,
	t.platform_type
;
end
GO
