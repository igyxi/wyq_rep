/****** Object:  StoredProcedure [STG_OMS].[TRANS_Online_Return_Apply_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Online_Return_Apply_Order_Item] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_OMS.Online_Return_Apply_Order_Item ;
insert into STG_OMS.Online_Return_Apply_Order_Item
select 
    online_return_apply_order_item_sys_id,
    online_return_apply_order_sys_id,
    sales_order_item_sys_id,
    apply_qty,
    create_time,
    sale_price,
    apply_unit_price,
    apply_total_price,
    case when trim(item_type) in ('null','') then null else trim(item_type) end as item_type,
    case when trim(item_sku) in ('null','') then null else trim(item_sku) end as item_sku,
    case when trim(item_name) in ('null','') then null else trim(item_name) end as item_name,
    update_time,
    apply_sku_flag,
    case when trim(virtual_sku) in ('null','') then null else trim(virtual_sku) end as virtual_sku,
    case when trim(po_info) in ('null','') then null else trim(po_info) end as po_info,
    purchase_sale_price,
    purchase_payed_unit_price,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.Online_Return_Apply_Order_Item
where dt = @dt
END
GO
