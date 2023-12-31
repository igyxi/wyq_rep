/****** Object:  StoredProcedure [STG_OrderHub].[TRANS_Order_Invoice_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[TRANS_Order_Invoice_Item] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-04       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_OrderHub.Order_Invoice_Item;
insert into STG_OrderHub.Order_Invoice_Item
select 
		order_invoice_item_sys_id,
		order_invoice_sys_id,
		case when trim(sku_code) in ('','null') then null else trim(sku_code) end as sku_code,
		case when trim(upc) in ('','null') then null else trim(upc) end as upc,
		case when trim(sku_name) in ('','null') then null else trim(sku_name) end as sku_name,
		case when trim(description) in ('','null') then null else trim(description) end as description,
		quantity,
		list_price,
		original_total,
		price_total,
		invoice_price_total,
		discount_price_total,
		is_delete,
		create_time,
		update_time,
		case when trim(create_user) in ('','null') then null else trim(create_user) end as create_user,
		case when trim(update_user) in ('','null') then null else trim(update_user) end as update_user,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by order_invoice_item_sys_id order by dt desc) rownum from ODS_OrderHub.Order_Invoice_Item
) t
where rownum = 1
END
GO
