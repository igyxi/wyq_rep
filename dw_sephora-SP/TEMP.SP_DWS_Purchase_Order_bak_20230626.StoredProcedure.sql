/****** Object:  StoredProcedure [TEMP].[SP_DWS_Purchase_Order_bak_20230626]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Purchase_Order_bak_20230626] AS 
begin 
truncate table DW_OMS.DWS_Purchase_Order;
insert into DW_OMS.DWS_Purchase_Order
select
    t.purchase_order_sys_id,
    b.purchase_order_item_sys_id,
    t.purchase_order_number,
    t.purchase_parent_order_number,
    t.related_order_number,
    t.sales_order_sys_id,
    t.sales_order_number,
    t.split_type,
    t.type,
    d.province,
    d.city,
    d.district,
    t.store_id,
    case when t.channel_id = 'TMALL' and t.shop_id = 'TM2' then 'TMALL_WEI' else t.channel_id end as channel_id,
    t.member_id,
    t.member_card,
    t.order_consumer,
    case when t.split_type <> 'SPLIT_ORIGIN'
        and t.type <> 2
        and t.basic_status <> 'DELETED'
        and (
            t.order_internal_status not in ('CANCELLED', 'CANCLED', 'CANNOT_CONTACT', 'CANT_CONTACTED', 'INTERCEPT', 'REJECTED') or
            (t.order_internal_status = 'CANCELLED' and t.basic_status = 'LOCKED')
        ) then 1 else 0 
    end as is_valid_flag,
    t.order_time,
    t.basic_status,
    t.order_internal_status,
    t.order_delivery_type,
    t.shipping_total,
    t.logistics_shipping_company,
    t.logistics_number,
    t.sign_time,
    t.shipping_time,
    t.missing_flag,
    t.mobile,
    t.order_shipping_time,
    t.order_shipping_comment,
    t.seller_order_comment,
    t.payed_amount,
    t.order_def_ware_house,
    t.order_actual_ware_house,
    t.parcel_number,
    t.food_order_flag,
    t.logistics_shipping_time,
    t.super_order_id,
    t.fczp_order_flag,
    t.create_user,
    t.update_user,
    t.is_delete,
    t.deal_type,
    t.shop_id,
    t.ors_coupon_flag,
    t.merge_flag,
    t.presales_sku,
    t.presales_date,
    t.invoice_id,
    t.m50_generated_status,
    t.m50_sync_time,
    t.ors_create_time,
    t.ors_filename,
    t.ors_generated_status,
    t.ors_model,
    t.ors_num,
    t.pos_filename,
    t.pos_sync_status,
    t.pos_sync_time,
    t.store_location_id,
    b.item_quantity,
    b.missing_flag,
    b.item_market_price,
    b.item_sale_price,
    b.item_adjustment_unit,
    b.item_adjustment_total,
    b.apportion_amount_unit,
    b.apportion_amount,
    b.item_sku,
    b.item_name,
    b.item_type,
    b.returned_quantity,
    b.cancel_quantity,
    b.applied_return_quantity,
    b.virtual_sku,
    b.virtual_quantity,
    b.virtual_name,
    b.virtual_amount,
    b.order_actual_ware_house,
    b.deliveried_quantity,
    b.customer_confirmed_quantity,
    b.delivery_flag,
    b.order_item_source,
    b.oid,
    b.process_status,
    t.create_time,
    t.update_time,
    t.version,
    current_timestamp as insert_timestamp
from
(
    select 
        a.*,
        c.invoice_id,
        c.m50_generated_status,
        c.m50_sync_time,
        c.ors_create_time,
        c.ors_filename,
        c.ors_generated_status,
        c.ors_model,
        c.ors_num,
        c.pos_filename,
        c.pos_sync_status,
        c.pos_sync_time,
        c.store_location_id
    from
        STG_OMS.Purchase_Order a
    left join
    (
        select distinct purchase_parent_order_number from STG_OMS.Merge_Order_log
    ) e
    on a.purchase_order_number = e.purchase_parent_order_number
    left join
        STG_OMS.Purchase_To_Sap c
    on a.purchase_order_sys_id = c.purchase_order_sys_id
    where
        e.purchase_parent_order_number is null
) t
left join 
(
    select  
		purchase_order_sys_id,
        province,
        city,
        district
    from 
        STG_OMS.Purchase_Order_Address 
    where 
        basic_status <> 'DELETED'
) d
on t.purchase_order_sys_id = d.purchase_order_sys_id
left join
    STG_OMS.Purchase_Order_Item b
on t.purchase_order_sys_id = b.purchase_order_sys_id
;
UPDATE STATISTICS DW_OMS.DWS_Purchase_Order;
end




GO
