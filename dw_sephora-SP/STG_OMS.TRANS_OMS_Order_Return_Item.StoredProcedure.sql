/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Order_Return_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Order_Return_Item] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_OMS.OMS_Order_Return_Item ;
insert into STG_OMS.OMS_Order_Return_Item
select 
    oms_order_return_item_sys_id,
    r_oms_order_return_item_sys_id,
    oms_order_return_sys_id,
    r_oms_order_return_sys_id,
    oms_order_item_sys_id,
    r_oms_order_item_sys_id,
    sales_price,
    list_price,
    item_quantity,
    good_quantity,
    def_quantity,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,
    version,
    case when trim(item_receive_comment) in ('null','') then null else trim(item_receive_comment) end as item_receive_comment,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    create_time,
    update_time,
    case when trim(item_sku) in ('null','') then null else trim(item_sku) end as item_sku,
    case when trim(barcode) in ('null','') then null else trim(barcode) end as barcode,
    case when trim(item_name) in ('null','') then null else trim(item_name) end as item_name,
    case when trim(item_description) in ('null','') then null else trim(item_description) end as item_description,
    case when trim(item_type) in ('null','') then null else trim(item_type) end as item_type,
    case when trim(item_kind) in ('null','') then null else trim(item_kind) end as item_kind,
    item_weight,
    case when trim(item_size) in ('null','') then null else trim(item_size) end as item_size,
    case when trim(item_color) in ('null','') then null else trim(item_color) end as item_color,
    returned_quantity,
    case when trim(exchange_sku) in ('null','') then null else trim(exchange_sku) end as exchange_sku,
    exchange_qty,
    is_delete,
    case when trim(virtual_stkin_flag) in ('null','') then null else trim(virtual_stkin_flag) end as virtual_stkin_flag,
    case when trim(old_sku_code) in ('null','') then null else trim(old_sku_code) end as old_sku_code,
    third_server_amount,
    oms_refund_order_items_sys_id,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.OMS_Order_Return_Item 
where dt = @dt
END
GO
