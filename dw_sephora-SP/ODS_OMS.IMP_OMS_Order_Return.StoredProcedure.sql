/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Order_Return]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Order_Return] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Order_Return where dt = @dt;
insert into ODS_OMS.OMS_Order_Return
select 
    a.oms_order_return_sys_id,
	r_oms_order_return_sys_id,
	oms_member_id,
	sales_order_sys_id,
	r_oms_order_sys_id,
	r_oms_order_stkout_hd_sys_id,
	r_oms_refund_apply_order_sys_id,
	r_oms_exchange_apply_order_sys_id,
	purchase_order_sys_id,
	oms_refund_apply_order_sys_id,
	oms_exchange_apply_order_sys_id,
	oms_order_code,
	source_order_code,
	exchange_new_order_code,
	return_bill_no,
	process_status,
	return_type,
	return_reason,
	return_comments,
	receive_comments,
	field1,
	r_field2,
	field2,
	field3,
	version,
	need_refund,
	confirm_time,
	receive_time,
	create_time,
	update_time,
	create_op,
	update_op,
	basic_status,
	refund_status,
	exchange_status,
	store_id,
	channel_id,
	sync_status,
	refund_invoice_flag,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_OMS.OMS_Order_Return where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select oms_order_return_sys_id from ODS_OMS.WRK_OMS_Order_Return
) b
on a.oms_order_return_sys_id = b.oms_order_return_sys_id
where b.oms_order_return_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Order_Return;
delete from ODS_OMS.OMS_Order_Return where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
