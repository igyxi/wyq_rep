/****** Object:  StoredProcedure [TEMP].[SP_Fact_Hub_Sales_Order_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Hub_Sales_Order_Bak_20230518] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-10       Tali           Initial Version
-- 2023-02-23       housuangqiang  add sub_type_code/payment_amount/item_sale_price/logistics_company/logistics_number
-- 2023-03-16       lizeyuan       add sap_till_number
-- 2023-05-06       zhailonglong   add sys_create_time & add sys_update_time
-- ========================================================================================
truncate table [DWD].[Fact_Hub_Sales_Order];
insert into [DWD].[Fact_Hub_Sales_Order]
select
    so.sales_order_number,
    null as purchase_order_number,
    so.invoice_id,
    so.channel_code,
    so.channel_name,
    so.channel_code as sub_channel_code,
    so.channel_name as sub_channel_name,
    so.store_code,
    so.province,
    so.city,
    so.district,
    1 as type_code,
    null as sub_type_code,
    m.member_card,
    null as member_card_grade,
    so.order_status,
    so.order_time,
    null as payment_status,
    so.payment_amount,
    so.payment_time,
    1 as is_placed,
    so.place_time,
    0 as smartba_flag,
    so.item_sku_code,
    so.item_sku_name,
    so.item_quantity,
    so.item_sale_price,
    so.item_total_amount,
    so.item_apportion_amount,
    so.item_discount_amount,
    a.animation_name,
    null as virtual_sku_code,
    null as virtual_quantity,
    null as virtual_apportion_amount,
    null as virtual_discount_amount,
    null as virtual_bind_quantity,
    null as logistics_company,
    null as logistics_number,
    so.complete_time as shipping_time,
    so.shipping_amount,
    null as def_warehouse,
    null as actual_warehouse,
    null as pos_sync_time,
    null as pos_sync_status,
    sap.till_number as sap_till_number,
    sap.Transaction_Number as sap_transaction_number,
    sap.item_quantity as sap_quantity,
    sap.item_amount as sap_amount,
    sap.Store_Code as sap_store_code,
    crm.invc_no as crm_invc_no,
    crm.trans_type as crm_trans_type,
    crm.order_time as crm_trans_time,
    crm.item_quantity as crm_qty,
    crm.item_apportion_amount as crm_amount,
    so.create_time as sys_create_time,
    so.update_time as sys_update_time,
    'HUB' as source,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    DW_OrderHub.DW_Store_Order_With_SKU so
left join
    DW_SAP.DWS_Sales_Ticket sap
on so.item_sku_code = sap.item_sku_code
and so.store_code = sap.store_code
and so.invoice_id = sap.combine_number
left join
(
    select 
        *
        ,row_number() over(partition by invc_no, store_code, item_sku_code order by sap_time desc, member_card desc) row_num
    from 
        DW_CRM.DWS_Trans_Order_With_SKU
    where 
        order_time >= '2019-01-01'
    and item_quantity >= 0
    and channel_code in ('DIANPING','JDDJ','MEITUAN')
) crm
on so.item_sku_code = crm.item_sku_code
and so.store_code = crm.store_code
and so.invoice_no = crm.invc_no
and so.channel_code = crm.channel_code
and crm.row_num = 1
-- and so.member_card = crm.member_card
left join
    DWD.DIM_Member_Info m
on isnull(so.member_card, crm.member_card) = m.member_card
left join
    DWD.Dim_Animation a
on so.item_sku_code = a.sku_code
and so.place_time between a.Start_Date and a.End_Date
where
    order_status = 8
END
GO
