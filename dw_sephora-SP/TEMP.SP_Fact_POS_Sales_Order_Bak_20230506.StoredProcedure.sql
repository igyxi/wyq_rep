/****** Object:  StoredProcedure [TEMP].[SP_Fact_POS_Sales_Order_Bak_20230506]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_POS_Sales_Order_Bak_20230506] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-09       tali           ini
-- 2023-02-24       housuangqiang  add sub_type_code/payment_amount/item_sale_price/logistics_company/logistics_number
-- 2023-03-16       lizeyuan       add sap_till_number
-- 2023-04-19       houshuangqiang add payment_workstation
-- ========================================================================================
truncate table DWD.Fact_POS_Sales_Order;
insert into DWD.Fact_POS_Sales_Order
select
    so.barcode as sales_order_number,
    null as purchase_order_number,
    so.invoice_id as invoice_id,
    'OFF_LINE' as channel_code,
    N'线下' as channel_name,
    'OFF_LINE' as sub_channel_code,
    N'线下' as sub_channel_name,
    so.store_code,
    isnull(so.province, b.crm_province) as province,
    isnull(so.city, b.crm_city) as city,
    so.district,
    1 as type_code,
    null as sub_type_code,
    m.member_card,
    so.member_card_grade,
    null as order_status,
    so.order_time,
    so.payment_workstation,
    null as payment_status,
    null as payment_amount,
    so.payment_time,
    1 as is_placed,
    payment_time as place_time,
    0 as smartba_flag,
    so.item_sku_code,
    so.item_sku_name,
    so.item_quantity,
    null as item_sale_price, -- 暂时赋null, 不知道源表中哪个字段是单价
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
    null as shipping_time,
    null as shipping_amount,
    null as def_ware_house,
    null as actual_ware_house,
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
    'POS' as source,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    [DW_POS].DW_POS_Order_With_SKU so
left join
    DWD.Dim_Store b
on so.store_code = b.store_code
left join
    DW_SAP.DWS_Sales_Ticket sap
on so.item_sku_code = sap.item_sku_code
and so.store_code = sap.store_code
and so.invoice_id = sap.combine_number
left join
(
    select 
        *
        -- ,row_number() over(partition by invc_no, store_code, item_sku_code order by sap_time desc, member_card desc) row_num
    from 
        DW_CRM.DWS_Trans_Order_With_SKU
    where 
        order_time >= '2019-01-01'
    and item_quantity >= 0
    and channel_code = 'OFF_LINE'
) crm
on so.item_sku_code  = crm.item_sku_code
and so.store_code = crm.store_code
and so.invoice_no = crm.invc_no
-- and crm.row_num = 1
-- and so.member_card = crm.member_card
left join
    DWD.DIM_Member_Info m
on isnull(so.member_card, crm.member_card) = m.member_card
left join
    DWD.Dim_Animation a
on so.item_sku_code = a.sku_code
and so.payment_time between a.Start_Date and a.End_Date
where
    so.order_time >= '2019-01-01'

union all
select
    cast(so.trans_id as nvarchar) as sales_order_number,
    null as purchase_order_number,
    so.invc_id,
    so.channel_code,
    so.channel_name,
    so.sub_channel_code,
    so.sub_channel_name,
    so.store_code,
    isnull(so.province, b.nso_province) as province,
    isnull(so.city, b.nso_city) as city,
    b.nso_district as district,
    null as type_code,
    null as sub_type_code,
    so.member_card,
    null as member_card_grade,
    null as order_status,
    so.order_time,
    null as payment_workstation,
    null as payment_status,
    null as payment_amount,
    so.sap_time  as payment_time,
    1 as is_placed,
    so.sap_time as place_time,
    0 as smartba_flag,
    so.item_sku_code,
    so.item_sku_name,
    so.item_quantity,
    null as item_sale_price,
    so.item_total_amount,
    so.item_apportion_amount,
    so.item_discount_amount,
    a.animation_name,
    null virtual_sku_code ,
    null virtual_quantity ,
    null virtual_apportion_amount ,
    null virtual_discount_amount ,
    null virtual_bind_quantity ,
    null as logistics_company,
    null as logistics_number,
    null shipping_time,
    null shipping_amount,
    null def_ware_house,
    null actual_ware_house,
    null pos_sync_time,
    null pos_sync_status,
    null as sap_till_number,
    null as sap_transaction_number,
    null as sap_quantity,
    null as sap_amount,
    null as sap_store_code,
    so.invc_no as crm_invc_no,
    so.trans_type as crm_trans_type,
    so.order_time as crm_trans_time,
    so.item_quantity as  crm_quantity,
    so.item_apportion_amount as crm_amount,
    'CRM' source,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DW_CRM.DWS_Trans_Order_With_SKU so
left join
    DW_POS.DW_POS_Order_With_SKU pos
ON 
    so.invc_no = pos.invoice_no
-- left join
--     DW_SAP.DWS_Sales_Ticket sap
-- on so.item_sku_code = sap.item_sku_code
-- and so.store_code = sap.store_code
-- and so.invc_id = sap.combine_number
left join
    DWD.Dim_Store b
on so.store_code = b.store_code
left join
    DWD.Dim_Animation a
on so.item_sku_code = a.sku_code
and so.sap_time between a.Start_Date and a.End_Date
where
    pos.barcode is null
and so.channel_code = 'OFF_LINE'
and so.order_time < '2021-01-01'
and so.order_time >= '2019-01-01'
and so.item_quantity >= 0
and b.crm_country = 'CN'
;
END
GO
