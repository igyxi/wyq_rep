/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Exchange_Apply_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Exchange_Apply_Order] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Exchange_Apply_Order where dt = @dt;
insert into ODS_OMS.OMS_Exchange_Apply_Order
select 
    a.oms_exchange_apply_order_sys_id,
	r_oms_exchange_apply_order_sys_id,
	basic_status,
	process_comment,
	comment,
	create_op,
	create_time,
	customer_id,
	exchange_no,
	exchange_reason,
	oms_order_code,
	order_status,
	process_status,
	source_order_code,
	update_op,
	update_time,
	store_id,
	channel_id,
	version,
	oms_warehouse_id,
	is_delete,
    sap_exchange_number,
    @dt as dt
from 
(
    select * from ODS_OMS.OMS_Exchange_Apply_Order where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select oms_exchange_apply_order_sys_id from ODS_OMS.WRK_OMS_Exchange_Apply_Order
) b
on a.oms_exchange_apply_order_sys_id = b.oms_exchange_apply_order_sys_id
where b.oms_exchange_apply_order_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Exchange_Apply_Order;
delete from ODS_OMS.OMS_Exchange_Apply_Order where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
