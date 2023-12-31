/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Sensor_Order_Latest_UTM_Attribution]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Sensor_Order_Latest_UTM_Attribution] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-30      zeyuan           Initial Version
-- 2023-03-31      wangzhichun      update
-- ========================================================================================
delete from DW_Sensor.DWS_Sensor_Order_Latest_UTM_Attribution where dt = @dt;
with sales_order as 
(
    select 
        sales_order_number,
        max(sephora_user_id) as sephora_user_id,
        max(case when channel_code = 'SOA' then 'S001' else channel_code end) as store_cd,
        max(case when sub_channel_code='TMALL006' then 'TMALL_WEI'
            when sub_channel_code='TMALL004' then 'TMALL_CHALING'
            when sub_channel_code='TMALL005' then 'TMALL_PTR'
            when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
            when sub_channel_code='DOUYIN001' then 'DOUYIN'
            when sub_channel_code='REDBOOK001' then 'REDBOOK'
            when sub_channel_code='JD003' then 'JD_FCS'
            when sub_channel_code in ('JD001','JD002') then 'JD'
            when sub_channel_code='GWP001' then 'OFF_LINE'
            else sub_channel_code 
            end) as channel_cd,
        max(order_type) as type_cd,
        -- max(basic_status_code) as basic_status_cd,   --源表缺少该字段
        max(order_status) as internal_status_cd,
        max(place_date) as place_date,
        max(place_time) as place_time,
        max(member_card) as member_card,
        max(order_date) as order_date,
        max(order_time) as order_time,
        max(payment_status) as payment_status_cd,
        max(payed_amount) as payed_amount,
        max(payment_time) as payment_time,
        max(payment_date) as payment_date,
        max(member_new_status) as member_new_status,
        max(is_placed) as is_placed_flag,
        sum(item_apportion_amount) as apportion_amount
    from
        RPT.RPT_Sales_Order_VB_Level
    where 
       sub_channel_code in ('MINIPROGRAM','PC','MOBILE','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT')
    and order_date = @dt 
    and 
        is_placed = 1
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
    null as basic_status_cd,
    a.internal_status_cd,
    a.place_date,
    a.member_card,
    a.order_date,
    a.payed_amount,
    a.payment_status_cd,
    a.apportion_amount,
    a.payment_time,
    a.payment_date,
    coalesce(a.member_new_status,'NO DETAIL') as member_status,
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
on b.orderid collate SQL_Latin1_General_CP1_CI_AS = a.sales_order_number
and b.rownum = 1
END

GO
