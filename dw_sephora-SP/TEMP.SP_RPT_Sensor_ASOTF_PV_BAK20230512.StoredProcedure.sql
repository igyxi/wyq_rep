/****** Object:  StoredProcedure [TEMP].[SP_RPT_Sensor_ASOTF_PV_BAK20230512]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Sensor_ASOTF_PV_BAK20230512] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-04       weichen		  Initial Version
-- ========================================================================================
delete from RPT.RPT_Sensor_ASOTF_PV where dt = @dt
insert into RPT.RPT_Sensor_ASOTF_PV
select
    [date] as [Date],
	store_code as store_code,
	touchpoint_name as touchpoint,
	sensor_user_id,
    sku_code as eb_sku_code,
	member_card as member_card,
	member_card_grade as member_card_grade,
    count(1) as pv,
    current_timestamp as insert_timestamp,
	@dt as dt
from
    DWD.Fact_ASOTF_Event 
where dt = @dt
group by 
	[date],
	store_code,
	touchpoint_name,
	sensor_user_id,
	sku_code,
	member_card,
	member_card_grade
;
end
GO
