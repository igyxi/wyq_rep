/****** Object:  StoredProcedure [DWD].[SP_Fact_OffLine_Sales_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_OffLine_Sales_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-16       houshuangqiang           Initial Version(new oms)
-- ========================================================================================
truncate table [DWD].[Fact_OffLine_Sales_Order];
with coupon_sku as
(
    select
        a.sales_order_number,
        a.joint_order_number,
        a.purchase_order_number,
        a.invoice_id,
        a.channel_code,
        a.channel_name,
        a.sub_channel_code,
        a.sub_channel_name,
        a.store_code,
        a.province,
        a.city,
        a.district,
        a.type_code,
        a.sub_type_code,
        m.member_card,
        a.member_card_grade,
        a.so_order_status,
        a.po_order_status,
        a.order_time,
        null as payment_workstation,
        a.payment_status,
        a.payment_amount,
        a.payment_time,
        a.is_placed,
        a.place_time,
        a.smartba_flag as smartba_flag,
        crm.item_sku_code,
        crm.item_sku_name,
        crm.item_quantity as item_quantity,
        0 as item_sale_price,
        0 as item_total_amount,
        0 as item_apportion_amount,
        0 as item_discount_amount,
        null as animation_name,
        null as virtual_sku_code,
        null as virtual_quantity,
        null as virtual_apportion_amount,
        null as virtual_discount_amount,
        null as virtual_bind_quantity,
        a.logistics_company,
        a.logistics_number,
        a.shipping_time,
        a.shipping_amount,
        a.def_warehouse,
        a.actual_warehouse,
        a.pos_sync_time,
        a.pos_sync_status,
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
        a.sys_create_time,
        a.sys_update_time,
        'New OMS' as source,
        CURRENT_TIMESTAMP as insert_timestamp
    from
    (
        select distinct
            sales_order_number,
            joint_order_number,
            purchase_order_number,
            invoice_no,
            invoice_id,
            channel_code,
            channel_name,
            sub_channel_code,
            sub_channel_name,
            store_code,
            province,
            city,
            district,
            type_code,
            sub_type_code,
            member_card,
            member_card_grade,
            payment_status,
            payment_amount,
            so_order_status,
            po_order_status,
            order_time,
            payment_time,
            is_placed,
            place_time,
            smartba_flag,
            logistics_company,
            logistics_number,
            shipping_time,
            shipping_amount,
            def_warehouse,
            actual_warehouse,
            pos_sync_time,
            pos_sync_status,
            sys_create_time,
            sys_update_time
        from
            DW_OMS_Order.DW_OffLine_Sales_Order_With_SKU
    ) a
    join
    (
        select
            t.*
        from
            DW_CRM.DW_Trans_Order_With_SKU t
        left join
            DWD.DIM_Store s
        on t.store_code = s.store_code
        where
            item_quantity >= 0
        and s.channel_code is not null
        and t.trans_type = 1
        and t.item_apportion_amount = 0
    ) crm
    on a.invoice_no = crm.invc_no
    join
    (
        select * from DW_CRM.DIM_SKU where is_offer = 1 and COALESCE(brand,'') <> 'GWP'
    ) c
    on crm.item_sku_code = c.sku_code
    left join
        DW_SAP.DWS_Sales_Ticket sap
    on crm.item_sku_code = sap.item_sku_code
    and crm.store_code = sap.store_code
    and  a.invoice_id  = cast(try_cast(sap.Transaction_Number as bigint) as nvarchar)
    left join
        DWD.DIM_Member_Info m
    on isnull(a.member_card, crm.member_card) = m.member_card
),
oms_so as (
    select
        so.sales_order_number,
        so.joint_order_number,
        so.purchase_order_number,
        so.invoice_id,
        so.channel_code,
        so.channel_name,
        so.sub_channel_code,
        so.sub_channel_name,
        so.store_code,
        so.province,
        so.city,
        so.district,
        so.type_code,
        so.sub_type_code,
        m.member_card,
        so.member_card_grade,
        so.so_order_status,
        so.po_order_status,
        so.order_time,
        null as payment_workstation,
        so.payment_status,
        so.payment_amount,
        so.payment_time,
        so.is_placed,
        so.place_time,
        so.smartba_flag,
        so.item_sku_code,
        -- so.item_sku_name,
        sku.eb_sku_name_cn as item_sku_name,
        so.item_quantity,
        so.item_sale_price,
        so.item_total_amount,
        so.item_apportion_amount,
        so.item_discount_amount,
        a.animation_name,
        so.virtual_sku_code,
        so.virtual_quantity,
        so.virtual_apportion_amount,
        so.virtual_discount_amount,
        v.quantity as virtual_bind_quantity,
        so.logistics_company,
        so.logistics_number,
        so.shipping_time,
        so.shipping_amount,
        so.def_warehouse,
        so.actual_warehouse,
        so.pos_sync_time,
        so.pos_sync_status,
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
        so.sys_create_time,
        so.sys_update_time,
        'New OMS' as source,
        CURRENT_TIMESTAMP as insert_timestamp
    from
    (
        select * from DW_OMS_Order.DW_OffLine_Sales_Order_With_SKU
    ) so
    left join
    (
        select vb_sku_code, bind_sku_code, sum(bind_sku_quantity) as quantity from DWD.DIM_VB_SKU_REL group by vb_sku_code, bind_sku_code
    ) v
    on so.virtual_sku_code = v.vb_sku_code
    and so.item_sku_code = v.bind_sku_code
    left join
        DW_SAP.DWS_Sales_Ticket sap
    on so.item_sku_code = sap.item_sku_code
    and so.store_code = sap.store_code
    and  so.invoice_id  = cast(try_cast(sap.Transaction_Number as bigint) as nvarchar)
    left join
    (
        select
            t.*
            , row_number() over(partition by invc_no, t.store_code, item_sku_code order by sap_time desc, member_card desc) row_num
        from
            DW_CRM.DW_Trans_Order_With_SKU t
        left join
            DWD.DIM_Store s
        on t.store_code = s.store_code
        where
            item_quantity >= 0
        and s.channel_code is not null
        and trans_type = 1
    ) crm
    on so.item_sku_code  = crm.item_sku_code
    and so.store_code= crm.store_code
    and so.invoice_no = crm.invc_no
    and crm.row_num = 1
    left join
        DWD.DIM_Member_Info m
    on isnull(so.member_card, crm.member_card) = m.member_card
    left join
        DWD.DIM_SKU_Info sku
    on  so.item_sku_code = sku.sku_code
    left join
        DWD.Dim_Animation a
    on so.item_sku_code = a.sku_code
    and so.place_time between a.Start_Date and a.End_Date
)

insert into [DWD].[Fact_OffLine_Sales_Order]
select a.* from coupon_sku a left join oms_so b
on a.sales_order_number = b.sales_order_number
and a.purchase_order_number = b.purchase_order_number
and a.item_sku_code = b.item_sku_code
where b.purchase_order_number is null
union all
select * from oms_so
END
GO
