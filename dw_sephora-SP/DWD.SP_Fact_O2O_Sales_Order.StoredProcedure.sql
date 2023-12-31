/****** Object:  StoredProcedure [DWD].[SP_Fact_O2O_Sales_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_O2O_Sales_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-21       houshuangqiang  Initial Version
-- 2022-12-23       houshuangqiang  DWD迁移，将门店切换之后的数据合并到DWD中
-- 2023-02-24       houshuangqiang  add sub_type_code/payment_amount/item_total_amount/logistics_number/logistics_company
-- 2023-03-16       lizeyuan       add sap_till_number
-- 2023-03-17       houshuangqiang changge source schema
-- 2023-04-19       houshuangqiang change SOA sub_channel & add joint_order_number & add payment_workstation
-- 2023-05-06       zhailonglong   add sys_create_time & add sys_update_time
-- 2023-05-09       wangzhichun    union all 'O2O'&'HUB' & add column & update DW_CRM.DW_Trans_Order_With_SKU
-- 2023-05-21       tali           delete the filter order_status = 8 for new o2o
-- 2023-06-21       houshuangqiang add so_order_status
-- ========================================================================================
truncate table [DWD].[Fact_O2O_Sales_Order];

with so as
(
    select 
        sales_order_number,
        joint_order_number,
        purchase_order_number,
        invoice_no,
        invoice_id,
        channel_code,
        channel_name,
        store_code,
        province,
        city,
        district,
        member_card,
        null as so_order_status,
        order_status,
        order_time,
        payment_status,
        total_paid_amount,
        payment_time,
        is_placed,
        place_time,
        item_sku_code,
        item_quantity,
        item_sale_price,
        item_total_amount,
        item_apportion_amount,
        item_discount_amount,
        complete_time,
        shipping_amount,
        create_time,
        update_time,
        'HUB' as source
    from 
        DW_OMS_Order.DW_O2O_Sales_Order_With_SKU 
    where is_sync is null -- 只取迁移之后的数据
    union all 
    select 
        sales_order_number,
        null as joint_order_number,
        null as purchase_order_number,
        invoice_no,
        invoice_id,
        sku.channel_code,
        sku.channel_name,
        sku.store_code,
        s.nso_province as province,
        s.nso_city as city,
        s.nso_district,
        member_card,
        null as so_order_status,
        order_status,
        order_time,
        null as payment_status,
        payment_amount as total_paid_amount,
        payment_time,
        is_placed,
        place_time,
        item_sku_code,
        item_quantity,
        item_sale_price,
        item_total_amount,
        item_apportion_amount,
        item_discount_amount,
        complete_time,
        shipping_amount,
        create_time,
        update_time,
        'HUB' as source
    from 
        DW_OrderHub.DW_Store_Order_With_SKU sku
    left join 
        DWD.DIM_Store s
    on sku.store_code=s.store_code
    where
        sku.order_status = 8
)

insert into [DWD].[Fact_O2O_Sales_Order]
select
    so.sales_order_number,
    so.joint_order_number,
    so.purchase_order_number,
    so.invoice_id,
    so.channel_code,
    so.channel_name,
    case when so.channel_code = 'SOA' then 'SFDC' else so.channel_code end as sub_channel_code,
    case when so.channel_code = 'SOA' then 'SFDC' else so.channel_name end as sub_channel_name,
    so.store_code,
    -- so.store_name,
    so.province,
    so.city,
    so.district,
    '1' as type_code,
    null as sub_type_code,
    m.member_card,
    member.member_card_grade as member_card_grade,
    so.so_order_status,
    so.order_status,
    so.order_time,
    null payment_workstation,
    so.payment_status,
    so.total_paid_amount as payment_amount,
    so.payment_time,
    so.is_placed,
    so.place_time,
    0 as smartba_flag,
    so.item_sku_code,
--    so.item_sku_name,
    sku.eb_sku_name_cn as item_sku_name, -- sku_name 以eb系统中的名称为准,上线之后，改成eb_sku_name_cn,现在没有dim_sku_info的依赖
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
--    so.pick_time as shipping_time,
    so.shipping_amount,
    null as def_warehouse, -- 源头数据中默认发货仓和实际发货仓没有赋值。
    null as actual_warehouse,
    null as pos_sync_time,
    null as pos_sync_status,
    sap.till_number as sap_till_number,
    sap.transaction_number as sap_transaction_number,
    sap.item_quantity as sap_quantity,
    sap.item_amount as sap_amount,
    sap.store_code as sap_store_code,
    crm.invc_no as crm_invc_no,
    crm.trans_type as crm_trans_type,
    crm.order_time as crm_trans_time,
    crm.item_quantity as crm_qty,
    crm.item_apportion_amount as crm_amount,
    so.create_time as sys_create_time,
    so.update_time as sys_update_time,
    -- 'HUB' as source,
    so.source,
    CURRENT_TIMESTAMP as insert_timestamp
from
    so
left join
(   
    select
        till_number,
        Transaction_Number,
        item_quantity,
        item_amount,
        Store_Code,
        item_sku_code
    from
        DW_SAP.DWS_Sales_Ticket ticket
    where ticket.Till_Number in ('0000000997','0000000999','0000000998')
) sap
on so.item_sku_code = sap.item_sku_code
and so.store_code = sap.store_code
and so.invoice_id = sap.transaction_Number
left join
(
    select 
        '66'+ trans.invc_no as invc_no,
        trans_type,
        order_time,
        item_quantity,
        item_apportion_amount,
        item_sku_code,
        store_code,
        channel_code,
        member_card,
        row_number() over(partition by invc_no, store_code, item_sku_code order by sap_time desc, member_card desc) row_num
    from 
        DW_CRM.DW_Trans_Order_With_SKU trans 
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
left join
(
    select member_card,
           upper(substring(card_type_name,3,100)) as member_card_grade,
           start_time,
           end_time
    from dwd.dim_member_card_grade_scd  -- 订单表中，会员身份为空，从会员身份变化记录表中去获取下单时的身份。
) member
on so.member_card = member.member_card
and so.payment_time between member.start_time and member.end_time
left join
    DWD.DIM_SKU_Info sku
on  so.item_sku_code = sku.sku_code
-- where
--     order_status = 8
END;
GO
