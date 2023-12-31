/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Sensor_Offline_Buyer_OMNI_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Sensor_Offline_Buyer_OMNI_Detail] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-27       mac             delete 'COLLATE Chinese_PRC_CS_AI_WS'
-- ========================================================================================

delete from DW_Sensor.DWS_Sensor_Offline_Buyer_OMNI_Detail where dt = @dt;
insert into DW_Sensor.DWS_Sensor_Offline_Buyer_OMNI_Detail 
SELECT
    a.account_number as card_no,
    a.card_type_name as card_type,
    a.trans_id,
    a.trans_time,
    b.platform_type,
    b.view_time,
    a.sales,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select distinct
        a.trans_id,
        a.trans_time,
        cast(a.trans_time as date) as trans_date,
        b.account_number,
        c.card_type_name,
        sum(a.sales) over (partition by a.trans_id) as sales
    from 
        ODS_CRM.FactTrans a 
    left JOIN
        ODS_CRM.DimAccount b 
    on 
        a.account_id = b.account_id
    left join
        ODS_CRM.knCard_Type c
    on 
        b.card_type = c.card_type_id
    WHERE
        cast(a.trans_time as date) = @dt
    and 
        (a.valid_flag = 1 or a.valid_flag is null)
)a
join
(
    select
        vip_card,
        platform_type,
        time as view_time
    from
        Stg_Sensor.Events
    where
        dt between dateadd(day,-29,@dt) and @dt
    and 
        event in('$pageview','$MPViewScreen')
    and 
        vip_card is not null
)b 
on a.account_number  = b.vip_card
where 
    a.trans_time >= b.view_time;
END

GO
