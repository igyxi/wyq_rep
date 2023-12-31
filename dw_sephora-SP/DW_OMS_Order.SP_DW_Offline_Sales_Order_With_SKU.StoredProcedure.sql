/****** Object:  StoredProcedure [DW_OMS_Order].[SP_DW_Offline_Sales_Order_With_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS_Order].[SP_DW_Offline_Sales_Order_With_SKU] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-15       houshuangqiang     Initial Version
-- ========================================================================================
truncate table DW_OMS_Order.DW_Offline_Sales_Order_With_SKU;
insert 	into DW_OMS_Order.DW_Offline_Sales_Order_With_SKU
select 	null as sales_order_number -- temp_no
		,null as joint_order_number
		,o.retail_order_bill_no as purchase_order_number
		,null as invoice_no
		,null as invoice_id
		--,dict.code as channel_code
		--,dict.name as channel_name
		,'OFF_LINE' as channel_code
		,N'线下' as chanenl_name
		,'GWP001' as sub_channel_code
		,N'线下' as sub_chanenl_name
		,store.code as store_code
		,provice.name as provice
		,city.name as city
		,district.name as district
		,null as type_code -- 待确认
		,null as sub_type_code -- 老OMS中都为NULL
		,null as member_id -- 待确认
		,o.vip_card_no as member_card
		,o.payment_amount
		,null as payment_status
		,1 payment_status
		,null as so_order_status
		,null as po_order_status
		,o.create_date as order_time
		,null as payment_time
		,null as is_placed
		,null as place_time
		,0 as smartba_flag
		,item.item_sku_code
		,item.item_sku_name
		,item.item_quantity
		,item.item_sale_price
		,item.item_apportion_amount
		,item.item_total_amount - item.item_apportion_amount as item_discount_amount
		,vb.virtual_sku_code
		,vb.virtual_quantity
		,vb.virtual_apportion_amount
		,vb.virtual_total_amount - vb.virtual_apportion_amount as virtual_discount_amount
		,delivery.name as logistics_company
		,trim(logistics.delivery_no) as logistics_number
		,logistics.receipt_date as shipping_time -- 如果对不上的话，让写入到 o表中
		,o.freight as shipping_amount
        ,def_warehouse.code as def_warehouse
        ,real_warehouse.code as actual_warehouse
		,null as pos_sync_time
		,null as pos_sync_status
		,null as sys_create_time
		,null as sys_update_time
		,current_timestamp as insert_timestamp
from 	ODS_New_OMS.OMS_Temp_Order_Bill o
left 	join
(
	select 	temp_id
			,sku_code as item_sku_code
			,max(name) as item_sku_name
			,sum(qty) as item_quantity
			,max(price) as item_sale_price
			,sum(price * qty) as item_total_amount
			,max(share_payment) as item_apportion_amount
	from 	ODS_New_OMS.Oms_Temp_Goods_Detail
	group 	by temp_id,sku_code
) item
on 		o.id = item.temp_id
left 	join
(
	select 	temp_id
			,vb_code as virtual_sku_code
			,sum(vb_qty) as virtual_quantity
			,sum(vb_price * vb_qty) as virtual_total_amount
			,sum(share_payment) as virtual_apportion_amount
	from 	ODS_New_OMS.Oms_Temp_Goods_Detail
	group 	by temp_id,vb_code
) vb
on 		o.id = vb.temp_id
left 	join OMS_IMS.Sys_Dict_Detail dict
on 		o.platform_id = dict.id
left 	join ODS_IMS.Bas_Channel store
on 		o.shop_id = store.id
left 	join ODS_OIMS_Support.Bas_Delivery_Type delivery
on 		o.delivery_type_id = delivery.id
left 	join ODS_New_OMS.ORD_Retail_ORD_DIS_Info logistics
on 		o.o.retail_order_bill_no = logistics.bill_no
left 	join Ods_Oims_Support.BAS_Adminarea provice
on 		o.province_id = provice.id
and 	provice.type = '02'
and 	provice.status = '09'
left 	join Ods_Oims_Support.BAS_Adminarea city
on 		o.city_id = city.id
and 	city.type = '03'
and 	city.status = '09'
left 	join Ods_Oims_Support.BAS_Adminarea district
on 		o.district_id = city.id
and 	district.type = '04'
and 	district.status = '09'
left 	join ODS_OIMS_Support.Bas_Warehouse def_warehouse
on      logistics.ware_house_default_id = def_warehouse.id
left    join ODS_OIMS_Support.Bas_Warehouse real_warehouse
on      logistics.ware_house_real_id = real_warehouse.id
END 
;
GO
