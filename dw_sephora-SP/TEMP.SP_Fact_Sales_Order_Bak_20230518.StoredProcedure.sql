/****** Object:  StoredProcedure [TEMP].[SP_Fact_Sales_Order_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Sales_Order_Bak_20230518] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-12       Tali           Initial Version
-- 2022-12-22       housuangqiang  add O2O
-- 2023-02-24       houshuangqiang  add sub_type_code/payment_amount/item_total_amount/logistics_number/logistics_company
-- 2023-03-16       lizeyuan       add sap_till_number
-- 2023-04-19       houshuangqiang add joint_order_number & add payment_workstation
-- 2023-05-06       zhailonglong   add sys_create_time & add sys_update_time
-- ========================================================================================
truncate table DWD.Fact_Sales_Order;
insert into DWD.Fact_Sales_Order
select
   t.sales_order_number,
   t.joint_order_number,
   t.purchase_order_number,
   t.invoice_id,
   t.channel_code,
   t.channel_name,
   t.sub_channel_code,
   t.sub_channel_name,
   t.store_code,
   t.province,
   t.city,
   t.district,
   t.type_code,
   t.sub_type_code,
   t.member_card,
   t.member_card_grade,
   t.order_status,
   t.order_time,
   t.payment_workstation,
   t.payment_status,
   t.payment_amount,
   t.payment_time,
   t.is_placed,
   t.place_time,
   t.is_smartba,
   t.item_sku_code,
   t.item_sku_name,
   t.item_quantity,
   t.item_sale_price,
   t.item_total_amount,
   t.item_apportion_amount,
   t.item_discount_amount,
   t.item_animation_name,
   t.virtual_sku_code,
   t.virtual_quantity,
   t.virtual_apportion_amount,
   t.virtual_discount_amount,
   t.virtual_bind_quantity,
   t.logistics_company,
   t.logistics_number,
   t.shipping_time,
   t.shipping_amount,
   t.def_warehouse,
   t.actual_warehouse,
   t.pos_sync_time,
   t.pos_sync_status,
   t.sap_till_number,
   t.sap_transaction_number,
   t.sap_quantity,
   t.sap_amount,
   t.sap_store_code,
   t.crm_invc_no,
   t.crm_trans_type,
   t.crm_trans_time,
   t.crm_quantity,
   t.crm_amount,
   t.sys_create_time,
   t.sys_update_time,
   t.source,
   CURRENT_TIMESTAMP
from
(
    -- OMS
    select 	sales_order_number
            ,null as joint_order_number
            ,purchase_order_number
            ,invoice_id
            ,channel_code
            ,channel_name
            ,sub_channel_code
            ,sub_channel_name
            ,store_code
            ,province
            ,city
            ,district
            ,type_code
            ,sub_type_code
            ,member_card
            ,member_card_grade
            ,order_status
            ,order_time
            ,null payment_workstation
            ,payment_status
            ,payment_amount
            ,payment_time
            ,is_placed
            ,place_time
            ,is_smartba
            ,item_sku_code
            ,item_sku_name
            ,item_quantity
            ,item_sale_price
            ,item_total_amount
            ,item_apportion_amount
            ,item_discount_amount
            ,item_animation_name
            ,virtual_sku_code
            ,virtual_quantity
            ,virtual_apportion_amount
            ,virtual_discount_amount
            ,virtual_bind_quantity
            ,logistics_company
            ,logistics_number
            ,shipping_time
            ,shipping_amount
            ,def_warehouse
            ,actual_warehouse
            ,pos_sync_time
            ,pos_sync_status
            ,sap_till_number
            ,sap_transaction_number
            ,sap_quantity
            ,sap_amount
            ,sap_store_code
            ,crm_invc_no
            ,crm_trans_type
            ,crm_trans_time
            ,crm_quantity
            ,crm_amount
            ,sys_create_time
            ,sys_update_time
            ,source
	from 	DWD.Fact_OMS_Sales_Order where order_time >= '2019-01-01'
	-- HUB
    union 	all
	select 	sales_order_number
            ,null as joint_order_number
            ,purchase_order_number
            ,invoice_id
            ,channel_code
            ,channel_name
            ,sub_channel_code
            ,sub_channel_name
            ,store_code
            ,province
            ,city
            ,district
            ,type_code
            ,sub_type_code
            ,member_card
            ,member_card_grade
            ,order_status
            ,order_time
            ,null payment_workstation
            ,payment_status
            ,payment_amount
            ,payment_time
            ,is_placed
            ,place_time
            ,is_smartba
            ,item_sku_code
            ,item_sku_name
            ,item_quantity
            ,item_sale_price
            ,item_total_amount
            ,item_apportion_amount
            ,item_discount_amount
            ,item_animation_name
            ,virtual_sku_code
            ,virtual_quantity
            ,virtual_apportion_amount
            ,virtual_discount_amount
            ,virtual_bind_quantity
            ,logistics_company
            ,logistics_number
            ,shipping_time
            ,shipping_amount
            ,def_warehouse
            ,actual_warehouse
            ,pos_sync_time
            ,pos_sync_status
            ,sap_till_number
            ,sap_transaction_number
            ,sap_quantity
            ,sap_amount
            ,sap_store_code
            ,crm_invc_no
            ,crm_trans_type
            ,crm_trans_time
            ,crm_quantity
            ,crm_amount
            ,sys_create_time
            ,sys_update_time
            ,source
	from 	DWD.Fact_HUB_Sales_Order
    union 	all
    -- POS
	select 	sales_order_number
            ,null as joint_order_number
            ,purchase_order_number
            ,invoice_id
            ,channel_code
            ,channel_name
            ,sub_channel_code
            ,sub_channel_name
            ,store_code
            ,province
            ,city
            ,district
            ,type_code
            ,sub_type_code
            ,member_card
            ,member_card_grade
            ,order_status
            ,order_time
            ,payment_workstation
            ,payment_status
            ,payment_amount
            ,payment_time
            ,is_placed
            ,place_time
            ,is_smartba
            ,item_sku_code
            ,item_sku_name
            ,item_quantity
            ,item_sale_price
            ,item_total_amount
            ,item_apportion_amount
            ,item_discount_amount
            ,item_animation_name
            ,virtual_sku_code
            ,virtual_quantity
            ,virtual_apportion_amount
            ,virtual_discount_amount
            ,virtual_bind_quantity
            ,logistics_company
            ,logistics_number
            ,shipping_time
            ,shipping_amount
            ,def_warehouse
            ,actual_warehouse
            ,pos_sync_time
            ,pos_sync_status
            ,sap_till_number
            ,sap_transaction_number
            ,sap_quantity
            ,sap_amount
            ,sap_store_code
            ,crm_invc_no
            ,crm_trans_type
            ,crm_trans_time
            ,crm_quantity
            ,crm_amount
            ,sys_create_time
            ,sys_update_time
            ,source
	from 	DWD.Fact_POS_Sales_Order
    union 	all
    -- O2O
    select 	sales_order_number
            ,joint_order_number
            ,purchase_order_number
            ,invoice_id
            ,channel_code
            ,channel_name
            ,sub_channel_code
            ,sub_channel_name
            ,store_code
            ,province
            ,city
            ,district
            ,type_code
            ,sub_type_code
            ,member_card
            ,member_card_grade
            ,order_status
            ,order_time
            ,null payment_workstation
            ,payment_status
            ,payment_amount
            ,payment_time
            ,is_placed
            ,place_time
            ,is_smartba
            ,item_sku_code
            ,item_sku_name
            ,item_quantity
            ,item_sale_price
            ,item_total_amount
            ,item_apportion_amount
            ,item_discount_amount
            ,item_animation_name
            ,virtual_sku_code
            ,virtual_quantity
            ,virtual_apportion_amount
            ,virtual_discount_amount
            ,virtual_bind_quantity
            ,logistics_company
            ,logistics_number
            ,shipping_time
            ,shipping_amount
            ,def_warehouse
            ,actual_warehouse
            ,pos_sync_time
            ,pos_sync_status
            ,sap_till_number
            ,sap_transaction_number
            ,sap_quantity
            ,sap_amount
            ,sap_store_code
            ,crm_invc_no
            ,crm_trans_type
            ,crm_trans_time
            ,crm_quantity
            ,crm_amount
            ,sys_create_time
            ,sys_update_time
            ,source
	from 	DWD.Fact_O2O_Sales_Order -- O2O切换门店之后的新数据
) t
;
END
GO
