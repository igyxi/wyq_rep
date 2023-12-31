/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Stkin_HD]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Stkin_HD] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Stkin_HD where dt = @dt;
insert into ODS_OMS.OMS_Stkin_HD
select 
    a.oms_stkin_hd_sys_id,
	r_oms_stkin_sys_id,
	r_oms_order_return_sys_id,
	oms_order_return_sys_id,
	store_id,
	channel_id,
	returner_name,
	oms_order_code,
	source_order_code,
	oms_stkin_no,
	stkin_rtn_orders,
	stkin_remark,
	create_op,
	update_op,
	create_time,
	update_time,
	receive_time,
	field1,
	field2,
	field5,
	process_status,
	basic_status,
	version,
	sync_status,
	oms_stkin_type,
	return_shipping_mtd,
	return_tracking_no,
	post_fee,
	who_pay_post,
	stkin_invoice_flag,
	is_delete,
	ware_house_code,
    @dt as dt
from 
(
    select * from ODS_OMS.OMS_Stkin_HD where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select oms_stkin_hd_sys_id from ODS_OMS.WRK_OMS_Stkin_HD
) b
on a.oms_stkin_hd_sys_id = b.oms_stkin_hd_sys_id
where b.oms_stkin_hd_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Stkin_HD;
delete from ODS_OMS.OMS_Stkin_HD where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
