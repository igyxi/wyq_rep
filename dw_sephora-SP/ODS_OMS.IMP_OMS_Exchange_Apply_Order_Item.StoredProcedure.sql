/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Exchange_Apply_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Exchange_Apply_Order_Item] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Exchange_Apply_Order_Item where dt = @dt;
insert into ODS_OMS.OMS_Exchange_Apply_Order_Item
select 
    a.oms_exchange_apply_order_item_sys_id,
	r_oms_order_item_sys_id,
	oms_order_item_sys_id,
	barcode,
	create_time,
	item_adjustment,
	item_type,
	list_price,
	r_oms_exchange_apply_order_sys_id,
	oms_exchange_apply_order_sys_id,
	qty,
	sales_price,
	sku_code,
	sku_name,
	total_adjustment,
	total_price,
	version,
	item_size,
	item_color,
	item_weight,
	comment,
	item_kind,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_OMS.OMS_Exchange_Apply_Order_Item where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select oms_exchange_apply_order_item_sys_id from ODS_OMS.WRK_OMS_Exchange_Apply_Order_Item
) b
on a.oms_exchange_apply_order_item_sys_id = b.oms_exchange_apply_order_item_sys_id
where b.oms_exchange_apply_order_item_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Exchange_Apply_Order_Item;
delete from ODS_OMS.OMS_Exchange_Apply_Order_Item where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
