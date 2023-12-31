/****** Object:  StoredProcedure [TEMP].[SP_OMS_Order_Refund_His]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_OMS_Order_Refund_His] AS
BEGIN
truncate table dw_oms.oms_order_refund_his
insert  into dw_oms.oms_order_refund_his
select
		online_return_apply_order_sys_id,
		oms_refund_apply_order_sys_id,
		max(oms_order_refund_sys_id) as oms_order_refund_sys_id,
		oms_order_sys_id,
		store_id,
		refund_status,
		refund_type,
		refund_reason,
		max(apply_time) as apply_time,
		max(refund_time) as refund_time,
		sum(refund_sum) as refund_amount,
		sum(product_fee) as product_amount,
		sum(delivery_fee) as delivery_amount,
		product_in_status,
		product_out_status,
		refund_mobile,
		comments,
		oms_order_code,
		min(return_pos_flag) as return_pos_flag,
		max(create_time) as create_time,
		max(update_time) as update_time,
		is_delete
from    stg_oms.oms_order_refund
left 	join stg_oms.oms_to_oims_sync_fail_log fail
on      a.oms_order_code = fail.sales_order_number
and     fail.sync_status = 1
and     fail.update_time >= '2023-05-25 18:39:22'
and     fail.update_time <= '2023-05-26 00:03:00'
group by
		online_return_apply_order_sys_id,
		oms_refund_apply_order_sys_id,
		oms_order_sys_id,
		store_id,
		refund_status,
		refund_type,
		refund_reason,
		product_in_status,
		product_out_status,
		refund_mobile,
		comments,
		oms_order_code,
		is_delete
end 
GO
