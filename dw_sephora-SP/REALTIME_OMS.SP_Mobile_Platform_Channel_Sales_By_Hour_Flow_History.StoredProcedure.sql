/****** Object:  StoredProcedure [REALTIME_OMS].[SP_Mobile_Platform_Channel_Sales_By_Hour_Flow_History]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [REALTIME_OMS].[SP_Mobile_Platform_Channel_Sales_By_Hour_Flow_History] @dt [VARCHAR](10) AS
BEGIN

-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-09       daqian.ji      add smartba data
-- ========================================================================================

delete from REALTIME_OMS.Mobile_Platform_Channel_Sales_By_Hour_Flow_History where dt =@dt;
insert into REALTIME_OMS.Mobile_Platform_Channel_Sales_By_Hour_Flow_History
select
    'digital' as platform_name
    ,channel_id as channel_name
    ,hour_minute
    ,sum(payed_amount) over(partition by channel_id order by hour_minute  ROWS unbounded preceding) as metrics_value
    ,'sales' as metrics_type
    ,@dt as dt
    ,DATEADD(HOUR, 8, CURRENT_TIMESTAMP) as insert_timestamp
from
(    

 select 
    a.channel_id
    ,concat(a.hour_time ,':',a.minute_time) as hour_minute
    ,coalesce(sum(payed_amount),0) as payed_amount
from 
(
    select 
         d1.channel_name as channel_id 
        ,d2.hour_interval
        ,d2.hour_time
        ,d2.minute_time
    from 
        REALTIME_OMS.Dim_Mobile_Platform_Channel d1
    left join REALTIME_OMS.Dim_Mobile_Flow_Time d2
    on d1.conn_id = d2.conn_id
    where 
         d1.platform_name = 'digital' 
         and d1.metrics_type = 'sales'
) a
left join    
(
    select 
        channel_id
        ,payment_time
        ,payed_amount
        ,floor(datepart(hour,payment_time))  as hour_interval
    from 
        REALTIME_OMS.V_Process_Mobile_Digital_Sales_Order_Yesterday
) b
on b.hour_interval = a.hour_interval
and b.channel_id = a.channel_id
group by
    a.channel_id
    ,a.hour_time
    ,a.minute_time
) c
where 
    c.channel_id <> 'OTHER'

union all

select 
    'digital' as platform_name
    ,'all' as channel_name
    , hour_minute
    ,sum(payed_amount) over(order by hour_minute  ROWS unbounded preceding) as metrics_value
    ,'sales' as metrics_type
    ,@dt as dt
    ,DATEADD(HOUR, 8, CURRENT_TIMESTAMP) as insert_timestamp
from 
(
    select 
         concat(d.hour_time ,':',d.minute_time) as hour_minute
        ,coalesce(sum(payed_amount),0) as payed_amount
    from 
        REALTIME_OMS.Dim_Mobile_Flow_Time d
    left join    
    (
        select 
             payment_time
            ,payed_amount
            ,floor(datepart(hour,payment_time))  as hour_interval
            from 
                REALTIME_OMS.V_Process_Mobile_Digital_Sales_Order_Yesterday
    ) e
    on d.hour_interval = e.hour_interval
    group by
         d.hour_time
        ,d.minute_time
) f    
union all
select
    'tmall' as platform_name
    ,channel_id as channel_name
    ,hour_minute
    ,sum(payed_amount) over(partition by channel_id order by hour_minute  ROWS unbounded preceding) as metrics_value
    ,'sales' as metrics_type
    ,@dt as dt
    ,DATEADD(HOUR, 8, CURRENT_TIMESTAMP) as insert_timestamp
from
(    
    select 
        a.channel_id
        ,concat(a.hour_time ,':',a.minute_time) as hour_minute
        ,coalesce(sum(payed_amount),0) as payed_amount
    from 
    (
        select 
             d1.channel_name as channel_id 
            ,d2.hour_interval
            ,d2.hour_time
            ,d2.minute_time
        from 
            REALTIME_OMS.Dim_Mobile_Platform_Channel d1
        left join REALTIME_OMS.Dim_Mobile_Flow_Time d2
        on d1.conn_id = d2.conn_id
        where 
             d1.platform_name = 'tmall' 
             and d1.metrics_type = 'sales'
    ) a
    left join    
    (
        select 
             case
                when store_id = 'TMALL001' and shop_id = 'TM2' then 'Tmall-Wei'
                when store_id = 'TMALL004' then 'Tmall-Chaling'
                when store_id = 'TMALL005' then 'Tmall-PTR'
                else 'Tmall-Sephora'
            end as channel_id
            ,payment_time
            ,payed_amount
            ,floor(datepart(hour,payment_time))  as hour_interval
        from 
            REALTIME_OMS.V_Process_Mobile_Digital_Sales_Order_Yesterday
        where
            channel_id = 'TMALL'    
    ) b
    on b.hour_interval = a.hour_interval
    and b.channel_id = a.channel_id
    group by
        a.channel_id
        ,a.hour_time
        ,a.minute_time
) c
union all
select 
    'tmall' as platform_name
    ,'all' as channel_name
    , hour_minute
    ,sum(payed_amount) over(order by hour_minute  ROWS unbounded preceding) as metrics_value
    ,'sales' as metrics_type
    ,@dt as dt
    ,DATEADD(HOUR, 8, CURRENT_TIMESTAMP) as insert_timestamp
from 
(
    select 
         concat(d.hour_time ,':',d.minute_time) as hour_minute
        ,coalesce(sum(payed_amount),0) as payed_amount
    from 
        REALTIME_OMS.Dim_Mobile_Flow_Time d
    left join    
    (
        select 
             payment_time
            ,payed_amount
            ,floor(datepart(hour,payment_time))  as hour_interval
            from 
                REALTIME_OMS.V_Process_Mobile_Digital_Sales_Order_Yesterday
            where
                channel_id = 'TMALL'       
    ) e
    on d.hour_interval = e.hour_interval
    group by
         d.hour_time
        ,d.minute_time
) f    
union all
select
    'dragon' as platform_name
    ,channel_id as channel_name
    ,hour_minute
    ,sum(payed_amount) over(partition by channel_id order by hour_minute  ROWS unbounded preceding) as metrics_value
    ,'sales' as metrics_type
    ,@dt as dt
    ,DATEADD(HOUR, 8, CURRENT_TIMESTAMP) as insert_timestamp
from    
(    

    select 
        a.channel_id
        ,concat(a.hour_time ,':',a.minute_time) as hour_minute
        ,coalesce(sum(payed_amount),0) as payed_amount
    from 
    (
        select 
             d1.channel_name as channel_id 
            ,d2.hour_interval
            ,d2.hour_time
            ,d2.minute_time
        from 
            REALTIME_OMS.Dim_Mobile_Platform_Channel d1
        left join REALTIME_OMS.Dim_Mobile_Flow_Time d2
        on d1.conn_id = d2.conn_id
        where 
             d1.platform_name = 'dragon' 
             and d1.metrics_type = 'sales'
    ) a
    left join    
    (
        select 
            channel_id
            ,payment_time
            ,payed_amount
            ,floor(datepart(hour,payment_time))  as hour_interval
            from 
                REALTIME_OMS.V_Process_Mobile_Dragon_Sales_Order_Yesterday
    ) b
    on b.hour_interval = a.hour_interval
    and b.channel_id = a.channel_id
    group by
        a.channel_id
        ,a.hour_time
        ,a.minute_time
) c
where 
    c.channel_id <> 'OTHER'
union all
select 
    'dragon' as platform_name
    ,'all' as channel_name
    , hour_minute
    ,sum(payed_amount) over(order by hour_minute  ROWS unbounded preceding) as  metrics_value
    ,'sales' as metrics_type
    ,@dt as dt
    ,DATEADD(HOUR, 8, CURRENT_TIMESTAMP) as insert_timestamp
from 
(
    select 
         concat(d.hour_time ,':',d.minute_time) as hour_minute
        ,coalesce(sum(payed_amount),0) as payed_amount
    from 
        REALTIME_OMS.Dim_Mobile_Flow_Time d
    left join    
    (
        select 
             payment_time
            ,payed_amount
            ,floor(datepart(hour,payment_time))  as hour_interval
            from 
                REALTIME_OMS.V_Process_Mobile_Dragon_Sales_Order_Yesterday
    ) e
    on d.hour_interval = e.hour_interval
    group by
         d.hour_time
        ,d.minute_time
) f

union all

-- smart_ba 历史数据 2022年10月9日新增

select 
    'smartba' as platform_name
    ,'all' as channel_name
    , hour_minute
    ,sum(payed_amount) over(order by hour_minute  ROWS unbounded preceding) as  metrics_value
    ,'sales' as metrics_type
    ,@dt as dt
    ,DATEADD(HOUR, 8, CURRENT_TIMESTAMP) as insert_timestamp
from 
(
    select 
         concat(d.hour_time ,':',d.minute_time) as hour_minute
        ,coalesce(sum(payed_amount),0) as payed_amount
    from 
        REALTIME_OMS.Dim_Mobile_Flow_Time d
    left join    
    (
        select  payment_time ,payed_amount
            ,floor(datepart(hour,payment_time))  as hour_interval
            from REALTIME_OMS.V_Process_Mobile_Dragon_Sales_Order_Yesterday v
			left join REALTIME_OMS.Sales_Order_Smartba ba on v.sales_order_sys_id = ba.sales_order_sys_id
			where ba.smartba_flag = 1  group by v.sales_order_sys_id,payment_time,payed_amount
    ) e
    on d.hour_interval = e.hour_interval
    group by
         d.hour_time
        ,d.minute_time
) f;

END
GO
