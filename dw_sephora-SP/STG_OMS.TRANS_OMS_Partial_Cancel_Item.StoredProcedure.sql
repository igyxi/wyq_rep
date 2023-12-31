/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Partial_Cancel_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Partial_Cancel_Item] AS
BEGIN
truncate table STG_OMS.OMS_Partial_Cancel_Item;
insert into STG_OMS.OMS_Partial_Cancel_Item
select 
    oms_partial_cancel_item_sys_id,
    sales_order_sys_id,
    case when trim(sales_order_number) in ('null','') then null else trim(sales_order_number) end as sales_order_number,	
    purchase_order_sys_id,
    case when trim(purchase_order_number) in ('null','') then null else trim(purchase_order_number) end as purchase_order_number,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    item_quantity,
    item_market_price,
    item_sale_price,
    item_adjustment_unit,
    item_adjustment_total,
    apportion_amount,
    apportion_amount_unit,
    case when trim(item_sku) in ('null','') then null else trim(item_sku) end as item_sku,
    case when trim(item_name) in ('null','') then null else trim(item_name) end as item_name,
    case when trim(item_type) in ('null','') then null else trim(item_type) end as item_type,
    case when trim(order_item_source) in ('null','') then null else trim(order_item_source) end as order_item_source, 
    case when trim(virtual_sku) in ('null','') then null else trim(virtual_sku) end as virtual_sku,
    create_time,
    update_time,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    item_dg_quantity,
    item_rg_quantity,
    cancel_flag,
    times_flag,
    cancel_type,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,
    presales_date,
    is_delete,
    case when trim(refund_id) in ('null','') then null else trim(refund_id) end as refund_id,
    case when trim(third_refund_id) in ('null','') then null else trim(third_refund_id) end as third_refund_id,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_partial_cancel_item_sys_id order by dt desc) rownum from ODS_OMS.OMS_Partial_Cancel_Item
) t
where rownum = 1
END


GO
