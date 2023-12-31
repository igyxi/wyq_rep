/****** Object:  StoredProcedure [STG_OMS].[TRANS_Online_Stkin_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Online_Stkin_Order_Item] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_OMS.Online_Stkin_Order_Item;
insert into STG_OMS.Online_Stkin_Order_Item
select 
    online_stkin_order_item_sys_id,
    online_stkin_order_sys_id,
    case when trim(item_sku) in ('null','') then null else trim(item_sku) end as item_sku,
    case when trim(item_name) in ('null','') then null else trim(item_name) end as item_name,
    item_quantity,
    case when trim(item_type) in ('null','') then null else trim(item_type) end as item_type,
    intact_quantity,
    loss_quantity,
    apply_sku_flag,
    case when trim(virtual_sku) in ('null','') then null else trim(virtual_sku) end as virtual_sku,
    case when trim(po_info) in ('null','') then null else trim(po_info) end as po_info,
    wrong_sku_flag,
    case when trim(loss_remark) in ('null','') then null else trim(loss_remark) end as loss_remark,
    apply_unit_price,
    sale_price,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    create_time,
    update_time,
    refund_quantity,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.Online_Stkin_Order_Item
where dt = @dt
END
GO
