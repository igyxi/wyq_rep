/****** Object:  StoredProcedure [DATA_OPS].[SP_DWS_Sensor_Order_UTM_Attribution]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_DWS_Sensor_Order_UTM_Attribution] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       eddie.zhang    Initial Version
-- 2023-03-31       wangzhichun    change source
-- ========================================================================================
delete from DATA_OPS.DWS_Sensor_Order_UTM_Attribution where dt = @dt;
with sales_order as 
(
    select 
        sales_order_number,
        max(sephora_user_id) as sephora_user_id,
        max(case when channel_code='SOA' THEN 'S001' ELSE sub_channel_code  end) as store_cd,
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
        [RPT].[RPT_Sales_Order_VB_Level]
    where 
        sub_channel_code in ('MINIPROGRAM','PC','MOBILE','ANNYMINIPROGRAM','BENEFITMINIPROGRAM','WECHAT')
    and 
        format(order_time,'yyyy-MM-dd') = @dt
    and 
        is_placed = 1
    group by 
        sales_order_number
)

insert into DATA_OPS.DWS_Sensor_Order_UTM_Attribution
select
    sales_order_number,
    sephora_user_id,
    store_cd,
    case when channel_cd in ('BENEFITMINIPROGRAM','MINIPROGRAM','ANNYMINIPROGRAM') then 'MiniProgram'
         when channel_cd in ('MOBILE','WECHAT') then 'mobile'
         when channel_cd in ('PC') then 'web'
    else 'NO DETAIL' end as channel_cd,    
    type_cd,
    null as basic_status_cd,
    internal_status_cd,
    place_date,
    place_time,
    member_card,
    order_date,
    order_time,
    payed_amount,
    payment_status_cd,
    apportion_amount,
    payment_time,
    payment_date,
	member_new_status,
    is_placed_flag,
    event_name,
    event_time,
    platform_type,
	coalesce(attribution_type,'NO DETAIL') as attribution_type,
    coalesce(ss_utm_source,'NO DETAIL') as ss_utm_source,
    coalesce(ss_utm_medium,'NO DETAIL') as ss_utm_medium,
    current_timestamp as insert_timestamp,
    @dt as dt
from
(
    select
        t1.*,
        t2.event_time,
        t2.platform_type,
        t2.event_name,
        case when datediff(day,t2.event_date,t1.order_date) between 0 and 1 then '1D'
             when datediff(day,t2.event_date,t1.order_date) between 2 and 7 then '7D'
             when datediff(day,t2.event_date,t1.order_date) between 8 and 14 then '14D'
			 when datediff(day,t2.event_date,t1.order_date) between 15 and 15 then '15D'
             when datediff(day,t2.event_date,t1.order_date) between 16 and 30  then '30D'
			 when datediff(day,t2.event_date,t1.order_date) between 31 and 90  then '90D'
             else null 
        end as attribution_type,
        t2.ss_utm_source,
        t2.ss_utm_medium,
        row_number() over (partition by t1.sales_order_number order by t2.event_time desc) as rownum
    from
        sales_order t1
    left join
    (
        select
            b.user_id as sephora_user_id,
            a.event_name,
            a.platform_type,
            a.ss_utm_source,
            a.ss_utm_medium,
            a.time as event_time,
            cast(a.time as date) as event_date
        from
        (
            select
                user_id,
                event as event_name,
                platform_type,
                coalesce(ss_utm_source,'isnull') as ss_utm_source,
                coalesce(ss_utm_medium,'isnull') as ss_utm_medium,
                dt,
                time
            from
                STG_Sensor.Events with (nolock)
            where
                dt between dateadd(day,-89,@dt) and @dt
            and event in('$pageview','$MPViewScreen')
            and platform_type in('MiniProgram','mobile','web')
            and (ss_utm_source is not null or ss_utm_medium is not null)
        )a
        inner join
        (
            select distinct
                ss_user_id,
                user_id,
                dt
            from
                DW_Sensor.DWS_Sensor_User_Info with (nolock)
            where 
                dt between dateadd(day,-89,@dt) and @dt
        )b
        on 
            a.user_id = b.ss_user_id
        and a.dt = b.dt
        where
            b.user_id is not null
    ) t2
    on
        t1.sephora_user_id = t2.sephora_user_id
    and t1.order_time >= t2.event_time
) t
where t.rownum = 1
;
END

GO
