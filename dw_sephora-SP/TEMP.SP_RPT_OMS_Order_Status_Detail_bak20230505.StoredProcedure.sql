/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_Order_Status_Detail_bak20230505]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_Order_Status_Detail_bak20230505] AS
BEGIN
truncate table DW_OMS.RPT_OMS_Order_Status_Detail;
insert into DW_OMS.RPT_OMS_Order_Status_Detail
select
    so.sales_order_number,
	po.purchase_order_number,
	so.store_cd as store_cd,
	so.channel_cd as channel_cd,
	so.province,
	so.city,
	so.district,
	so.is_valid_flag,
	so.is_placed_flag,
	so.type_cd as so_type_cd,
	so.basic_status as so_basic_status_cd,
	so.internal_status as so_internal_status_cd,
	po.type_cd as po_type_cd,
	po.basic_status as po_basic_status_cd,
	po.internal_status as po_internal_status_cd,
	po.split_type as po_split_type_cd,
	so.place_time,
	format(so.place_time,'yyyy-MM-dd') as place_date,
	so.order_time,
	format(so.order_time,'yyyy-MM-dd') as order_date,
	so.payment_status as so_payment_status_cd,
	so.payed_amount as so_payed_amount,
	so.shipping_amount as so_shipping_amount,
	so.product_amount as so_product_amount,
	so.apportion_amount as so_apportion_amount,
	po.apportion_amount as po_apportion_amount,
	so.payment_time as payment_time,
	format(so.payment_time,'yyyy-MM-dd') as payment_date,
	po.order_def_ware_house as order_def_ware_house,
	po.order_actual_ware_house as order_actual_ware_house,
	po.shipping_time as shipping_time,
	format(po.shipping_time,'yyyy-MM-dd') as shipping_date,
	po.sign_time as sign_time,
	format(po.sign_time,'yyyy-MM-dd') as sign_date,
	po.create_time as po_sys_create_time,
	format(po.create_time,'yyyy-MM-dd') as po_sys_create_date,
	po.update_time as po_sys_update_time,
	format(po.update_time,'yyyy-MM-dd') as po_sys_update_date,
    current_timestamp as insert_timestamp	
from 
    (
	select 
		sales_order_number,
		sales_order_sys_id,
		store_cd,
		channel_cd,
		province,
		city,
		district,
		is_valid_flag,
		is_placed_flag,
		type_cd,
		basic_status,
		internal_status,
		place_time,
		order_time,
		payment_status,
		payed_amount,
		shipping_amount,
		product_amount,
		payment_time,
		sum(item_apportion_amount) as apportion_amount
	from 
	    [DW_OMS].[DWS_Sales_Order] 
	group by 
	    sales_order_number,
		sales_order_sys_id,
		store_cd,
		channel_cd,
		province,
		city,
		district,
		is_valid_flag,
		is_placed_flag,
		type_cd,
		basic_status,
		internal_status,
		place_time,
		order_time,
		payment_status,
		payed_amount,
		shipping_amount,
		product_amount,
		payment_time
	) so
	
left join 
    (
	select 
		purchase_order_number,
		sales_order_number,
		sales_order_sys_id,
		type_cd,
		basic_status,
		internal_status,
		split_type,
		order_def_ware_house,
		order_actual_ware_house,
		shipping_time,
		sign_time,
		create_time,
		update_time,
		sum(item_apportion_amount) as apportion_amount
	from 
		[DW_OMS].[DWS_Purchase_Order]
	group by 
	    purchase_order_number,
		sales_order_sys_id,
		sales_order_number,
		type_cd,
		basic_status,
		internal_status,
		split_type,
		order_def_ware_house,
		order_actual_ware_house,
		shipping_time,
		sign_time,
		create_time,
		update_time
	) po
on so.sales_order_sys_id = po.sales_order_sys_id
and so.sales_order_number = po.sales_order_number;

END
GO
