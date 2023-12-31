/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Order_Refund]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Order_Refund] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Order_Refund where dt = @dt;
insert into ODS_OMS.OMS_Order_Refund
select 
    oms_order_refund_sys_id,
	oms_order_return_sys_id,
	r_oms_order_return_sys_id,
	order_cancellation_sys_id,
	oms_order_sys_id,
	r_oms_order_sys_id,
	refund_no,
	refund_sum,
	payment_method,
	payment_transaction_id,
	r_field1,
	field1,
	field3,
	field4,
	field5,
	field6,
	r_oms_refund_apply_order_sys_id,
	oms_refund_apply_order_sys_id,
	oms_order_code,
	source_order_code,
	version,
	refund_status,
	refund_op,
	refund_type,
	apply_time,
	refund_time,
	create_op,
	update_op,
	create_time,
	update_time,
	basic_status,
	serivice_note,
	account_number,
	refund_reason,
    convert(varchar(max),HASHBYTES('MD5', refund_mobile),2) as refund_mobile,
	account_name,
	pay_method_order_no,
	financial_remark,
	customer_post_fee,
	seller_post_fee,
	batch_number,
	refund_source,
	pay_time,
	defult_product_fee,
	defult_post_fee,
	defult_sum,
	product_fee,
	delivery_fee,
	exp_indemnity,
	product_in_status,
	product_out_status,
	alipay_account,
	convert(varchar(max),HASHBYTES('SHA2_256', customer_name),2) as customer_name,
	account_bank,
	update_reason,
	store_id,
	channel_id,
	assign_to,
	comments,
	field2,
	related_order_code,
	offline_flag,
	online_return_apply_order_sys_id,
	super_order_id,
	tmall_refund_id,
	is_delete,
	return_pos_flag,
    silk_pay_flag,
    third_refund_id,
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Order_Refund;
truncate table ODS_OMS.WRK_OMS_Order_Refund;
END

GO
