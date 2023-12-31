/****** Object:  StoredProcedure [TEMP].[SP_RPT_Negative_Order_Overview_New_Bak_20230309]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Negative_Order_Overview_New_Bak_20230309] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2023-02-23       houshuangqiang replace DW_OMS.RPT_Sales_Order_SKU_Level/DW_OMS.DWS_Negative_Order & store_cd channge to sub_channel_code
-- ========================================================================================
truncate table DW_OMS.RPT_Negative_Order_Overview_New;
with refund_order as
(
    select  refund.purchase_order_number
            ,refund.return_amount
    from
    (
        select  purchase_order_number,
                round(sum(item_apportion_amount),2) as return_amount
        from    DWD.Fact_Refund_Order_New
        where   source = 'OMS'
    --    and     order_status in ('SHIPPED', 'SIGNED')
        and     refund_type in ('RETURN_REFUND', 'ONLINE_RETURN_REFUND') -- 退货退款, 线上退货退款, 还需要限制order_status in ('SHIPPED', 'SIGNED')，所以关联Fact_OMS_Sales_Order过滤
    --    negative_type in (N'退货退款',N'线上退货退款')
        and     purchase_order_number is not null
        group   by purchase_order_number
    ) refund
    inner join
    (
        select  purchase_order_number
        from    DWD.Fact_OMS_Sales_Order_New
        where   order_status in ('SHIPPED', 'SIGNED')
        group   by purchase_order_number
    ) so
    on  refund.purchase_order_number = refund.purchase_order_number
)


insert into DW_OMS.RPT_Negative_Order_Overview_New
select
    o.place_date,
    o.sub_channel_code,
    sum(case when o.order_status = 'REJECTED' then 1 else 0 end) as reject_orders,
    concat(substring(cast(round(sum(case when o.order_status = 'REJECTED' then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as reject_orders_ratio,
    sum(case when o.order_status = 'REJECTED' then o.apportion_amount else 0 end) as reject_amount,
    concat(substring(cast(round(sum(case when o.order_status = 'REJECTED' then o.apportion_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as reject_amount_ratio,
    sum(case when b.purchase_order_number is not null then 1 else 0 end) as return_orders,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as return_orders_ratio,
    sum(case when b.purchase_order_number is not null then return_amount else 0 end) as return_amount,
    concat(substring(cast(round(sum(case when b.purchase_order_number is not null then return_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as return_amount_ratio,
    sum(case when o.order_status = 'REJECTED' or b.purchase_order_number is not null then 1 else 0 end) as reject_return_orders,
    concat(substring(cast(round(sum(case when o.order_status = 'REJECTED' or b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as reject_return_orders_ratio,
    sum(case when o.order_status = 'REJECTED' then o.apportion_amount
             when b.purchase_order_number is not null then return_amount
        else 0 end) as reject_return_amount,
    concat(substring(cast(round(sum(case when o.order_status = 'REJECTED' then o.apportion_amount
             when b.purchase_order_number is not null then return_amount
        else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as reject_return_amount_ratio,
    sum(case when o.order_status in('PARTAIL_CANCEL','CANCELLED') then 1 else 0 end) as cancel_orders,
    concat(substring(cast(round(sum(case when o.order_status in('PARTAIL_CANCEL','CANCELLED') then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as cancel_orders_ratio,
    sum(case when o.order_status in('PARTAIL_CANCEL','CANCELLED') then o.apportion_amount else 0 end) as cancel_amount,
    concat(substring(cast(round(sum(case when o.order_status in('PARTAIL_CANCEL','CANCELLED') then o.apportion_amount else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as cancel_amount_ratio,
    sum(case when o.order_status in('PARTAIL_CANCEL','CANCELLED','REJECTED') or b.purchase_order_number is not null then 1 else 0 end) as total_refund_orders,
    concat(substring(cast(round(sum(case when o.order_status in('PARTAIL_CANCEL','CANCELLED','REJECTED') or b.purchase_order_number is not null then 1 else 0 end)*100.0/count(1),2) as varchar(512)),1,5),'%') as total_refund_orders_ratio,
    sum(case when o.order_status in('PARTAIL_CANCEL','CANCELLED','REJECTED') then o.apportion_amount
             when b.purchase_order_number is not null then return_amount
        else 0 end) as total_refund_amount,
    concat(substring(cast(round(sum(case when o.order_status in('PARTAIL_CANCEL','CANCELLED','REJECTED') then o.apportion_amount
             when b.purchase_order_number is not null then return_amount
        else 0 end)*100/sum(apportion_amount),2) as varchar(512)),1,5),'%') as total_refund_amount_ratio,
   count(1) as total_orders,
    sum(apportion_amount) as total_amount,
    current_timestamp as insert_timestamp
from
(
    select  format(place_time, 'yyyy-MM-dd') place_date,
            purchase_order_number,
            case when charindex('TMALL',sub_channel_code)>0 then channel_code else sub_channel_code end as sub_channel_code,
            order_status,
            round(sum(item_apportion_amount),2) as apportion_amount
    from    DWD.Fact_OMS_Sales_Order_New
    where   is_placed = 1
    and     type_code <> 2
    and     sub_channel_code <> 'GWP001'
    group   by  format(place_time, 'yyyy-MM-dd'), purchase_order_number,order_status,
            case when charindex('TMALL',sub_channel_code)>0 then channel_code else sub_channel_code end
) o
left    join refund_order b
on      o.purchase_order_number = b.purchase_order_number
group   by  o.place_date,o.sub_channel_code
--(
--    select  purchase_order_number,
--            round(sum(item_apportion_amount),2) as return_amount
--    from    DWD.Fact_Refund_Order_New
--    where   source = 'OMS'
--    and     order_status in ('SHIPPED', 'SIGNED')
--    and     refund_type in ('RETURN_REFUND', 'ONLINE_RETURN_REFUND') -- 退货退款, 线上退货退款
----    negative_type in (N'退货退款',N'线上退货退款')
--    and     purchase_order_number is not null
--    group   by purchase_order_number
--)b

END
;

GO
