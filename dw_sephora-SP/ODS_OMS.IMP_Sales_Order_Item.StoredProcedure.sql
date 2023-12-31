/****** Object:  StoredProcedure [ODS_OMS].[IMP_Sales_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Sales_Order_Item] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Sales_Order_Item where dt = @dt;
insert into ODS_OMS.Sales_Order_Item
select 
    a.sales_order_item_sys_id,
	sales_order_sys_id,
	r_oms_order_item_sys_id,
	r_oms_order_sys_id,
	item_quantity,
	item_market_price,
	item_sale_price,
	item_adjustment_unit,
	item_adjustment_total,
	apportion_amount,
	apportion_amount_unit,
	item_sku,
	item_name,
	item_description,
	item_brand,
	item_product_id,
	update_time,
	item_type,
	item_size,
	item_color,
	item_weight,
	order_item_source,
	item_category,
	create_time,
	sys_create_time,
	sys_update_time,
	returned_quantity,
	apply_quantity,
	sale_org,
	have_srv_flag,
	task_flag,
	tax_rate,
	adjustment_amount,
	deposit_amount,
	platform_adjustment_amount,
	srv_fee,
	transport_fee,
	gift_card_amount,
	deal_type,
	deal_type_flag,
	promotion_num,
	tmall_oid,
	jd_sku_id,
	item_order_tax_fee,
	item_discount_fee,
	item_sub_order_tax_promotion_fee,
	create_user,
	update_user,
	is_delete,
	presales_date,
	douyin_oid,
	source,
    @dt as dt 
from 
    ODS_OMS.WRK_Sales_Order_Item;
update statistics ODS_OMS.Sales_Order_Item;
END




GO
