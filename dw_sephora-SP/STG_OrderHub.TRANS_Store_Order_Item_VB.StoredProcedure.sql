/****** Object:  StoredProcedure [STG_OrderHub].[TRANS_Store_Order_Item_VB]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[TRANS_Store_Order_Item_VB] AS
BEGIN
truncate table STG_OrderHub.Store_Order_Item_VB;
insert into STG_OrderHub.Store_Order_Item_VB
select 
	order_item_vb_sys_id,
	order_item_sys_id,
	case when trim(lower(sku_code)) in ('null','') then null else trim(sku_code) end as sku_code,
	case when trim(lower(upc)) in ('null','') then null else trim(upc) end as upc,
	case when trim(lower(sku_name)) in ('null','') then null else trim(sku_name) end as sku_name,
	case when trim(lower(description)) in ('null','') then null else trim(description) end as description,
	case when trim(lower(main_image)) in ('null','') then null else trim(main_image) end as main_image,
	case when trim(lower(categroy)) in ('null','') then null else trim(categroy) end as categroy,
	case when trim(lower(brand)) in ('null','') then null else trim(brand) end as brand,
	case when trim(lower(spec)) in ('null','') then null else trim(spec) end as spec,
	case when trim(lower(sku_type)) in ('null','') then null else trim(sku_type) end as sku_type,
	quantity,
	list_price,
	original_total,
	price_total,
	invoice_price_total,
	discount_price_total,
	case when trim(lower(unique_id)) in ('null','') then null else trim(unique_id) end as unique_id,
	is_delete,
	create_time,
	update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by order_item_vb_sys_id order by dt desc) rownum from ODS_OrderHub.Store_Order_Item_VB
) t
where rownum = 1
END


GO
