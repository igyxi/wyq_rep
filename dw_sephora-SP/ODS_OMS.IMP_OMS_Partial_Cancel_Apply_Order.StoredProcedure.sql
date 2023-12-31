/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Partial_Cancel_Apply_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Partial_Cancel_Apply_Order] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Partial_Cancel_Apply_Order where dt = @dt;
insert into ODS_OMS.OMS_Partial_Cancel_Apply_Order
select 
    a.oms_partial_cancel_apply_order_sys_id,
 sales_order_sys_id,
 sales_order_number,
 purchase_order_number,
 related_order_number,
 purchase_order_sys_id,
 store_id,
 type,
 cancel_amount,
 cancel_reason,
 cancel_comments,
 cancel_status,
 cancel_time,
 times_flag,
 cancel_type,
 create_time,
 update_time,
 create_op,
 update_op,
 field1,
 field2,
 is_delete,
 general_process_flag,
 origin_order_internal_status,
 tmall_refund_id,
    @dt as dt
from 
(
    select * from ODS_OMS.OMS_Partial_Cancel_Apply_Order where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select oms_partial_cancel_apply_order_sys_id from ODS_OMS.WRK_OMS_Partial_Cancel_Apply_Order
) b
on a.oms_partial_cancel_apply_order_sys_id = b.oms_partial_cancel_apply_order_sys_id
where b.oms_partial_cancel_apply_order_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Partial_Cancel_Apply_Order;
delete from ODS_OMS.OMS_Partial_Cancel_Apply_Order where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
