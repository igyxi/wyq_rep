/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Refund_Apply_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Refund_Apply_Order] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Refund_Apply_Order where dt = @dt;
insert into ODS_OMS.OMS_Refund_Apply_Order
select 
    a.oms_refund_apply_order_sys_id,
	r_oms_refund_apply_order_sys_id,
	actual_delivery_fee,
	actual_product_fee,
	actual_total_fee,
	advice_delivery_fee,
	advice_product_fee,
	advice_total_fee,
	origin_delivery_fee,
	customer_pay_delivery_fee,
	shop_pay_delivery_fee,
	final_total_fee,
	advice_shop_stkin_delivery_fee,
	basic_status,
	order_status,
	comment,
	create_op,
	create_time,
	customer_id,
	last_update_op,
	last_update_time,
	oms_order_code,
	source_order_code,
	refund_code,
	refund_reason,
	refund_type,
	process_status,
	account_name,
	bank_name,
	bank_account,
	store_id,
	channel_id,
	process_comment,
	r_is_shop_pay_delivery_fee,
	shop_pay_delivery_fee_flag,
	version,
	return_wh,
	from_type,
	mms_flag,
	tmall_refund_id,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_OMS.OMS_Refund_Apply_Order where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select oms_refund_apply_order_sys_id from ODS_OMS.WRK_OMS_Refund_Apply_Order
) b
on a.oms_refund_apply_order_sys_id = b.oms_refund_apply_order_sys_id
where b.oms_refund_apply_order_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Refund_Apply_Order;
delete from ODS_OMS.OMS_Refund_Apply_Order where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
