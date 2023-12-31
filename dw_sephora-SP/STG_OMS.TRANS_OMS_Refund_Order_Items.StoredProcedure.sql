/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Refund_Order_Items]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Refund_Order_Items] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_OMS.OMS_Refund_Order_Items;
insert into STG_OMS.OMS_Refund_Order_Items
select 
    oms_refund_order_items_sys_id,
    case when trim(r_oms_order_item_sys_id) in ('null','') then null else trim(r_oms_order_item_sys_id) end as r_oms_order_item_sys_id,
    oms_order_item_sys_id,
    apply_qty,
    case when trim(barcode) in ('null','') then null else trim(barcode) end as barcode,
    create_time,
    list_price,
    qty,
    sales_price,
    total_price,
    item_adjustment,
    total_adjustment,
    case when trim(item_type) in ('null','') then null else trim(item_type) end as item_type,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    case when trim(sku_name) in ('null','') then null else trim(sku_name) end as sku_name,
    case when trim(item_size) in ('null','') then null else trim(item_size) end as item_size,
    case when trim(item_color) in ('null','') then null else trim(item_color) end as item_color,
    item_weight,
    version,
    case when trim(r_oms_refund_apply_order_sys_id) in ('null','') then null else trim(r_oms_refund_apply_order_sys_id) end as r_oms_refund_apply_order_sys_id,
    oms_refund_apply_order_sys_id,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    third_server_amount,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.OMS_Refund_Order_Items 
where dt = @dt
END
GO
