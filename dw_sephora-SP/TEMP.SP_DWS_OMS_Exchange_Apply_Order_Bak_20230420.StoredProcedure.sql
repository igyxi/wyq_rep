/****** Object:  StoredProcedure [TEMP].[SP_DWS_OMS_Exchange_Apply_Order_Bak_20230420]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_OMS_Exchange_Apply_Order_Bak_20230420] AS
BEGIN
truncate table DW_OMS.DWS_OMS_Exchange_Apply_Order;
insert into DW_OMS.DWS_OMS_Exchange_Apply_Order
select
    a.oms_exchange_apply_order_sys_id as oms_exchange_apply_order_sys_id,
    b.oms_exchange_apply_order_item_sys_id as oms_exchange_apply_order_item_sys_id,
    b.oms_order_item_sys_id as oms_order_item_sys_id,
    a.basic_status as basic_status,
    a.process_comment as process_comment,
    a.comment as exchange_apply_comment,
    a.customer_id as customer_id,
    a.exchange_no as exchange_number,
    a.exchange_reason as exchange_reason,
    a.oms_order_code as sales_order_number,
    a.order_status as order_status,
    a.process_status as process_status,
    a.source_order_code as source_order_code,
    a.store_id as store_cd,
    a.channel_id as channel_cd,
    a.oms_warehouse_id as warehouse_cd,
    b.item_adjustment as item_adjustment,
    b.item_type as item_type,
    b.list_price as item_list_price,
    b.qty as item_qty,
    b.sales_price as item_sales_price,
    b.sku_code as item_sku_code,
    b.sku_name as item_sku_name,
    b.total_adjustment as item_total_adjustment,
    b.total_price as item_total_price,
    b.item_size as item_size,
    b.item_color as item_color,
    b.item_weight as item_weight,
    b.comment as item_comment,
    b.item_kind as item_kind,
    a.version as version,
    a.create_time as create_time,
    convert(date,a.create_time) as create_date,
    a.update_time as update_time,
    convert(date,a.update_time) as update_date,
    current_timestamp as insert_tiemstamp
from
    [STG_OMS].[OMS_Exchange_Apply_Order] a 
left join
    [STG_OMS].[OMS_Exchange_Apply_Order_Item] b
on a.oms_exchange_apply_order_sys_id = b.oms_exchange_apply_order_sys_id;
END
GO
