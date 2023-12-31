/****** Object:  StoredProcedure [STG_OrderHub].[TRANS_Refund_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[TRANS_Refund_Order_Item] AS
BEGIN
truncate table STG_OrderHub.Refund_Order_Item;
insert into STG_OrderHub.Refund_Order_Item
select 
    refund_order_item_sys_id,
    refund_order_sys_id,
    case when trim(lower(app_food_code)) in ('null','') then null else trim(app_food_code) end as app_food_code,
    case when trim(lower(sku_code)) in ('null','') then null else trim(sku_code) end as sku_code,
    case when trim(lower(sku_name)) in ('null','') then null else trim(sku_name) end as sku_name,
    quantity,
    case when trim(lower(upc)) in ('null','') then null else trim(upc) end as upc,
    price,
    origin_price,
    refund_price,
    refund_price_total,
	refund_invoice_total,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by refund_order_item_sys_id order by dt desc) rownum from ODS_OrderHub.Refund_Order_Item
) t
where rownum = 1
END


GO
