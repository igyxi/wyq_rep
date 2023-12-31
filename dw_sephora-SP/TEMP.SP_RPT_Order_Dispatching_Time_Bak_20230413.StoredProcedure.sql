/****** Object:  StoredProcedure [TEMP].[SP_RPT_Order_Dispatching_Time_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Order_Dispatching_Time_Bak_20230413] AS 
BEGIN
truncate table DW_OMS.RPT_Order_Dispatching_Time;
insert into DW_OMS.RPT_Order_Dispatching_Time
select 
    a.place_date,
    a.store_cd,
    sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 <=24 then 1 else 0 end) as dispatching_time_within_24h_orders,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 <=24 then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as dispatching_time_within_24h_orders_ratio,
    sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 <=48 then 1 else 0 end) as dispatching_time_within_48h_orders,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 <=48 then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as dispatching_time_within_48h_orders_ratio,
    sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 >48 then 1 else 0 end) as dispatching_time_within_48h_orders,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null and a.internal_status_cd = 'SIGNED' and datediff(s,payment_time,logistics_shipping_time)/3600.0 >48 then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as dispatching_time_within_48h_orders_ratio,
    sum(case when a.internal_status_cd in('CANCELLED','PARTAIL_CANCEL') then 1 else 0 end) as cancelled_orders,
    concat(substring(cast(round(sum(case when a.internal_status_cd in('CANCELLED','PARTAIL_CANCEL') then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as cancelled_orders_ratio,
    sum(case when a.internal_status_cd in('WAIT_SAPPROCESS','PENDING','EXCEPTION') then 1 else 0 end) as pending_orders,
    concat(substring(cast(round(sum(case when a.internal_status_cd in('WAIT_SAPPROCESS','PENDING','EXCEPTION') then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as pending_orders_ratio,
    current_timestamp as insert_timestamp
from
(
    select distinct
        purchase_order_number,
        case when CHARINDEX('TMALL',store_cd)>0 then channel_cd else store_cd end as store_cd,
        place_date,
        payment_time,
        internal_status_cd
    from
        DW_OMS.RPT_Sales_Order_SKU_Level
    where 
        split_type_cd <> 'SPLIT_ORIGIN'
    and 
        type_cd <> 2
    and 
        basic_status_cd <> 'DELETED'
    and 
        so_type_cd <> 8
    and 
        is_placed_flag = 1 
)a
left JOIN
(
    SELECT distinct
        purchase_order_number,
        logistics_shipping_time
    from
        DW_OMS.DWS_Purchase_Order
    where 
        split_type <> 'SPLIT_ORIGIN'
    and 
        internal_status = 'SIGNED'
    and 
        type_cd <> 2
    and 
        type_cd <> 8
    and 
        logistics_shipping_time is not null
    and 
        basic_status <> 'DELETED'
)b 
on a.purchase_order_number = b.purchase_order_number
group by 
    a.place_date,
    a.store_cd
;
UPDATE STATISTICS DW_OMS.RPT_Order_Dispatching_Time;
end
GO
