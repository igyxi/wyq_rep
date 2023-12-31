/****** Object:  StoredProcedure [TEMP].[SP_DWS_dws_online_return_apply_order_Bak_20230330]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_dws_online_return_apply_order_Bak_20230330] AS
BEGIN
truncate table DW_OMS.DWS_Online_Return_Apply_Order;
with online_return_item as 
(     
    select t.*, purchase_order_number, applyQty 
    from STG_OMS.Online_Return_Apply_Order_Item t
        CROSS APPLY OPENJson(po_info) as root 
            cross APPLY openjson(root.value)
            with (
                purchase_order_number varchar(512) '$.purchaseOrderNumber',
                applyQty int '$.applyQty'
            )
)

insert into DW_OMS.DWS_Online_Return_Apply_Order
select 
    a.online_return_apply_order_sys_id,
    a.super_order_id,
    a.return_number,
    a.account_info,
    a.actual_delivery_fee,
    a.actual_product_fee,
    a.actual_total_fee,
    a.advice_delivery_fee,
    a.advice_product_fee,
    a.advice_total_fee,
    a.origin_delivery_fee,
    a.shop_pay_delivery_fee,
    a.basic_status,
    a.order_status,
    a.comment,
    a.logistics_number,
    a.logistics_company,
    a.mobile,
    a.card_no,
    a.sales_order_number,
    a.return_reason,
    a.return_type,
    a.process_status,
    a.process_comment,
    a.apply_image_paths,
    a.store_id,
    a.channel_id,
    a.apply_channel_id,
    a.shop_pay_delivery_fee_flag,
    a.warehouse_status,
    a.version,
    a.logistics_post_back_time,
    a.virtual_stkin_flag,
    a.is_return_express_fee,
    a.shop_id,
    b.online_return_apply_order_item_sys_id,
    b.sales_order_item_sys_id,
    b.apply_qty as item_apply_qty,
    b.sale_price as item_sale_price,
    b.apply_unit_price as item_apply_unit_price,
    b.apply_total_price as item_apply_amount,
    b.item_type,
    b.item_sku as item_sku_cd,
    b.item_name,
    b.apply_sku_flag as item_apply_sku_flag,
    b.virtual_sku as item_virtual_sku,
    b.po_info as item_po_info,
    b.purchase_order_number,
    b.applyQty as purchase_apply_qty,
    b.purchase_sale_price,
    b.purchase_payed_unit_price,
    a.is_delete,
    a.create_time,
    a.update_time,
    current_timestamp as insert_timestamp
from 
    [STG_OMS].[Online_Return_Apply_Order] a
left join
    online_return_item b
on a.online_return_apply_order_sys_id = b.online_return_apply_order_sys_id

END 
GO
