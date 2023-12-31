/****** Object:  StoredProcedure [STG_OMS].[TRANS_Purchase_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Purchase_Order_Item] AS
BEGIN
truncate table STG_OMS.Purchase_Order_Item;
insert into STG_OMS.Purchase_Order_Item
select 
    purchase_order_item_sys_id,
    case when trim(lower(r_oms_stkout_hd_sys_id)) in ('null', '') then null else trim(r_oms_stkout_hd_sys_id) end as r_oms_stkout_hd_sys_id,
    purchase_order_sys_id,
    item_quantity,
    missing_flag,
    item_market_price,
    item_sale_price,
    item_adjustment_unit,
    item_adjustment_total,
    apportion_amount,
    apportion_amount_unit,
    case when trim(lower(item_sku)) in ('null', '') then null else trim(item_sku) end as item_sku,
    case when trim(lower(item_name)) in ('null', '') then null else trim(item_name) end as item_name,
    case when trim(lower(create_op)) in ('null', '') then null else trim(create_op) end as create_op,
    case when trim(lower(update_op)) in ('null', '') then null else trim(update_op) end as update_op,
    create_time,
    case 
        when trim(lower(item_type)) in ('null', '') then null 
        when trim(item_type) = N'正常商品' then 'NORMAL'
        else trim(item_type)
    end as item_type,
    returned_quantity,
    cancel_quantity,
    applied_return_quantity,
    case when trim(lower(virtual_sku)) in ('null', '') then null else trim(virtual_sku) end as virtual_sku,
    virtual_quantity,
    case when trim(lower(virtual_name)) in ('null', '') then null else trim(virtual_name) end as virtual_name,
    virtual_amount,
    case when trim(lower(order_actual_ware_house)) in ('null', '') then null else trim(order_actual_ware_house) end as order_actual_ware_house,
    deliveried_quantity,
    customer_confirmed_quantity,
    delivery_flag,
    case when trim(lower(order_item_source)) in ('null', '') then null else trim(order_item_source) end as order_item_source,
    update_time,
    process_status,
    case when trim(lower(item_size)) in ('null', '') then null else trim(item_size) end as item_size,
    sys_create_time,
    sys_update_time,
    is_delete,
    case when trim(lower(oid)) in ('null', '') then null else trim(oid) end as oid,
    stock_flag,
    case when trim(lower(presales_sku)) in ('null', '') then null else trim(presales_sku) end as presales_sku,
    presales_date,
    case when trim(douyin_oid) in ('null', '') then null else trim(douyin_oid) end as douyin_oid,
    case when trim(third_oid) in ('null', '') then null else trim(third_oid) end as third_oid,
    case when trim(third_server_rate) in ('null', '') then null else trim(third_server_rate) end as third_server_rate,
    third_server_amount,
    case when trim(activity_id) in ('null', '') then null else trim(activity_id) end as activity_id,
    case when trim(activity_type) in ('null', '') then null else trim(activity_type) end as activity_type,
    activity_item_quantity,
    current_timestamp as insert_timestamp
from 
(
    select *, ROW_NUMBER() over(partition by purchase_order_sys_id, purchase_order_item_sys_id order by dt desc) rownum from ODS_OMS.Purchase_Order_Item
) t
where rownum = 1
END


GO
