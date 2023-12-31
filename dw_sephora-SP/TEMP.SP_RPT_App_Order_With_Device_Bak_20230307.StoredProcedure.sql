/****** Object:  StoredProcedure [TEMP].[SP_RPT_App_Order_With_Device_Bak_20230307]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_App_Order_With_Device_Bak_20230307] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-01-26       tali           add collate
-- ========================================================================================
delete from [DW_OMS].[RPT_App_Order_With_Device] where dt = @dt;
insert into [DW_OMS].[RPT_App_Order_With_Device]
select 
    a.sales_order_number,
    a.type_cd,
    a.channel_cd,
    a.is_placed_flag,
    a.place_time,
    a.place_date,
    a.order_time,
    a.order_date,
    a.payed_amount,
    a.member_id as user_id,
    a.member_new_status,
    a.member_daily_new_status,
    a.member_monthly_new_status,
    c.idfa,
    c.android_id,
    c.oaid,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
( 
    select 
        sales_order_number,
        type_cd,
        channel_cd,
        is_placed_flag,
        place_time,
        place_date,
        order_time,
        order_date,
        payed_amount,
        member_id,
        member_new_status,
        member_daily_new_status,
        member_monthly_new_status
    from 
        [DW_OMS].[RPT_Sales_Order_Basic_Level]
    where 
        channel_cd in ('APP(IOS)','APP(ANDROID)','APP') 
    and cast(order_time as date) = @dt 
) a 
left join 
(
    select distinct orderid,user_id from [STG_Sensor].[Events] where dt = @dt and event = 'submitOrder' and platform_type = 'app'
) b 
on a.sales_order_number = b.orderid collate SQL_Latin1_General_CP1_CI_AS
left join 
(
    select ss_user_id, max(idfa) as idfa, max(android_id) android_id,max(oaid) oaid from [DW_Sensor].[DWS_Sensor_User_Info] where dt = @dt group by ss_user_id
) c
on b.user_id = c.ss_user_id;
END 

GO
