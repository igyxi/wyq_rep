/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_Negative_Order_Overview]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_Negative_Order_Overview] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2023-02-23       houshuangqiang replace DW_OMS.RPT_Sales_Order_SKU_Level/DW_OMS.DWS_Negative_Order & store_cd channge to sub_channel_code
-- 2023-03-15       tali           new version
-- ========================================================================================
truncate table DW_OMS.RPT_Negative_Order_Overview;

insert into DW_OMS.RPT_Negative_Order_Overview
select
    a.place_date,
    a.store_code,
    sum(case when a.order_status = 'REJECTED' then 1 else 0 end) as reject_orders,
    concat(substring(cast(round(sum(case when a.order_status = 'REJECTED' then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as reject_orders_ratio,
    sum(case when a.order_status = 'REJECTED' then a.apportion_amount else 0 end) as reject_amount,
    concat(substring(cast(round(sum(case when a.order_status = 'REJECTED' then a.apportion_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as reject_amount_ratio,
    sum(case when b.purchase_order_number is not null then 1 else 0 end) as return_orders,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as return_orders_ratio,
    sum(case when b.purchase_order_number is not null then return_amount else 0 end) as return_amount,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null then return_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as return_amount_ratio,
    sum(case when a.order_status = 'REJECTED' or b.purchase_order_number is not null then 1 else 0 end) as reject_return_orders,
    concat(substring(cast(round(sum(case when a.order_status = 'REJECTED' or b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as reject_return_orders_ratio,
    sum(case when a.order_status = 'REJECTED' then a.apportion_amount
             when b.purchase_order_number is not null then return_amount
        else 0 end) as reject_return_amount,
    concat(substring(cast(round(sum(case when a.order_status = 'REJECTED' then a.apportion_amount
             when b.purchase_order_number is not null then return_amount
        else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as reject_return_amount_ratio,
    sum(case when a.order_status in('PARTAIL_CANCEL','CANCELLED') then 1 else 0 end) as cancel_orders,
    concat(substring(cast(round(sum(case when a.order_status in('PARTAIL_CANCEL','CANCELLED') then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as cancel_orders_ratio,
    sum(case when a.order_status in('PARTAIL_CANCEL','CANCELLED') then a.apportion_amount else 0 end) as cancel_amount,
    concat(substring(cast(round(sum(case when a.order_status in('PARTAIL_CANCEL','CANCELLED') then a.apportion_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as cancel_amount_ratio,
    sum(case when a.order_status in('PARTAIL_CANCEL','CANCELLED','REJECTED') or b.purchase_order_number is not null then 1 else 0 end) as total_refund_orders,
    concat(substring(cast(round(sum(case when a.order_status in('PARTAIL_CANCEL','CANCELLED','REJECTED') or b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as total_refund_orders_ratio,
    sum(case when a.order_status in('PARTAIL_CANCEL','CANCELLED','REJECTED') then a.apportion_amount
             when b.purchase_order_number is not null then return_amount
        else 0 end) as total_refund_amount,
    concat(substring(cast(round(sum(case when a.order_status in('PARTAIL_CANCEL','CANCELLED','REJECTED') then a.apportion_amount
             when b.purchase_order_number is not null then return_amount
        else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as total_refund_amount_ratio,
   count(1) as total_orders,
    sum(apportion_amount) as total_amount,
    current_timestamp as insert_timestamp
from
(
    select
        format(place_time, 'yyyy-MM-dd') as place_date,
        purchase_order_number,
--        case when channel_code = 'SOA' then 'S001' else sub_channel_code end as store_code,
        case when channel_code = 'SOA' then 'S001'
             when sub_channel_code='TMALL006' then 'TMALL_WEI'
             when sub_channel_code='TMALL004' then 'TMALL_CHALING'
             when sub_channel_code='TMALL005' then 'TMALL_PTR'
             when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
             else sub_channel_code
        end as store_code,
        order_status,
        round(sum(case when item_sku_code = 'TRP001' then item_apportion_amount - shipping_amount -- EB虚拟券的时候，在with_sku表时，加了邮费, 原来的逻辑是不包含邮费的
             else item_apportion_amount
        end),2) as apportion_amount
    from
        DWD.Fact_Sales_Order
    where
        is_placed = 1
    and source = 'OMS'
    group by
        format(place_time, 'yyyy-MM-dd'),
        purchase_order_number,
        case when channel_code = 'SOA' then 'S001'
                     when sub_channel_code='TMALL006' then 'TMALL_WEI'
                     when sub_channel_code='TMALL004' then 'TMALL_CHALING'
                     when sub_channel_code='TMALL005' then 'TMALL_PTR'
                     when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
                     else sub_channel_code
                end,
        order_status
)a
left join
(
    select
        purchase_order_number,
        round(sum(item_apportion_amount),2) as return_amount
    from
        DWD.Fact_Refund_Order
    where

        refund_type in ('RETURN_REFUND','ONLINE_RETURN_REFUND')
    and
        purchase_order_number is not null
    group by
        purchase_order_number
)b
on a.purchase_order_number = b.purchase_order_number
group by
    a.place_date,
    a.store_code
END

GO
