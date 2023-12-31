/****** Object:  StoredProcedure [TEMP].[SP_Fact_OMS_Sales_Order_Bak_20230217]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_OMS_Sales_Order_Bak_20230217] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-10       Tali           Initial Version
-- 2022-10-31       houshuangqiang add create_time/update_time
-- ========================================================================================
truncate table [DWD].[Fact_OMS_Sales_Order_New];
with coupon_sku as
(
    select
        a.sales_order_number,
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
        m.member_card,
        a.member_card_grade,
        a.order_status,
        a.order_time,
        a.payment_status,
        a.payment_time,
        a.is_placed,
        a.place_time,
        a.smartba_flag as smartba_flag,
        crm.item_sku_code,
        crm.item_sku_name,
        crm.item_quantity as item_quantity,
        0 as item_total_amount,
        0 as item_apportion_amount,
        0 as item_discount_amount,
        null as animation_name,
        null as virtual_sku_code,
        null as virtual_quantity,
        null as virtual_apportion_amount,
        null as virtual_discount_amount,
        null as virtual_bind_quantity,
        a.shipping_time,
        a.shipping_amount,
        a.def_warehouse,
        a.actual_warehouse,
		a.create_time,
		a.update_time,		
        a.pos_sync_time,
        a.pos_sync_status,
        sap.Transaction_Number as sap_transaction_number,
        sap.item_quantity as sap_quantity,
        sap.item_amount as sap_amount,
        sap.Store_Code as sap_store_code,
        crm.invc_no as crm_invc_no,
        crm.trans_type as crm_trans_type,
        crm.order_time as crm_trans_time,
        crm.item_quantity as crm_qty,
        crm.item_apportion_amount as crm_amount,
        'OMS' as source,
        CURRENT_TIMESTAMP as insert_timestamp
    from 
    (
        select distinct 
            sales_order_number, 
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
            member_id,
            member_card,
            member_card_grade,
            payment_status,
            order_status,
            order_time,
            payment_time,
            is_placed,
            place_time,
            smartba_flag,
            shipping_time,
            shipping_amount,
            def_warehouse,
            actual_warehouse,
			create_time,
			update_time,	
            pos_sync_time,
            pos_sync_status
        from
            DW_OMS.DWS_Sales_Order_With_SKU_New 
    ) a
    join
    (
        select 
            * 
        from 
            DW_CRM.DWS_Trans_Order_With_SKU 
        where 
            item_quantity >= 0
        and channel_code <> 'OFF_LINE'
        and trans_type = 1
        and item_apportion_amount = 0
    ) crm
    on a.invoice_no = crm.invc_no
    join
    (
        select * from DW_CRM.DIM_SKU where is_offer = 1 and brand <> 'GWP'
    ) c
    on crm.item_sku_code = c.sku_code
    left join
        DW_SAP.DWS_Sales_Ticket sap
    on crm.item_sku_code = sap.item_sku_code
    and crm.store_code = sap.store_code
    and  a.invoice_id  = sap.combine_number
    left join
        DWD.DIM_Member_Info m
    on isnull(a.member_card, crm.member_card) = m.member_card
), 
oms_so as (
    select
        so.sales_order_number,
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
        m.member_card,
        so.member_card_grade,
        so.order_status,
        so.order_time,
        so.payment_status,
        so.payment_time,
        so.is_placed,
        so.place_time,
        so.smartba_flag,
        so.item_sku_code,
        so.item_sku_name,
        so.item_quantity,
        so.item_total_amount,
        so.item_apportion_amount,
        so.item_discount_amount,
        a.animation_name,
        so.virtual_sku_code,
        so.virtual_quantity,
        so.virtual_apportion_amount,
        so.virtual_discount_amount,
        v.quantity as virtual_bind_quantity,
        so.shipping_time,
        so.shipping_amount,
        so.def_warehouse,
        so.actual_warehouse,
		so.create_time,
		so.update_time,
        so.pos_sync_time,
        so.pos_sync_status,
        sap.Transaction_Number as sap_transaction_number,
        sap.item_quantity as sap_quantity,
        sap.item_amount as sap_amount,
        sap.Store_Code as sap_store_code,
        crm.invc_no as crm_invc_no,
        crm.trans_type as crm_trans_type,
        crm.order_time as crm_trans_time,
        crm.item_quantity as crm_qty,
        crm.item_apportion_amount as crm_amount,
        'OMS' as source,
        CURRENT_TIMESTAMP as insert_timestamp
    from 
    (
        select * from DW_OMS.DWS_Sales_Order_With_SKU_New
        -- union all 
        -- select * from coupon_sku
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
    and  so.invoice_id  = sap.combine_number
    left join
    (
        select 
            *
            , row_number() over(partition by invc_no, store_code, item_sku_code order by sap_time desc, member_card desc) row_num
        from 
            DW_CRM.DWS_Trans_Order_With_SKU
        where 
            item_quantity >= 0
        and channel_code <> 'OFF_LINE'
        and trans_type = 1
        -- and member_card is not null
    ) crm
    on so.item_sku_code  = crm.item_sku_code
    and so.store_code= crm.store_code
    and so.invoice_no = crm.invc_no
    and crm.row_num = 1
    -- and so.member_card = crm.member_card
    left join
        DWD.DIM_Member_Info m
    on isnull(so.member_card, crm.member_card) = m.member_card
    left join
        DWD.Dim_Animation a
    on so.item_sku_code = a.sku_code
    and so.place_time between a.Start_Date and a.End_Date
)

insert into [DWD].[Fact_OMS_Sales_Order_New]
select a.* from coupon_sku a left join oms_so b 
on a.sales_order_number = b.sales_order_number
and a.purchase_order_number = b.purchase_order_number 
and a.item_sku_code = b.item_sku_code 
where b.purchase_order_number is null
union all 
select * from oms_so
END

GO
