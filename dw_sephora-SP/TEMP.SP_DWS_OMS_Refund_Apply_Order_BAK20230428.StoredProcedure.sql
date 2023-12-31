/****** Object:  StoredProcedure [TEMP].[SP_DWS_OMS_Refund_Apply_Order_BAK20230428]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_OMS_Refund_Apply_Order_BAK20230428] AS
BEGIN
truncate table DW_OMS.DWS_OMS_Refund_Apply_Order;
insert into DW_OMS.DWS_OMS_Refund_Apply_Order
select
    a.oms_refund_apply_order_sys_id,
    a.actual_delivery_fee,
    a.actual_product_fee,
    a.actual_total_fee,
    a.advice_delivery_fee,
    a.advice_product_fee,
    a.advice_total_fee,
    a.origin_delivery_fee,
    a.customer_pay_delivery_fee,
    a.shop_pay_delivery_fee,
    a.final_total_fee,
    a.advice_shop_stkin_delivery_fee,
    a.basic_status,
    a.order_status,
    a.comment,
    a.customer_id,
    a.oms_order_code as sales_order_number,
    a.source_order_code as purchase_order_number,
    a.refund_code,
    a.refund_reason,
    a.refund_type,
    a.process_status,
    a.account_name,
    a.bank_name,
    a.bank_account,
    a.process_comment,
    a.shop_pay_delivery_fee_flag,
    a.return_wh,
    a.from_type,
    a.mms_flag,
    a.tmall_refund_id,
    b.oms_refund_order_items_sys_id,
    b.oms_order_item_sys_id,
    b.sku_code as item_sku_cd,
    b.sku_name as item_name,
    b.item_type,
    b.apply_qty as item_apply_qty,
    b.barcode as item_barcode,
    b.list_price as item_list_price,
    b.qty as item_qty,
    b.sales_price as item_sales_price,
    b.total_price as item_amount,
    b.item_adjustment,
    b.total_adjustment,
    a.create_time,
    a.last_update_time as update_time,
    a.version,
    a.is_delete,
    current_timestamp as inster_timestamp
from
   STG_OMS.OMS_Refund_Apply_Order a
left join
    STG_OMS.OMS_Refund_Order_Items b
on 
    a.oms_refund_apply_order_sys_id = b.oms_refund_apply_order_sys_id;
    END 
    
GO
