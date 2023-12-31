/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_Order_Lead_Time_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_Order_Lead_Time_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       tali           delete collate
-- 2023-03-09       houshuangqiang change source table
-- 2023-03-24       wangzhichun        change source table
-- 2023-06-01       wangzhichun    order_status = N'SIGNED' change refund_status=N'已签收'
-- ========================================================================================

--1.目前报表以place_date为颗粒度，但type=8的订单是货到付款，现在逻辑中把货到付款给排除了；
--2.部分订单显示已经签收，但没有签收时间，占比大概1/7，查下来是换货订单，不知道还有没有其他原因，现在逻辑中把签收时间为空的排除了。
--3.大仓收单时间无法获取
--4. shipping_time/logistics_shipping_time的实际意义待确认
-- shipping_time 是否为实际仓库发货时间
-- logistics_shipping_time 是物流发货时间？还是揽收时间
--5. 数据中存在shipping_time比logistics_shipping_time早，也存在shipping_time比logistics_shipping_tim
truncate table DW_OMS.RPT_Order_Lead_Time_New;
insert into DW_OMS.RPT_Order_Lead_Time_New
select
	o.place_date
   ,o.store_cd -- 快递信息时间，如果在DWD.Fact_Logistics_Order中有的话，取Fact_Sales_Order中字段，担心Fact_Logistics_Order 中字段会引起更大差异,Fact_Logistics_Order  主要是为了补齐缺失的字段
   ,sum(cast(datediff(s, o.order_time, o.payment_time) as bigint)) as [order_to_payment_totaltime]                                  -- 订单-支付总时长
   ,sum(cast(datediff(s, o.payment_time, o.shipping_time) as bigint)) as [payment_to_shipping_totaltime]                            -- 付款-发货总时长
   ,sum(cast(datediff(s, o.shipping_time, logistics.logistics_shipping_time) as bigint)) as [shipping_to_logistic_shipping_totaltime]       -- 商家发货-物流发货总时长
   ,sum(cast(datediff(s, logistics.logistics_shipping_time, logistics.sign_time) as bigint)) as [logistic_shipping_to_sign_totaltime]               -- 物流发货-签收总时长
   ,sum(cast(datediff(s, o.payment_time, cast(substring([wms大仓收单时间],1,23) as datetime)) as bigint)) as [shipping_to_wms_recieve_totaltime] -- 付款时间-wms大仓收单时间总时长
   ,sum(cast(datediff(s, cast(substring([wms大仓收单时间],1,23) as datetime), logistics.logistics_shipping_time) as bigint)) as [wms_recieve_to_logistic_shipping_totaltime] -- wms大仓收单时间-物流发货总时长
   ,sum(cast(datediff(s, o.order_time, logistics.sign_time) as bigint)) as [totaltime]      -- 订单-签收总时间
   ,count(distinct o.purchase_order_number) as [totalorder]
   ,sum(cast(datediff(s, o.order_time, o.payment_time) as bigint)) / count(distinct o.purchase_order_number) as avg_period_of_order_to_payment
   ,sum(cast(datediff(s, o.payment_time, o.shipping_time) as bigint)) / count(distinct o.purchase_order_number) as avg_period_of_payment_to_shipping
   ,sum(cast(datediff(s, o.shipping_time, logistics.logistics_shipping_time) as bigint)) / count(distinct o.purchase_order_number) as avg_period_of_shipping_to_logistic_shipping
   ,sum(cast(datediff(s, logistics.logistics_shipping_time, logistics.sign_time) as bigint)) / count(distinct o.purchase_order_number) as avg_period_of_logistic_shipping_to_sign
   ,sum(cast(datediff(s, o.order_time, logistics.sign_time) as bigint)) / count(distinct o.purchase_order_number) as avg_period_of_total_leadtime
   ,current_timestamp as insert_timestamp
from
(
	select  distinct
	           sales_order_number
               ,purchase_order_number
               ,logistics_number
               ,case when channel_code = 'SOA' then 'S001'
                    when sub_channel_code='TMALL006' then 'TMALL_WEI'
                    when sub_channel_code='TMALL004' then 'TMALL_CHALING'
                    when sub_channel_code='TMALL005' then 'TMALL_PTR'
                    when sub_channel_code in ('TMALL001','TMALL002') then 'TMALL'
                    else sub_channel_code
                end as store_cd
               ,format(place_time, 'yyyy-MM-dd' ) as place_date
               ,order_time
               ,payment_time
               ,shipping_time
		from    [DWD].[Fact_OMS_Sales_Order_New]
		where   source = 'NEW OMS'
		and     po_order_status =  N'已签收'
		AND     sub_channel_code <> 'GWP001'
		and     type_code <> 8
		and     is_placed = 1
		and     shipping_time is not null
) o
inner join
(
    select  distinct
            purchase_order_number
            ,logistics_shipping_time
		    ,sign_time
    from    DWD.Fact_Logistics_Order_New
    where   source = 'OMS'
    and logistics_shipping_time is not null
    and sign_time is not null
) logistics
on      o.purchase_order_number = logistics.purchase_order_number
left    join [MANUAL_WMS].[WMS_Order_Detail] c
on      o.purchase_order_number = c.[eb order]
and     isdate([wms大仓收单时间]) =1
group   by o.place_date,o.store_cd
END
GO
