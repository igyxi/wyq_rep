/****** Object:  StoredProcedure [TEMP].[SP_Fact_Sales_Order_Bak20220920]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Sales_Order_Bak20220920] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-12       Tali           Initial Version
-- 2022-01-27       tali           delete collate
-- 2022-02-10       Tali           change SAP_COMBINE_KEY to SAP_Transaction_Number
-- 2022-02-21       Tali           add Hdr_szTaCreatedDate as order_time
-- 2022-02-21       Tali           add country filter condition for sap
-- 2022-02-23       Tali           set member_card from dimaccount
-- 2022-02-23       Tali           change order hub logic
-- 2022-03-02       Tali           change the logic
-- 2022-03-15       Tali           change the logic
-- 2022-03-18       Tali           change the crm and pos channel_code
-- 2022-03-29       tali           add store_code for sap logic
-- 2022-04-19       Tali           add crm_trans_type and crm_trans_time 
-- 2022-04-20       Tali           change crm and hub join logic
-- 2022-05-02       Tali           add oms coupon
-- 2022-05-19       Tali           add district
-- 2022-05-25       Tali           replace member_card null value with crm
-- 2022-05-25       Tali           add channel_name and sub_channel_name for hub and pos
-- 2022-05-26       Tali           change crm join logic
-- 2022-05-31       tali           add smartba_flag and animation_name
-- 2022-06-22       Tali           fix pos city/province
-- 2022-06-29       Tali           fix pos ticket_date
-- 2022-07-09       Tali           fix oms gwp and hub sku
-- 2022-07-14       Tali           add purchase_order_number is not null 
-- 2022-07-18       Tali           change  DWS_Store_Order_With_SKU/DWS_POS_Order_With_SKU/DWS_Sales_Ticket
-- 2022-07-27       Tali           add district for pos and hub
-- 2022-09-05       Tali           change oms filter
-- 2022-09-15       Tali           split the query to 3
-- ========================================================================================
truncate table DWD.Fact_Sales_Order;
insert into DWD.Fact_Sales_Order
select 
    t.sales_order_number,
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
    t.member_card,
    t.member_card_grade,
    t.order_status,
    t.order_time,
    t.payment_status,
    t.payment_time,
    t.is_placed,
    t.place_time,
    t.is_smartba,
    t.item_sku_code,
    t.item_sku_name,
    t.item_quantity,
    t.item_sale_price,
    t.item_apportion_amount,
    t.item_discount_amount,
    t.item_animation_name,
    t.virtual_sku_code,
    t.virtual_quantity,
    t.virtual_apportion_amount,
    t.virtual_discount_amount,
    t.virtual_bind_quantity,
    t.shipping_time,
    t.shipping_amount,
    t.def_warehouse,
    t.actual_warehouse,
    t.pos_sync_time,
    t.pos_sync_status,
    t.sap_transaction_number,
    t.sap_quantity,
    t.sap_amount,
    t.sap_store_code,
    t.crm_invc_no,
    t.crm_trans_type,
    t.crm_trans_time,
    t.crm_quantity,
    t.crm_amount,
    t.source,
    CURRENT_TIMESTAMP
from
(
    select
        * 
    from 
        DWD.Fact_OMS_Sales_Order
    where
        order_time > '2019-01-01'
    UNION ALL
    select 
        * 
    from 
        DWD.Fact_POS_Sales_Order
    UNION ALL
    select 
        * 
    from 
        DWD.Fact_HUB_Sales_Order
) t
;
END
GO
