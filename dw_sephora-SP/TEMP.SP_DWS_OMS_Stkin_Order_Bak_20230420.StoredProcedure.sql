/****** Object:  StoredProcedure [TEMP].[SP_DWS_OMS_Stkin_Order_Bak_20230420]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_OMS_Stkin_Order_Bak_20230420] AS
BEGIN
truncate table DW_OMS.DWS_OMS_Stkin_Order;
with online_stkin as
(
    select 
        a.online_stkin_order_sys_id as oms_stkin_order_sys_id,
        b.online_stkin_order_item_sys_id as oms_stkin_order_item_sys_id,
        a.stkin_order_number,
        a.sales_order_number,
        a.logistics_number,
        a.logistics_company,
        a.logistics_post_back_time,
        a.store_id as store_cd,
        a.channel_id as channel_cd,
        a.process_status,
        a.basic_status,
        cast (a.stkin_type as varchar) as stkin_type,
        a.return_sku_quantity,
        a.return_sku_packages,
        a.apply_logistics_fee,
        a.post_fee as stkin_fee,
        a.partial_stkin_reason,
        a.comment as comments,
        a.stkin_exception_type,
        a.stkin_trouble as stkin_trouble_type,
        a.return_exchange_type as stkin_return_exchange_type,
        a.stkin_exception_refund_type,
        a.resend_flag,
        a.virtual_stkin_flag,
        a.stkin_invoice_flag as invoice_stkin_flag,
        a.online_return_apply_order_sys_id,
        a.super_order_id,
        a.purchase_order_numbers,
        a.order_ware_house,
        b.item_sku as item_sku_cd,
        b.item_name,
        b.item_quantity,
        b.item_type,
        b.intact_quantity as item_intact_quantity,
        b.loss_quantity as item_loss_quantity,
        b.apply_sku_flag as item_apply_sku_flag,
        b.virtual_sku as item_virtual_sku_cd,
        b.po_info as item_po_info,
        b.wrong_sku_flag as item_wrong_sku_flag,
        b.loss_remark as item_loss_remark,
        b.apply_unit_price as item_apply_unit_price,
        b.sale_price as item_sale_price,
        b.refund_quantity as item_refund_quantity,
        null as item_status,
        null as item_size,
        null as item_color,
        null as item_weight,
        a.create_op,
        a.update_op,
        a.create_time,
        convert(date,a.create_time) as create_date,
        a.update_time,
        convert(date,a.update_time) as update_date,
        'ONLINE_STKIN' as source,
        0 as is_delete,
        current_timestamp as insert_timestamp
    from 
        STG_OMS.Online_Stkin_Order a
    left join
        STG_OMS.Online_Stkin_Order_Item b
    on 
        a.online_stkin_order_sys_id = b.online_stkin_order_sys_id
),
stkin_hd_dtl as
(
    select 
        a.oms_stkin_hd_sys_id as oms_stkin_order_sys_id,
        b.oms_order_item_sys_id as oms_stkin_order_item_sys_id,
        a.oms_stkin_no as stkin_order_number,
        a.oms_order_code as sales_order_number,
        null as logistics_number,
        null as logistics_company,
        null as logistics_post_back_time,
        a.store_id as store_cd,
        a.channel_id as channel_cd,
        a.process_status,
        a.basic_status,
        a.oms_stkin_type as stkin_type,
        null as return_sku_quantity,
        null as return_sku_packages,
        null apply_logistics_fee,
        a.post_fee as stkin_fee,
        null as partial_stkin_reason,
        a.stkin_remark as comments,
        null as stkin_exception_type,
        null as stkin_trouble_type,
        null as stkin_return_exchange_type,
        null as stkin_exception_refund_type,
        null as resend_flag,
        null as virtual_stkin_flag,
        a.stkin_invoice_flag as invoice_stkin_flag,
        null as online_return_apply_order_sys_id,
        null as super_order_id,
        a.source_order_code as purchase_order_numbers,
        a.ware_house_code as order_ware_house,
        b.item_sku as item_sku_cd,
        b.item_name,
        b.item_quantity,
        b.item_type,
        b.good_quantity as item_intact_quantity,
        null as item_loss_quantity,
        null as item_apply_sku_flag,
        null as item_virtual_sku_cd,
        null as item_po_info,
        null as item_wrong_sku_flag,
        null as item_loss_remark,
        null as item_apply_unit_price,
        null as item_sale_price,
        null as item_refund_quantity,
        b.item_status,
        b.item_size,
        b.item_color,
        b.item_weight,
        a.create_op,
        a.update_op,
        a.create_time,
        convert(date,a.create_time) as create_date,
        a.update_time,
        convert(date,a.update_time) as update_date,
        'STKIN_HD' as source,
        a.is_delete,
        current_timestamp as insert_timestamp
    from 
        STG_OMS.OMS_Stkin_HD a
    left join
        STG_OMS.OMS_Stkin_DTL b
    on 
        a.oms_stkin_hd_sys_id = b.oms_stkin_hd_sys_id
)
insert into DW_OMS.DWS_OMS_Stkin_Order
select 
    oms_stkin_order_sys_id,
    oms_stkin_order_item_sys_id,
    stkin_order_number,
    sales_order_number,
    logistics_number,
    logistics_company,
    logistics_post_back_time,
    store_cd,
    channel_cd,
    process_status,
    basic_status,
    stkin_type,
    return_sku_quantity,
    return_sku_packages,
    apply_logistics_fee,
    stkin_fee,
    partial_stkin_reason,
    comments,
    stkin_exception_type,
    stkin_trouble_type,
    stkin_return_exchange_type,
    stkin_exception_refund_type,
    resend_flag,
    virtual_stkin_flag,
    invoice_stkin_flag,
    online_return_apply_order_sys_id,
    super_order_id,
    purchase_order_numbers,
    order_ware_house,
    item_sku_cd,
    item_name,
    item_quantity,
    item_type,
    item_intact_quantity,
    item_loss_quantity,
    item_apply_sku_flag,
    item_virtual_sku_cd,
    item_po_info,
    item_wrong_sku_flag,
    item_loss_remark,
    item_apply_unit_price,
    item_sale_price,
    item_refund_quantity,
    item_status,
    item_size,
    item_color,
    item_weight,
    create_op,
    update_op,
    create_time,
    create_date,
    update_time,
    update_date,
    source,
    is_delete,
    insert_timestamp
from
(
    select * from online_stkin
    union all
    select * from stkin_hd_dtl
) t
END 

GO
