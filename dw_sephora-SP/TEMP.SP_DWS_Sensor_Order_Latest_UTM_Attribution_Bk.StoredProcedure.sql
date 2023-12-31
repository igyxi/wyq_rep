/****** Object:  StoredProcedure [TEMP].[SP_DWS_Sensor_Order_Latest_UTM_Attribution_Bk]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Sensor_Order_Latest_UTM_Attribution_Bk] @dt [VARCHAR](10) AS
BEGIN
delete from DW_Sensor.DWS_Sensor_Order_Latest_UTM_Attribution where dt = @dt;
with sales_order as 
(
    select 
        sales_order_number,
        max(sephora_user_id) as sephora_user_id,
        max(store_cd) as store_cd,
        max(channel_cd) as channel_cd,
        max(type_cd) as type_cd,
        max(basic_status_cd) as basic_status_cd,
        max(internal_status_cd) as internal_status_cd,
        max(place_date) as place_date,
        max(place_time) as place_time,
        max(member_card) as member_card,
        max(order_date) as order_date,
        max(order_time) as order_time,
        max(payment_status_cd) as payment_status_cd,
        max(payed_amount) as payed_amount,
        max(payment_time) as payment_time,
        max(payment_date) as payment_date,
        max(member_new_status) as member_new_status,
        max(is_placed_flag) as is_placed_flag,
        sum(item_apportion_amount) as apportion_amount
    from
        [DW_OMS].[RPT_Sales_Order_VB_Level]
    where 
        channel_cd in ('MINIPROGRAM','PC','MOBILE','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT')
    and 
        order_date = @dt
    and 
        is_placed_flag = 1
    group by 
        sales_order_number
)

insert into DW_Sensor.DWS_Sensor_Order_Latest_UTM_Attribution
select
    a.sales_order_number,
    a.sephora_user_id,
    a.store_cd,
    case when a.channel_cd in ('BENEFITMINIPROGRAM','MINIPROGRAM','ANNYMINIPROGRAM') then 'MiniProgram'
         when a.channel_cd in ('MOBILE','WECHAT') then 'mobile'
         when a.channel_cd in ('PC') then 'web'
    else 'NO DETAIL' end as channel_cd,
    a.type_cd,
    a.basic_status_cd,
    a.internal_status_cd,
    a.place_date,
    a.member_card,
    a.order_date,
    a.payed_amount,
    a.payment_status_cd,
    a.apportion_amount,
    a.payment_time,
    a.payment_date,
    coalesce(a.member_new_status,'NO DETAIL') as member_new_status,
    a.is_placed_flag,
    b.event as event_name,
	b.time as event_time,
    b.platform_type,
    'Sensor payment' as attribution_type,
    coalesce(b.ss_utm_source,'NO DETAIL') as ss_utm_source,
    coalesce(b.ss_utm_medium,'NO DETAIL') as ss_utm_medium,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
    sales_order a
left join
(
    select 
        platform_type,
        coalesce(ss_latest_utm_source,'isnull') as ss_utm_source,
        coalesce(ss_latest_utm_medium,'isnull') as ss_utm_medium,
        orderid,
        dt,
        event,
		time,
        row_number() over (partition by orderid order by time desc) as rownum
    from 
        STG_Sensor.Events with (nolock)
    where 
        dt = @dt
    and 
        event = 'submitOrder'
    and
        platform_type in('MiniProgram','mobile','web')
)b
on b.orderid = a.sales_order_number
and b.rownum = 1
END

GO
