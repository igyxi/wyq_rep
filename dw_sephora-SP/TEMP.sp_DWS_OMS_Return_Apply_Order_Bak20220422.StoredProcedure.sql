/****** Object:  StoredProcedure [TEMP].[sp_DWS_OMS_Return_Apply_Order_Bak20220422]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[sp_DWS_OMS_Return_Apply_Order_Bak20220422] AS
BEGIN
truncate table DW_OMS.DWS_OMS_Return_Apply_Order;
with online_return as 
(
    select 
        a.online_return_apply_order_sys_id as oms_return_apply_order_sys_id,
		b.online_return_apply_order_item_sys_id as oms_return_apply_order_item_sys_id,
        a.super_order_id,
        a.sales_order_number,
		b.sales_order_item_sys_id,
        a.return_number,
        case when a.return_type is null then 'ONLINE_RETURN' else a.return_type end as return_type,
        a.return_reason,
        a.process_status,
        a.basic_status,
        a.process_comment,
        a.apply_channel_id as channel_cd,
        a.actual_delivery_fee,
        a.actual_product_fee,
        a.actual_total_fee,
        a.advice_delivery_fee,
        a.advice_product_fee,
        a.advice_total_fee,
        a.origin_delivery_fee,
        a.shop_pay_delivery_fee_flag,
        a.shop_pay_delivery_fee,
        a.logistics_number,
        a.logistics_company,
        a.logistics_post_back_time,
        null as account_info,
        a.card_no,
        a.apply_image_paths as image_paths,
        a.comment as apply_comment,
        a.create_user_id as user_id,
        a.version,
        'ONLINE_RETURN' as source,
		b.virtual_sku as virtual_sku_cd,
        b.item_sku as return_item_sku_cd,
        b.item_name as return_item_name,
        b.item_type as return_item_type,
        b.sale_price as return_item_sale_price,
        b.apply_sku_flag as return_item_sku_flag,
        b.apply_qty as return_item_qty,
        b.apply_unit_price as return_item_unit_price,
        b.apply_total_price as return_item_total_price,
        b.po_info,
		a.create_time,
        convert(date,a.create_time) as create_date,
        a.update_time,
        convert(date,a.update_time) as update_date,
        current_timestamp as insert_timestamp
    from 
        STG_OMS.Online_Return_Apply_Order a
	left join
	    STG_OMS.Online_Return_Apply_Order_Item b
	on a.online_return_apply_order_sys_id = b.online_return_apply_order_sys_id
)
,return_refund as
(
    select 
        a.oms_refund_apply_order_sys_id as oms_return_apply_order_sys_id,
        b.oms_refund_order_items_sys_id as oms_return_apply_order_item_sys_id,
        null as super_order_id,
        a.oms_order_code as sales_order_number,
        b.oms_order_item_sys_id as sales_order_item_sys_id,
        a.refund_code as return_number,
        a.refund_type as return_type,
        a.refund_reason as return_reason,
        a.process_status,
        a.basic_status,
        a.process_comment,
        null as channel_cd,
        a.actual_delivery_fee,
        a.actual_product_fee,
        a.actual_total_fee,
        a.advice_delivery_fee,
        a.advice_product_fee,
        a.advice_total_fee,
        a.origin_delivery_fee,
        a.shop_pay_delivery_fee_flag,
        a.shop_pay_delivery_fee,
        null as logistics_number,
        null as logistics_company,
        null as logistics_post_back_time,
        null as account_info,
        null as card_no,
        null as image_paths,
        a.comment as apply_comment,
        null as user_id,
        a.version,
        'RETURN_REFUND' as source,
		case when b.barcode like '[VS]%' then b.barcode else null end as virtual_sku_cd, 
        b.sku_code as return_item_sku_cd,
        b.sku_name as return_item_name,
        b.item_type as return_item_type,
        b.sales_price as return_item_sale_price,
        null as return_item_sku_flag,
        b.apply_qty as return_item_qty,
        b.sales_price as return_item_unit_price,
        b.total_price as return_item_total_price,
        null as po_info,
        a.create_time,
        convert(date,a.create_time) as create_date,
        a.last_update_time as update_time,
        convert(date,a.last_update_time) as update_date,
        current_timestamp as insert_timestamp
    from 
	    (select * from STG_OMS.OMS_Refund_Apply_Order where refund_type = 'RETURN_REFUND') a
	left join
	    STG_OMS.OMS_Refund_Order_Items b
    on a.oms_refund_apply_order_sys_id = b.oms_refund_apply_order_sys_id
)

insert into [DW_OMS].[DWS_OMS_Return_Apply_Order]
select
    oms_return_apply_order_sys_id,
    oms_return_apply_order_item_sys_id,
    super_order_id,
    sales_order_number,
    sales_order_item_sys_id,
    return_number,
    return_type,
    return_reason,
    process_status,
    basic_status,
    process_comment,
    channel_cd,
    actual_delivery_fee,
    actual_product_fee,
    actual_total_fee,
    advice_delivery_fee,
    advice_product_fee,
    advice_total_fee,
    origin_delivery_fee,
    shop_pay_delivery_fee_flag,
    shop_pay_delivery_fee,
    logistics_number,
    logistics_company,
    logistics_post_back_time,
    account_info,
    card_no,
    image_paths,
    apply_comment,
    user_id,
    version,
    source,
    virtual_sku_cd,
    return_item_sku_cd,
    return_item_name,
    return_item_type,
    return_item_sale_price,
    return_item_sku_flag,
    return_item_qty,
    return_item_unit_price,
    return_item_total_price,
    po_info,
    create_time,
    create_date,
    update_time,
    update_date,
    insert_timestamp
from
    (
        select * from online_return 
        union all 
        select * from return_refund
    )
    t

END 

GO
