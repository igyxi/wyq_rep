/****** Object:  StoredProcedure [DWD].[SP_Fact_POS_Sales_Order_Bak_20230621]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_POS_Sales_Order_Bak_20230621] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-09       tali           ini
-- 2023-02-24       housuangqiang  add sub_type_code/payment_amount/item_sale_price/logistics_company/logistics_number
-- 2023-03-16       lizeyuan       add sap_till_number
-- 2023-04-19       houshuangqiang add payment_workstation
-- 2023-05-06       zhailonglong   add sys_create_time & add sys_update_time
-- 2023-05-07       wangzhichun    update DWD.Dim_Store & DW_SAP.DWS_Sales_Ticket & DW_CRM.DW_Trans_Order_With_SKU
-- ========================================================================================
truncate table DWD.Fact_POS_Sales_Order_New;
insert into DWD.Fact_POS_Sales_Order_New
-- select
--     so.barcode as sales_order_number,
--     null as joint_order_number,
--     null as purchase_order_number,
--     so.invoice_id as invoice_id,
--     'OFF_LINE' as channel_code,
--     N'线下' as channel_name,
--     'OFF_LINE' as sub_channel_code,
--     N'线下' as sub_channel_name,
--     so.store_code,
--     isnull(b.nso_province, b.crm_province) as province,
--     isnull(b.nso_city, b.crm_city) as city,
--     b.nso_district,
--     1 as type_code,
--     null as sub_type_code,
--     m.member_card,
--     so.member_card_grade,
--     null as order_status,
--     so.order_time,
--     so.payment_workstation,
--     null as payment_status,
--     null as payment_amount,
--     so.payment_time,
--     1 as is_placed,
--     payment_time as place_time,
--     0 as smartba_flag,
--     so.item_sku_code,
--     so.item_sku_name,
--     so.item_quantity,
--     null as item_sale_price, -- 暂时赋null, 不知道源表中哪个字段是单价
--     so.item_total_amount,
--     so.item_apportion_amount,
--     so.item_discount_amount,
--     a.animation_name,
--     null as virtual_sku_code,
--     null as virtual_quantity,
--     null as virtual_apportion_amount,
--     null as virtual_discount_amount,
--     null as virtual_bind_quantity,
--     null as logistics_company,
--     null as logistics_number,
--     null as shipping_time,
--     null as shipping_amount,
--     null as def_ware_house,
--     null as actual_ware_house,
--     null as pos_sync_time,
--     null as pos_sync_status,
--     sap.till_number as sap_till_number,
--     sap.Transaction_Number as sap_transaction_number,
--     sap.item_quantity as sap_quantity,
--     sap.item_amount as sap_amount,
--     sap.Store_Code as sap_store_code,
--     crm.invc_no as crm_invc_no,
--     crm.trans_type as crm_trans_type,
--     crm.order_time as crm_trans_time,
--     crm.item_quantity as crm_qty,
--     crm.item_apportion_amount as crm_amount,
--     so.sys_create_time,
--     null as sys_update_time,
--     'POS' as source,
--     CURRENT_TIMESTAMP as insert_timestamp
-- from
--     [DW_POS].DW_POS_Order_With_SKU so
-- left join
--     DWD.Dim_Store b
-- on so.store_code = b.store_code
-- left join
--     DW_SAP.DWS_Sales_Ticket sap
-- on  so.item_sku_code = sap.item_sku_code
-- and so.store_code = sap.store_code
-- and so.invoice_id = sap.combine_number
-- left join
-- (
--     select 
--         '66'+ t.invc_no as invc_no,
--         trans_type,
--         order_time,
--         item_quantity,
--         item_apportion_amount,
--         item_sku_code,
--         t.store_code,
--         member_card
--     from 
--         DW_CRM.DW_Trans_Order_With_SKU t 
--     left join
--         DWD.DIM_Store s
--     on t.store_code = s.store_code
--     where 
--         order_time >= '2019-01-01'
--     and item_quantity >= 0
--     and s.channel_code is null
-- ) crm
-- on so.item_sku_code  = crm.item_sku_code
-- and so.store_code = crm.store_code
-- and so.invoice_no = crm.invc_no
-- -- and crm.row_num = 1
-- -- and so.member_card = crm.member_card
-- left join
--     DWD.DIM_Member_Info m
-- on isnull(so.member_card, crm.member_card) = m.member_card
-- left join
--     DWD.Dim_Animation a
-- on so.item_sku_code = a.sku_code
-- and so.payment_time between a.Start_Date and a.End_Date
-- where
--     so.order_time >= '2019-01-01'

-- union all
select
    cast(so.trans_id as nvarchar) as sales_order_number,
    null as joint_order_number,
    null as purchase_order_number,
    so.invc_id,
    case when so.channel_code in ('JDDJ', 'DIANPING', 'MEITUAN') then so.channel_code
         when so.channel_code is not null then 'SOA'
         when b.channel_code is null then 'OFF_LINE'
         else b.channel_code 
    end as channel_code,
    case when so.channel_code in ('JDDJ', 'DIANPING', 'MEITUAN') then so.channel_name
         when so.channel_code is not null then N'官网'
         when b.channel_code is null then N'线下'
         else b.channel_name 
    end as channel_name,
    case when so.channel_code is not null then so.channel_code
        when b.sub_channel_code is null then 'OFF_LINE' 
        else b.sub_channel_code
    end as sub_channel_code,
    case when so.channel_code is not null then so.channel_name
        when b.sub_channel_code is null then N'线下' 
        else b.sub_channel_name
    end as sub_channel_name,
    so.store_code,
    isnull(b.nso_province,so.province) as province,
    isnull(b.nso_city,so.city) as city,
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
    ('66'+ so.invc_no) as crm_invc_no,
    so.trans_type as crm_trans_type,
    so.order_time as crm_trans_time,
    so.item_quantity as  crm_quantity,
    so.item_apportion_amount as crm_amount,
    so.create_time as sys_create_time,
    so.update_time as sys_update_time,
    'CRM' source,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DW_CRM.DW_Trans_Order_With_SKU so
left join
    DW_POS.DW_POS_Order_With_SKU pos
ON
    ('66'+ so.invc_no) = pos.invoice_no
left join
    DWD.Dim_Store b
on so.store_code = b.store_code
left join
    DWD.Dim_Animation a
on so.item_sku_code = a.sku_code
and so.sap_time between a.Start_Date and a.End_Date
where
    pos.barcode is null
and case when so.channel_code is not null then so.channel_code
        when b.sub_channel_code is null then 'OFF_LINE' 
        else b.sub_channel_code
    end ='OFF_LINE'
and so.order_time < '2021-01-01'
and so.order_time >= '2019-01-01'
and so.item_quantity >= 0
and b.crm_country = 'CN'
;
END

GO
