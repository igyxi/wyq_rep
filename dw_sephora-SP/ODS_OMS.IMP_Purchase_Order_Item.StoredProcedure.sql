/****** Object:  StoredProcedure [ODS_OMS].[IMP_Purchase_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Purchase_Order_Item] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Purchase_Order_Item where dt = @dt;
insert into ODS_OMS.Purchase_Order_Item
select 
    a.purchase_order_item_sys_id,
	r_oms_stkout_hd_sys_id,
	purchase_order_sys_id,
	item_quantity,
	missing_flag,
	item_market_price,
	item_sale_price,
	item_adjustment_unit,
	item_adjustment_total,
	apportion_amount,
	apportion_amount_unit,
	item_sku,
	item_name,
	create_op,
	update_op,
	create_time,
	item_type,
	returned_quantity,
	cancel_quantity,
	applied_return_quantity,
	virtual_sku,
	virtual_quantity,
	virtual_name,
	virtual_amount,
	order_actual_ware_house,
	deliveried_quantity,
	customer_confirmed_quantity,
	delivery_flag,
	order_item_source,
	update_time,
	process_status,
	item_size,
	sys_create_time,
	sys_update_time,
	is_delete,
	oid,
	stock_flag,
	presales_sku,
	presales_date,
	douyin_oid,
    @dt as dt 
from 
    ODS_OMS.WRK_Purchase_Order_Item;
update statistics ODS_OMS.Purchase_Order_Item;
END



GO
