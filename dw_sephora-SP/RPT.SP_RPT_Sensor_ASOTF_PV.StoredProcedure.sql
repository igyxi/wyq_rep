/****** Object:  StoredProcedure [RPT].[SP_RPT_Sensor_ASOTF_PV]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sensor_ASOTF_PV] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-04       weichen		  Initial Version
-- 2023-05-12		weichen		  add touchpoint_en
-- 2023-05-17       Joey          add touchpoint_subcategory and change touchpoint_name
-- ========================================================================================
delete from RPT.RPT_Sensor_ASOTF_PV where dt = @dt
insert into RPT.RPT_Sensor_ASOTF_PV
select
    [date] as [Date],
	store_code as store_code,
	case 
	when touchpoint_name like N'%智能推介%' THEN N'智能推介'
	when touchpoint_name like N'%智美探店%' THEN N'智美探店'
	when touchpoint_name like N'%美力玩妆%' THEN N'美力玩妆'
	ELSE NULL
	end as touchpoint,
	case 
	when touchpoint_name like N'%智能推介%' THEN 'Lift and Learn'
	when touchpoint_name like N'%智美探店%' THEN 'Enhanced Navigation'
	when touchpoint_name like N'%美力玩妆%' THEN 'Makeup Fun Trial'
	ELSE NULL
	end as touchpoint_en,
    case
    when touchpoint_name like N'%PDP Navigation%' THEN 'PDP Navigation'
    when touchpoint_name like N'%Store Navigation%' THEN 'Store Navigation'
    ELSE NULL
    end as touchpoint_subcategory,
	sensor_user_id,
    sku_code as eb_sku_code,
	case when len(isnull(b.member_card, a.member_card)) < 15 then isnull(b.member_card, a.member_card) else '' end as member_card,
	a.member_card_grade as member_card_grade,
    SUM(case when [page_id] = 'APP_1000006' then 0 else 1 end) as pv,
    current_timestamp as insert_timestamp,
	@dt as dt
from
    DWD.Fact_ASOTF_Event a
    LEFT JOIN DWD.DIM_Member_Info b
    ON a.member_card = cast(b.eb_user_id as nvarchar)
where dt = @dt
AND (
(touchpoint_name like N'%Care Table%' AND [event] = 'EnterPDP' AND [page_id] = 'PDP_10000003')
OR
(touchpoint_name like N'%Store Navigation%' AND [event] = 'EnterStorePortal' AND [action_id] = '30000001_000')
OR
(touchpoint_name like N'%PDP Navigation%' AND [event] = 'EnterPDP' AND [page_id] = 'EN_PDP_20000001')
OR
(touchpoint_name like N'%Play Table%' AND [page_id] = 'APP_1000001' AND [action_id] IN ('APP_1000001_102' , 'APP_1000001_103'))
OR
(touchpoint_name like N'%Play Table%' AND [page_id] = 'APP_1000006' AND [action_id] IN ('APP_1000006_301'))
)
group by 
	[date],
	store_code,
	case 
	when touchpoint_name like N'%智能推介%' THEN N'智能推介'
	when touchpoint_name like N'%智美探店%' THEN N'智美探店'
	when touchpoint_name like N'%美力玩妆%' THEN N'美力玩妆'
	ELSE NULL
	end ,
	case 
	when touchpoint_name like N'%智能推介%' THEN 'Lift and Learn'
	when touchpoint_name like N'%智美探店%' THEN 'Enhanced Navigation'
	when touchpoint_name like N'%美力玩妆%' THEN 'Makeup Fun Trial'
	ELSE NULL
	end,
    case
    when touchpoint_name like N'%PDP Navigation%' THEN 'PDP Navigation'
    when touchpoint_name like N'%Store Navigation%' THEN 'Store Navigation'
    ELSE NULL
    end,
	sensor_user_id,
	sku_code,
	case when len(isnull(b.member_card, a.member_card)) < 15 then isnull(b.member_card, a.member_card) else '' end,
	member_card_grade
;
end


GO
