/****** Object:  StoredProcedure [DW_OrderHub].[SP_DWS_Store_Order_With_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OrderHub].[SP_DWS_Store_Order_With_SKU] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-10       tali           Initial Version
-- 2022-03-15       tali           update order status
-- 2022-03-17       tali           add province, city
-- 2022-04-14       tali           add vb
-- 2022-07-18       tali           fix duplicate order and add channel_name
-- 2022-07-27       tali           feat add district
-- 2022-11-11       houshuangqiang fix item_total_amount and item_discount_amount
-- 2022-11-18       houshuangqiang fix derived_type = 'NEW'
-- ========================================================================================
truncate table DW_OrderHub.DWS_Store_Order_With_SKU;
insert into DW_OrderHub.DWS_Store_Order_With_SKU 
select 
    sales_order_number,
    invoice_no,
    sales_order_number as invoice_id,
    channel_code,
    channel_name,
    store_code,
    province,
    city,
    district,
    member_card,
    order_status,
    is_placed,
    place_time,
    order_time,
    payment_time,
    pick_time,
    complete_time,
    item_sku_code,
    max(item_sku_name),
    sum(item_quantity),
    sum(item_total_amount),
    sum(item_apportion_amount),
    sum(item_discount_amount),
    shipping_amount,
    create_time,
    update_time,
    CURRENT_TIMESTAMP as insert_timestamp
from
(
    select
        a.order_id as sales_order_number,
        a.invoice_no as invoice_no,
        a.channel_id as channel_code,
        case when channel_id = 'DIANPING' then N'点评'
                when channel_id ='MEITUAN' then N'美团'
                when channel_id ='JDDJ' then N'京东到家'
        end as channel_name,
        a.store_code as store_code,
        si.province,
        si.city,
        si.district,
        a.card_code as member_card,
        case when a.s_order_status is null and a.channel_id = 'MEITUAN' then a.order_status else a.s_order_status end as order_status,
        case when a.s_order_status = 8 then 1 
         when a.channel_id = 'MEITUAN' and a.order_status = 8 then 1
         else 0 
        end as is_placed,
        -- a.s_order_status as order_status,
        -- case when s_order_status = 8 then 1 else 0 end as is_placed,
        a.order_pay_time as place_time,
        a.create_time as order_time,
        a.order_pay_time as payment_time,
        a.pick_time as pick_time,
        a.logistics_completed_time as complete_time,
        isnull(c.sku_code, b.sku_code) as item_sku_code,
        isnull(c.sku_name, b.sku_name) item_sku_name,
        isnull(c.quantity, b.quantity) as item_quantity,
        isnull(c.price_total + c.discount_price_total,  b.price_total + b.adjustment_price_total) as item_total_amount,
        isnull(c.price_total, b.price_total) as item_apportion_amount,
        isnull(c.discount_price_total, b.adjustment_price_total) as item_discount_amount,
        a.delivery_fee as shipping_amount,
        a.create_time,
        a.update_time
    from 
        STG_OrderHub.Store_Order a
    left join
        STG_OrderHub.Store_Order_Item b 
    on a.store_order_sys_id = b.store_order_sys_id
    left join 
        STG_OrderHub.Store_Order_Item_VB c
    on b.store_order_item_sys_id = c.order_item_sys_id
    left join
        stg_nso.storeinfo si
    on  a.store_code = cast(si.storeno as nvarchar)
    where a.derived_type = 'NEW'
) t
group by 
    sales_order_number,
    invoice_no,
    channel_code,
    channel_name,
    store_code,
    province,
    city,
    district,
    member_card,
    order_status,
    is_placed,
    place_time,
    order_time,
    payment_time,
    pick_time,
    complete_time,
    item_sku_code,
    shipping_amount,
    create_time,
    update_time
END
GO
