/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Exchange_Apply_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Exchange_Apply_Order_Item] AS
BEGIN
truncate table STG_OMS.OMS_Exchange_Apply_Order_Item;
insert into STG_OMS.OMS_Exchange_Apply_Order_Item
select 
    oms_exchange_apply_order_item_sys_id,
    r_oms_order_item_sys_id,
    oms_order_item_sys_id,
    case when trim(barcode) in ('null','') then null else trim(barcode) end as barcode,
    create_time,
    item_adjustment,
    case when trim(item_type) in ('null','') then null else trim(item_type) end as item_type,
    list_price,
    r_oms_exchange_apply_order_sys_id,
    oms_exchange_apply_order_sys_id,
    qty,
    sales_price,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    case when trim(sku_name) in ('null','') then null else trim(sku_name) end as sku_name,
    total_adjustment,
    total_price,
    version,
    case when trim(item_size) in ('null','') then null else trim(item_size) end as item_size,
    case when trim(item_color) in ('null','') then null else trim(item_color) end as item_color,
    item_weight,
    case when trim(comment) in ('null','') then null else trim(comment) end as comment,
    case when trim(item_kind) in ('null','') then null else trim(item_kind) end as item_kind,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,	
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(virtual_stkin_flag) in ('null','') then null else trim(virtual_stkin_flag) end as virtual_stkin_flag,
    case when trim(old_sku_code) in ('null','') then null else trim(old_sku_code) end as old_sku_code,	
    current_timestamp as insert_timestamp
from 
(
    select *,row_number() over(partition by oms_exchange_apply_order_item_sys_id order by dt desc) rownum from ODS_OMS.OMS_Exchange_Apply_Order_Item 
) t
where rownum = 1
END


GO
