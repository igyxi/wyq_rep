/****** Object:  StoredProcedure [TEMP].[SP_RPT_Negative_Order_Overview_Bak_20230323]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Negative_Order_Overview_Bak_20230323] AS 
BEGIN
truncate table DW_OMS.RPT_Negative_Order_Overview;
insert into DW_OMS.RPT_Negative_Order_Overview
select 
    a.place_date,
    a.store_cd,
    sum(case when a.internal_status_cd = 'REJECTED' then 1 else 0 end) as reject_orders,
    concat(substring(cast(round(sum(case when a.internal_status_cd = 'REJECTED' then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as reject_orders_ratio,
    sum(case when a.internal_status_cd = 'REJECTED' then a.apportion_amount else 0 end) as reject_amount,
    concat(substring(cast(round(sum(case when a.internal_status_cd = 'REJECTED' then a.apportion_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as reject_amount_ratio,
    sum(case when b.purchase_order_number is not null then 1 else 0 end) as return_orders,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as return_orders_ratio,
    sum(case when b.purchase_order_number is not null then return_amount else 0 end) as return_amount,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null then return_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as return_amount_ratio,
    sum(case when a.internal_status_cd = 'REJECTED' or b.purchase_order_number is not null then 1 else 0 end) as reject_return_orders,
    concat(substring(cast(round(sum(case when a.internal_status_cd = 'REJECTED' or b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as reject_return_orders_ratio,
    sum(case when a.internal_status_cd = 'REJECTED' then a.apportion_amount 
             when b.purchase_order_number is not null then return_amount
        else 0 end) as reject_return_amount,
    concat(substring(cast(round(sum(case when a.internal_status_cd = 'REJECTED' then a.apportion_amount 
             when b.purchase_order_number is not null then return_amount
        else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as reject_return_amount_ratio,
    sum(case when a.internal_status_cd in('PARTAIL_CANCEL','CANCELLED') then 1 else 0 end) as cancel_orders,
    concat(substring(cast(round(sum(case when a.internal_status_cd in('PARTAIL_CANCEL','CANCELLED') then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as cancel_orders_ratio,
    sum(case when a.internal_status_cd in('PARTAIL_CANCEL','CANCELLED') then a.apportion_amount else 0 end) as cancel_amount,
    concat(substring(cast(round(sum(case when a.internal_status_cd in('PARTAIL_CANCEL','CANCELLED') then a.apportion_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as cancel_amount_ratio,
    sum(case when a.internal_status_cd in('PARTAIL_CANCEL','CANCELLED','REJECTED') or b.purchase_order_number is not null then 1 else 0 end) as total_refund_orders,
    concat(substring(cast(round(sum(case when a.internal_status_cd in('PARTAIL_CANCEL','CANCELLED','REJECTED') or b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as total_refund_orders_ratio,
    sum(case when a.internal_status_cd in('PARTAIL_CANCEL','CANCELLED','REJECTED') then a.apportion_amount 
             when b.purchase_order_number is not null then return_amount
        else 0 end) as total_refund_amount,
    concat(substring(cast(round(sum(case when a.internal_status_cd in('PARTAIL_CANCEL','CANCELLED','REJECTED') then a.apportion_amount 
             when b.purchase_order_number is not null then return_amount
        else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as total_refund_amount_ratio,
   count(1) as total_orders,
    sum(apportion_amount) as total_amount,
    current_timestamp as insert_timestamp
from
(
    select
        place_date,
        purchase_order_number,
        case when CHARINDEX('TMALL',store_cd)>0 then channel_cd else store_cd end as store_cd,
        internal_status_cd,
        round(sum(item_apportion_amount),2) as apportion_amount
    from 
        DW_OMS.RPT_Sales_Order_SKU_Level
    where 
        is_placed_flag = 1
    and 
        type_cd <> 2
    and 
        store_cd <> 'GWP001'
    and 
        split_type_cd <> 'SPLIT_ORIGIN'
    and
        basic_status_cd <> 'DELETED'
    group by 
        place_date,
        purchase_order_number,
        case when CHARINDEX('TMALL',store_cd)>0 then channel_cd else store_cd end,
        internal_status_cd
)a
left join
(
    select 
        purchase_order_number,
        round(sum(item_apply_amount),2) as return_amount
    from
        DW_OMS.DWS_Negative_Order
    where 
        negative_type in (N'退货退款',N'线上退货退款')
    and 
        purchase_order_number is not null
    group by 
        purchase_order_number
)b 
on a.purchase_order_number = b.purchase_order_number
group by 
    a.place_date,
    a.store_cd
;
UPDATE STATISTICS DW_OMS.RPT_Negative_Order_Overview;
end
GO
