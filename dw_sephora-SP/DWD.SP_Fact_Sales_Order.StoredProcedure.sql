/****** Object:  StoredProcedure [DWD].[SP_Fact_Sales_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Sales_Order] AS
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
-- 2023-05-18       wangzhichun    update OMS/O2O/POS table structure
-- 2023-06-21       houshuangqiang add so_order_status
-- ========================================================================================
truncate table DWD.Fact_Sales_Order;
insert into DWD.Fact_Sales_Order
select
    sales_order_number
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
    ,so_order_status
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
    ,CURRENT_TIMESTAMP as insert_timestamp
from
(
    select 	
        *
	from 	
        DWD.Fact_OMS_Sales_Order
    where order_time >= '2019-01-01'
    union all
	select 
        *
	from 
        DWD.Fact_POS_Sales_Order
    union all
    select 
        *
	from 
        DWD.Fact_O2O_Sales_Order
) t
;
END;
GO
