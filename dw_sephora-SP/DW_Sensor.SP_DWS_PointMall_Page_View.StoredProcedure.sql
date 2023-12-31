/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_PointMall_Page_View]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_PointMall_Page_View] @dt [VARCHAR](10) AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-17       Tali           Initial Version
-- ========================================================================================
delete from DW_Sensor.DWS_PointMall_Page_View where dt = @dt;
insert into DW_Sensor.DWS_PointMall_Page_View
select 
    *,
    CURRENT_TIMESTAMP,
    @dt
from(
    ---page view
    select 
        [event],
        user_id,
        [date],
        [time],
        button_name,
        page_type_detail,
        current_url,
        vip_card,
        vip_card_type,
        platform_type
    from 
        [STG_Sensor].[Events]
    where 
        dt = @dt
    and event='$pageview' 
    and page_type_detail='rewardsBoutique'
    union all
    --click
    select 
        [event],
        user_id,
        [date],
        [time],
        button_name,
        page_type_detail,
        current_url,
        vip_card,
        vip_card_type,
        platform_type
    from 
        [STG_Sensor].[Events]
    where 
        dt = @dt
    and event in ('pointMall_hp_click','pointMall_rewardspoint_click','pointMall_detail_click','pointMall_charity_click')
)t
END

GO
