/****** Object:  StoredProcedure [TEST].[SP_RPT_Order_Dispatching_Time_test]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_Order_Dispatching_Time_test] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-03-24       wangzhichun        change source table
-- ========================================================================================
truncate table Test.RPT_Order_Dispatching_Time_Test;
insert into Test.RPT_Order_Dispatching_Time_Test
select 
    a.place_date,
    a.store_code as store_cd,
    --支付时间和物流发货时间差在24小时内的已签收订单订单数
    sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 <=24 then 1 else 0 end) as dispatching_time_within_24h_orders,
    --支付时间和物流发货时间差在24小时内的已签收订单订单数 与总订单数比率
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 <=24 then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as dispatching_time_within_24h_orders_ratio,
    --支付时间和物流发货时间差在48小时内的已签收订单订单数
    sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 <=48 then 1 else 0 end) as dispatching_time_within_48h_orders,
    --支付时间和物流发货时间差在48小时内的已签收订单订单数 与总订单数比率
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 <=48 then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as dispatching_time_within_48h_orders_ratio,
    --支付时间和物流发货时间差大于48小时的已签收订单订单数    
    sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 >48 then 1 else 0 end) as dispatching_time_within_48h_orders,
    --支付时间和物流发货时间差大于48小时的已签收订单订单数  与总订单数比率
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 >48 then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as dispatching_time_within_48h_orders_ratio,
    --取消订单数
    sum(case when a.internal_status_cd in('CANCELLED','PARTAIL_CANCEL') then 1 else 0 end) as cancelled_orders,
    --取消订单数比率
    concat(substring(cast(round(sum(case when a.internal_status_cd in('CANCELLED','PARTAIL_CANCEL') then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as cancelled_orders_ratio,
    --待定订单数
    sum(case when a.internal_status_cd in('WAIT_SAPPROCESS','PENDING','EXCEPTION') then 1 else 0 end) as pending_orders,
    concat(substring(cast(round(sum(case when a.internal_status_cd in('WAIT_SAPPROCESS','PENDING','EXCEPTION') then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as pending_orders_ratio,
    current_timestamp as insert_timestamp
from
(
    select distinct
        purchase_order_number,
        case when channel_code = 'SOA' then 'S001'
             when sub_channel_code='TMALL006' then 'TMALL_WEI'
             when sub_channel_code='TMALL004' then 'TMALL_CHALING'
             when sub_channel_code='TMALL005' then 'TMALL_PTR'
             when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
             else sub_channel_code
        end as store_code,
        cast(place_time as date) as place_date,
        payment_time,
        order_status as internal_status_cd
    from
        [temp].[Fact_OMS_Sales_Order_His_20230525_26_delete] fso
    where 
        is_placed = 1 
        and source='OMS'
        and type_code<>8
        -- and order_time>='2022-01-01'
        -- and  purchase_order_number is not null
)a
left JOIN
(
    SELECT distinct
        purchase_order_number,
        logistics_shipping_time
    from
        DWD.Fact_Logistics_Order
) b 
on a.purchase_order_number = b.purchase_order_number
group by 
    a.place_date,
    a.store_code
;
UPDATE STATISTICS DW_OMS.RPT_Order_Dispatching_Time;
end

GO
