/****** Object:  StoredProcedure [TEMP].[SP_DWS_Refund_Order_Item]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Refund_Order_Item] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-26       houshuangqiang     New_OMS数据往老的OrderHub.Refund_Order_Item中写数据，供下游使用。
-- ========================================================================================
truncate table DW_New_OMS.DWS_Refund_Order_Item;
insert into DW_New_OMS.DWS_Refund_Order_Item
select  cancel.id as refund_order_item_sys_id
		,cancel.refund_apply_bill_id as refund_order_sys_id
        ,coalesce(cancel.vb_app_food_code,cancel.app_food_code) as app_food_code
		-- ,cancel.app_food_code as sku_code
        ,sku.code as sku_code
		,sku.name as sku_name
		,cancel.qty as quantity
		,cancel.upc as upc
		,cancel.price as price
		,cancel.origin_price as origin_price
		,cancel.refund_price as refund_price
		,cancel.refund_price_total as refund_price_total
		,cancel.refund_invoice_total as refund_invoice_total
		,'CANCELED' as order_ype
		,cancel.create_time as create_time
		,cancel.modify_time as update_time
		,cancel.create_by as create_user
		,cancel.modify_by as update_user
		,[cancel].is_synt as is_sync
		,0 as is_delete
		,current_timestamp as insert_timestamp
from 	STG_New_Oms.Omni_Refund_Apply_Item cancel
left    join STG_IMS.gds_btsinglprodu sku
on      cancel.sku_id = sku.id
-- left 	join DWD.DIM_SKU_INFO sku
-- on 		cancel.app_food_code = sku.sku_code
union   all
select 	item.id as refund_order_item_sys_id
		,item.return_bill_id as refund_order_sys_id
		,item.app_food_code as app_food_code
		-- ,item.sku as sku_code
--		,[return].good_id as sku_name
        -- ,sku.eb_sku_name_cn as sku_name
        ,sku.code as sku_code
        ,sku.name as sku_name
		,item.qty as quantity
		,item.barcode as upc
		,item.average_price as price
		,item.shop_price as origin_price
		,item.average_price as refund_price
		,item.payed_amount as refund_price_total
		,item.paid_amount as refund_invoice_total
		,'RETURNED' as order_ype
		,[return].create_date as create_time
		,[return].modify_date as update_time
		,[return].create_by as create_user
		,[return].modify_by as update_user
		,[item].is_synt as is_sync
		,0 as is_delete
		,current_timestamp as insert_timestamp
from 	STG_New_OMS.Omni_Retail_Return_Gds_De item
left 	join STG_New_OMS.OMNI_Retail_Return_Bill [return]
on 		item.return_bill_id = [return].id
left    join STG_IMS.gds_btsinglprodu sku
on 		item.single_product_id = sku.id
-- left    join DWD.DIM_SKU_Info sku
-- on      item.sku = sku.sku_code

END
GO
