/****** Object:  StoredProcedure [TEMP].[SP_DWS_Store_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Store_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-22       houshuangqiang     New_OMS数据往老的OrderHub.Store_Order中写数据，供下游使用。
-- ========================================================================================
truncate table DW_New_OMS.DWS_Store_Order;
insert  into DW_New_OMS.DWS_Store_Order
select  o.id as store_order_sys_id
		,o.bill_no as order_id
		,o.app_poi_code as app_poi_code
		,o.amount_total as total_amount
		---amount_paid as total_amount
		,o.logistics_status as logistics_status
		,o.pay_date as order_pay_time
		,o.complete_date as logistics_completed_time
		,o.status as order_status
		,o.distribution_state as s_order_status
		,null as commission
		,o.express_fee as delivery_fee
		,ware.code as store_code
		,o.member_card_no as card_code
		,o.original_price as original_price
		,o.invoice_no as invoice_no
		,o.day_seq as day_seq
		,o.remarks as customer_remark
		,o.source_bill_no as sales_order_id
		--,o.related_order_id as related_order_id
		--,o.refund_order_id as refund_order_id
		,null as related_order_id
		,null as refund_order_id
		,o.refund_type as refund_type
		--,o.derived_type as derived_type
		,null as derived_type
		,o.shortage_status as lack_stock_tag
		,o.pick_time as pick_time
		,o.goods_original_total as goods_original_total
		--,o.amount_tag as goods_original_total
		,o.total_tax_amount as goods_paid_total
		--,o.amount_goods as goods_paid_total
		,o.discount_amount as goods_adjustment_total
		,o.channel_id as channel_id
		,0 as is_delete
		,o.is_synt as is_sync
		,o.create_date as create_time
		,o.lastchanged as update_time
		,o.create_by as create_user
		,o.modify_by as update_user
		,current_timestamp as insert_timestamp
from 	stg_new_oms.omni_retail_order_bill o
left 	join STG_IMS.Bas_Warehouse ware
on 		o.warehouse_id = ware.id
END
GO
