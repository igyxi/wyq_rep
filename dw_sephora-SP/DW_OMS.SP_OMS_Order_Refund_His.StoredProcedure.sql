/****** Object:  StoredProcedure [DW_OMS].[SP_OMS_Order_Refund_His]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_OMS_Order_Refund_His] AS
BEGIN
truncate table dw_oms.oms_order_refund_his
insert  into dw_oms.oms_order_refund_his
select
		refund.online_return_apply_order_sys_id,
		refund.oms_refund_apply_order_sys_id,
		max(refund.oms_order_refund_sys_id) as oms_order_refund_sys_id,
		refund.oms_order_sys_id,
		refund.store_id,
		refund.refund_status,
		refund.refund_type,
		refund.refund_reason,
		max(refund.apply_time) as apply_time,
		max(refund.refund_time) as refund_time,
		sum(refund.refund_sum) as refund_amount,
		sum(refund.product_fee) as product_amount,
		sum(refund.delivery_fee) as delivery_amount,
		refund.product_in_status,
		refund.product_out_status,
		refund.refund_mobile,
		refund.comments as refund_comments,
		refund.oms_order_code as sales_order_number,
		min(refund.return_pos_flag) as return_pos_flag,
		max(refund.create_time) as create_time,
		max(refund.update_time) as update_time,
		refund.is_delete
from    stg_oms.oms_order_refund refund
inner 	join stg_oms.oms_to_oims_sync_fail_log fail
on      refund.oms_order_code = fail.sales_order_number
and     fail.sync_status = 1
--and     fail.update_time >= '2023-05-25 18:39:22'
--and     fail.update_time <= '2023-05-26 00:03:00'
and     fail.update_time >= '2023-05-29 14:00:00'
--and     fail.update_time <= '2023-05-26 00:03:00'
inner 	join stg_oms.purchase_order po
on 		refund.source_order_code = po.purchase_order_number
and 	po.sales_order_number not like '%del%'
inner 	join stg_oms.sales_order so
on 		po.sales_order_sys_id = so.sales_order_sys_id
and 	so.sales_order_number = po.sales_order_number
group by
		refund.online_return_apply_order_sys_id,
		refund.oms_refund_apply_order_sys_id,
		refund.oms_order_sys_id,
		refund.store_id,
		refund.refund_status,
		refund.refund_type,
		refund.refund_reason,
		refund.product_in_status,
		refund.product_out_status,
		refund.refund_mobile,
		refund.comments,
		refund.oms_order_code,
		refund.is_delete
end

GO
