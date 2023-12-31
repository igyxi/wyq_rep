/****** Object:  StoredProcedure [TEMP].[SP_Fact_Refund_Order_Bak_202304227]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Refund_Order_Bak_202304227] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-28       Tali           initial
-- 2022-02-28       Tali           fix the discount bug
-- 2020-04-06       Tali           change channel_code
-- 2022-04-18       Tali           abs for pos item_apportion_amount
-- 2022-06-15       Tali           change pos return logic
-- 2022-06-15       Tali           change logic
-- 2022-07-12       tali           add sync_type/sync_status/sync_time
-- 2022-12-28       houshuangqiang add 'HUB' source
-- 2023-02-17       houshuangqiang add product_in_status/product_out_status
-- 2023-03-17       houshuangqiang add order_status
-- 2023-03-17       add refund_source
-- ========================================================================================
truncate table DWD.Fact_Refund_Order;
insert into DWD.Fact_Refund_Order
select
    t.refund_no,
    so.channel_code,
    so.sub_channel_code,
    so.store_code as store_code,
    t.refund_status,
    t.refund_type,
    t.refund_reason,
    t.apply_time,
    t.refund_time,
    t.refund_amount,
    t.product_amount,
    t.delivery_amount,
    t.product_in_status,
    t.product_out_status,
    t.refund_mobile,
    t.refund_comments,
    t.return_pos_flag,
    t.refund_source,
    t.sales_order_number,
    isnull(t.purchase_order_number, so.purchase_order_number) as purchase_order_number,
    so.member_card,
    so.order_status,
    so.is_placed,
    so.place_time,
    t.item_sku_name,
    t.item_sku_code,
    t.item_quantity,
    t.item_total_amount,
    t.item_apportion_amount,
    t.item_discount_amount,
    t.sync_type,
    t.sync_status,
    t.sync_time,
    t.create_time as create_time,
    t.update_time as update_time,
    t.is_delete,
    'OMS' as source,
    current_timestamp as insert_timestamp
from
    DW_OMS.DW_Refund_Order t
join
    DWD.Fact_Sales_Order so
on t.sales_order_number = so.sales_order_number
and t.item_sku_code = so.item_sku_code
and (t.purchase_order_number = so.purchase_order_number or t.purchase_order_number is null)

union all
-- POS
select
    a.barcode as refund_no,
    'OFF_LINE' as channel_code,
    null as sub_channel_code,
    a.store_code as store_code,
    'REFUNDED' as refund_status,
    null as refund_type,
    null as refund_reason,
    null as apply_time,
    try_cast(cast(CONVERT(date, SUBSTRING(a.barcode,17,8), 112) as nvarchar) + ' ' + SUBSTRING(a.barcode,25,2) + ':'+ SUBSTRING(a.barcode,27,2)+':' + SUBSTRING(a.barcode,29,2) as datetime) as refund_time,
    null as refund_amount,
    null as product_amount,
    null as delivery_amount,
    null as product_in_status,
    null as product_out_status,
    null as refund_mobile,
    null as comments,
    null as return_pos_flag,
    null as refund_source,
    a.org_barcode as sales_order_number,
    null as purchase_order_number,
    null as order_status,
    a.member_card as member_card,
    1 as is_placed,
    try_cast(cast(CONVERT(date, SUBSTRING(a.org_barcode,17,8), 112) as nvarchar) + ' ' + SUBSTRING(a.org_barcode,25,2) + ':'+ SUBSTRING(a.org_barcode,27,2)+':' + SUBSTRING(a.org_barcode,29,2) as datetime) as place_time,
    a.item_sku_name,
    a.item_sku_code,
    isnull(abs(try_cast(a.item_quantity as int)),0) as item_quantity,
    isnull(abs(try_cast(a.item_total_amount as decimal)),0) as item_total_amount,
    abs(item_apportion_amount) as item_apportion_amount,
    item_discount_amount,
    null as sync_type,
    null as sync_status,
    null as sync_time,
    null as create_time,
    null as update_time,
    null as is_delete,
    'POS' as source,
    current_timestamp as insert_timestamp
from
    DW_POS.DWS_POS_Return_Order a
union   all
-- O2O
select
    p.refund_no,
    p.channel_code,
    null as sub_channel_code,
    p.store_code,
    'REFUNDED' as refund_status,
    p.refund_type,
    p.refund_reason,
    p.apply_time,
    p.refund_time,
    p.refund_amount,
    p.product_amount,
    p.delivery_amount,
    null as product_in_status,
    null as product_out_status,
    p.refund_mobile,
    p.refund_comments as comments,
    p.return_pos_flag,
    p.order_type,
    p.sales_order_number,
    p.purchase_order_number,
    so.order_status,
    p.member_card,
    p.is_placed,
    p.place_time,
    t.eb_sku_name as item_sku_name, -- new_oms表中的item_sku_name与dim_sku_info中的eb_sku_name不一致，在这里使用eb_sku_name，上游表的DWS_Refund_Order中的item_sku_name可能会删除
    p.item_sku_code,
    p.item_quantity,
    p.item_total_amount,
    p.item_apportion_amount,
    p.item_discount_amount,
    p.sync_type,
    p.sync_status,
    p.sync_time,
    p.create_time,
    p.update_time,
    p.is_delete,
    'HUB' as source,
    current_timestamp as insert_timestamp
from
    DW_OMS_Order.DW_O2O_Refund_Order p
left join
    DWD.Fact_Sales_Order so
on  p.sales_order_number = so.sales_order_number
and p.item_sku_code = so.item_sku_code
-- and (p.purchase_order_number = so.purchase_order_number or p.purchase_order_number is null)
left join DWD.DIM_SKU_Info t
on  p.item_sku_code = t.sku_code
where
    p.refund_status = N'退款成功'
;
end

GO
