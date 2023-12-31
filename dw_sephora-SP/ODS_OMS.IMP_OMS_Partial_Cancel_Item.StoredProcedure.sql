/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Partial_Cancel_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Partial_Cancel_Item] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Partial_Cancel_Item where dt = @dt;
insert into ODS_OMS.OMS_Partial_Cancel_Item
select 
    a.oms_partial_cancel_item_sys_id,
	sales_order_sys_id,
	sales_order_number,
    purchase_order_sys_id,
    purchase_order_number,
	store_id,
	item_quantity,
	item_market_price,
	item_sale_price,
	item_adjustment_unit,
	item_adjustment_total,
	apportion_amount,
	apportion_amount_unit,
	item_sku,
	item_name,
	item_type,
	order_item_source,
	virtual_sku,
	create_time,
	update_time,
	create_op,
	update_op,
	item_dg_quantity,
	item_rg_quantity,
	cancel_flag,
	times_flag,
	cancel_type,
	field1,
	field2,
	presales_date,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_OMS.OMS_Partial_Cancel_Item where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select oms_partial_cancel_item_sys_id from ODS_OMS.WRK_OMS_Partial_Cancel_Item
) b
on a.oms_partial_cancel_item_sys_id = b.oms_partial_cancel_item_sys_id
where b.oms_partial_cancel_item_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Partial_Cancel_Item;
delete from ODS_OMS.OMS_Partial_Cancel_Item where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
