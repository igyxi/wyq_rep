/****** Object:  StoredProcedure [ODS_OMS].[IMP_Purchase_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Purchase_Order] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Purchase_Order where dt = @dt;
insert into ODS_OMS.Purchase_Order
select 
    purchase_order_sys_id,
	r_oms_stkout_hd_sys_id,
	store_id,
	channel_id,
	member_id,
	member_card,
	order_consumer,
	purchase_order_number,
	sales_order_number,
	related_order_number,
	order_time,
	order_internal_status,
	type,
	order_delivery_type,
	shipping_total,
	logistics_shipping_company,
	logistics_number,
	sign_time,
	shipping_time,
	missing_flag,
    convert(varchar(max),HASHBYTES('MD5', mobile),2) as mobile,
	order_shipping_time,
	create_time,
	update_time,
	order_shipping_comment,
	seller_order_comment,
	payed_amount,
	basic_status,
	order_def_ware_house,
	cancel_time,
	cancel_reason,
	cancel_comment,
	purchase_parent_order_number,
	order_actual_ware_house,
	version,
	split_type,
	r_oms_order_sys_id,
	sales_order_sys_id,
	parcel_number,
	r_field3,
	food_order_flag,
	logistics_shipping_time,
	sys_create_time,
	sys_update_time,
	super_order_id,
	fczp_order_flag,
	create_user,
	update_user,
	is_delete,
	deal_type,
	shop_id,
	ors_coupon_flag,
	merge_flag,
	presales_sku,
	presales_date,
    smartba_flag,
	activity_id,
    joint_order_number,
	ware_house_code,
    pending_comment,
	secondary_order_type,
	split_method,
    @dt as dt
from 
   ODS_OMS.WRK_Purchase_Order;
truncate table ODS_OMS.WRK_Purchase_Order;
END

GO
