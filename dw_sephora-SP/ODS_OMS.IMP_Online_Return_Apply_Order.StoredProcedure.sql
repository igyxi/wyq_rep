/****** Object:  StoredProcedure [ODS_OMS].[IMP_Online_Return_Apply_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Online_Return_Apply_Order] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Online_Return_Apply_Order where dt = @dt;
insert into ODS_OMS.Online_Return_Apply_Order
select 
    online_return_apply_order_sys_id,
	super_order_id,
	return_number,
	convert(varchar(max),HASHBYTES('SHA2_256',account_info),2) as account_info,
	actual_delivery_fee,
	actual_product_fee,
	actual_total_fee,
	advice_delivery_fee,
	advice_product_fee,
	advice_total_fee,
	origin_delivery_fee,
	shop_pay_delivery_fee,
	basic_status,
	order_status,
	comment,
	create_nick_name,
	create_user_id,
	create_time,
	logistics_number,
	logistics_company,
    convert(varchar(max),HASHBYTES('MD5', mobile),2) as mobile,
	card_no,
	update_nick_name,
	update_time,
	sales_order_number,
	return_reason,
	return_type,
	process_status,
	process_comment,
	apply_image_paths,
	store_id,
	channel_id,
	apply_channel_id,
	shop_pay_delivery_fee_flag,
	warehouse_status,
	version,
	logistics_post_back_time,
	create_user,
	update_user,
	is_delete,
	virtual_stkin_flag,
	is_return_express_fee,
	shop_id,
	purchase_order_number,
	tmall_refund_id,
    return_warehouse_id,
    third_refund_id,
    @dt as dt
from 
    ODS_OMS.WRK_Online_Return_Apply_Order;
truncate table ODS_OMS.WRK_Online_Return_Apply_Order;
END


GO
