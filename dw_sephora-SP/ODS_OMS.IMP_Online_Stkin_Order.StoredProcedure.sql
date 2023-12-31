/****** Object:  StoredProcedure [ODS_OMS].[IMP_Online_Stkin_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Online_Stkin_Order] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Online_Stkin_Order where dt = @dt;
insert into ODS_OMS.Online_Stkin_Order
select 
    online_stkin_order_sys_id,
	sales_order_number,
	logistics_number,
	logistics_company,
    convert(varchar(max),HASHBYTES('MD5', mobile),2) as mobile,
	return_sku_quantity,
	return_sku_packages,
	apply_logistics_fee,
	stkin_order_number,
	process_status,
	basic_status,
	post_fee,
	stkin_invoice_flag,
	partial_stkin_reason,
	comment,
	stkin_type,
	create_op,
	update_op,
	create_time,
	update_time,
	online_return_apply_order_sys_id,
	super_order_id,
	return_exchange_type,
	logistics_post_back_time,
	stkin_exception_type,
	stkin_exception_refund_type,
	resend_flag,
	purchase_order_numbers,
	order_ware_house,
	virtual_stkin_flag,
	stkin_trouble,
	store_id,
	channel_id,
	logistics_sign_time,
    @dt as dt
from 
    ODS_OMS.WRK_Online_Stkin_Order;
truncate table ODS_OMS.WRK_Online_Stkin_Order;
END



GO
