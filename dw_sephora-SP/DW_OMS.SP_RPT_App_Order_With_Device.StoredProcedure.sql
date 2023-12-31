/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_App_Order_With_Device]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_App_Order_With_Device] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-01-26       tali           add collate
-- 2023-03-07       wangzhichun    update source table
-- 2023-03-21       tali           change the device id logic
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
    case when b.ss_device_id is not null and b.ss_lib = 'iOS'  then b.ss_device_id else c.idfa end as idfa,
    case when b.ss_device_id is not null and b.ss_lib = 'Android'  then b.ss_device_id else c.androidId end as android_id,
    c.oaid,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
( 
    select 
        sales_order_number,
        order_type as type_cd,
        sub_channel_code as channel_cd,
        is_placed as is_placed_flag,
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
        [RPT].[RPT_Sales_Order_Basic_Level]
    where 
        sub_channel_code in ('APP(IOS)','APP(ANDROID)','APP') 
    and cast(order_time as date) = @dt 
) a 
left join 
(
    select orderid, user_id, ss_device_id, ss_lib, row_number()over(partition by orderid order by [time] desc) rownum from [STG_Sensor].[Events] where dt = @dt and event = 'submitOrder' and platform_type = 'app'
) b 
on a.sales_order_number = b.orderid collate SQL_Latin1_General_CP1_CI_AS
and b.rownum = 1
left join
(
    select id, oaid, androidId, idfa from [STG_Sensor].[Users]
) c
on b.user_id = c.id
END 


GO
