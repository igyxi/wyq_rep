/****** Object:  StoredProcedure [TEMP].[SP_Fact_Sales_Order_Bak20221011]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Sales_Order_Bak20221011] AS
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
-- ========================================================================================
truncate table DWD.Fact_Sales_Order;
with sales_order as (
    select
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
        member_card,
        member_card_grade,
        payment_status,
        order_status,
        order_time,
        payment_time,
        is_placed,
        place_time,
        smartba_flag,
        item_sku_code,
        item_sku_name,
        item_quantity,
        item_total_amount,
        item_apportion_amount,
        item_discount_amount,
        virtual_sku_code,
        virtual_quantity,
        virtual_apportion_amount,
        virtual_discount_amount,
        c.quantity as virtual_bind_quantity,
        shipping_time,
        shipping_amount,
        def_warehouse,
        actual_warehouse,
        pos_sync_time,
        pos_sync_status,
        'OMS' as source
    from 
    (
        select 
            * 
        from 
            DW_OMS.DWS_Sales_Order_With_SKU
        -- WHERE
        --     purchase_order_number is not null
        union all 
        select 
            a.* 
        from 
            DWD.Fact_OMS_Sales_Order_With_Coupon a 
        left join 
            DW_OMS.DWS_Sales_Order_With_SKU b
        on a.sales_order_number = b.sales_order_number 
        and a.purchase_order_number = b.purchase_order_number 
        and a.item_sku_code = b.item_sku_code
        where b.sales_order_number is null
    ) t
    left join
    (
        select vb_sku_code, bind_sku_code, sum(bind_sku_quantity) as quantity from DWD.DIM_VB_SKU_REL group by vb_sku_code, bind_sku_code
    )c
    on t.virtual_sku_code = c.vb_sku_code
    and t.item_sku_code = c.bind_sku_code
    where
        order_time >= '2019-01-01'
),
hub_order as (
    select
        sales_order_number,
        null as purchase_order_number,
        invoice_no,
        invoice_id,
        channel_code,
        channel_name,
        channel_code as sub_channel_code,
        channel_name as sub_channel_name,
        store_code,
        province,
        city,
        district,
        1 as type_code,
        member_card,
        null as member_card_grade,
        null as payment_status,
        null as order_status,
        order_time,
        payment_time,
        1 as is_placed,
        place_time,
        0 as smartba_flag,
        item_sku_code,
        item_sku_name,
        item_quantity,
        item_total_amount,
        item_apportion_amount,
        item_discount_amount,
        null as virtual_sku_code,
        null as virtual_quantity,
        null as virtual_apportion_amount,
        null as virtual_discount_amount,
        null as virtual_bind_quantity,
        complete_time as shipping_time,
        shipping_amount,
        null as def_warehouse,
        null as actual_warehouse,
        null as pos_sync_time,
        null as pos_sync_status,
        'HUB' as source
    from 
        DW_OrderHub.DWS_Store_Order_With_SKU
    where
        order_status = 8
),
pos_order as (
    select
        barcode as sales_order_number,
        null as purchase_order_number,
        invoice_no,
        invoice_id,
        'OFF_LINE' as channel_code,
        N'线下' as channel_name,
        'OFF_LINE' as sub_channel_code,
        N'线下' as sub_channel_name,
        a.store_code,
        isnull(a.province, b.crm_province) as province,
        isnull(a.city, b.crm_city) as city,
        a.district,
        1 as type_code,
        member_card,
        member_card_grade,
        null as payment_status,
        null as order_status,
        order_time,
        payment_time,
        1 as is_placed,
        payment_time as place_time,
        0 as smartba_flag,
        item_sku_code,
        item_sku_name,
        item_quantity,
        item_total_amount,
        item_apportion_amount,
        item_discount_amount,
        null as virtual_sku_code,
        null as virtual_quantity,
        null as virtual_apportion_amount,
        null as virtual_discount_amount,
        null as virtual_bind_quantity,
        null as shipping_time,
        null as shipping_amount,
        null as def_ware_house,
        null as actual_ware_house,
        null as pos_sync_time,
        null as pos_sync_status,
        'POS' as source
    from 
        [DW_POS].DWS_POS_Order_With_SKU a
    left join
        DWD.Dim_Store b
    on a.store_code = b.store_code
    where
        order_time >= '2019-01-01'
),
crm_order as (
    select
        cast(trans_id as nvarchar) as sales_order_number,
        null as purchase_order_number,
        invc_no as invoice_no,
        invc_id as invoice_id,
        channel_code,
        channel_name,
        sub_channel_code,
        sub_channel_name,
        store_code,
        province,
        city,
        null as district,
        trans_type,
        member_card,
        null as member_card_grade,
        null as payment_status,
        null as order_status,
        order_time,
        sap_time  as payment_time,
        1 as is_placed,
        sap_time as place_time,
        0 as smartba_flag,
        item_sku_code,
        item_sku_name,
        item_quantity,
        item_total_amount,
        item_apportion_amount,
        item_discount_amount,
        null as virtual_sku_code,
        null as virtual_quantity,
        null as virtual_apportion_amount,
        null as virtual_discount_amount,
        null as virtual_bind_quantity,
        null as shipping_time,
        null as shipping_amount,
        null as def_ware_house,
        null as actual_warehouse,
        null as pos_synctime,
        null as pos_sync_status,
        'CRM' as source -- added 202209009 by Joey for issue fix
    FROM 
        DW_CRM.DWS_Trans_Order_With_SKU
    where 
        order_time >= '2019-01-01'
    and item_quantity >= 0
)
-- ,
-- sap_order as (
--     select
--         CASE
--             WHEN LEN(ticket_hour) = 3 THEN '0' + CAST(ticket_hour AS NVARCHAR) 
--             ELSE CAST(ticket_hour AS NVARCHAR)
--         END as Ticket_Hour,
--         CASE 
--             WHEN LEN(ticket_hour) = 3 and left(ticket_hour, 1) < '3' then format(dateadd(day,1, cast(Ticket_Date as varchar)), 'yyyyMMdd')
--             WHEN len(ticket_hour) = 4 and left(ticket_hour, 2) < '03' then format(dateadd(day,1, cast(Ticket_Date as varchar)), 'yyyyMMdd')
--             ELSE CAST(Ticket_Date AS NVARCHAR)
--         END as Ticket_Date,
--         Material_Code,
--         store_code,
--         Till_Number,
--         Transaction_Number,
--         SUM(ISNULL(cast(Quantity as int), 0)) AS SAP_QTY,
--         SUM(ISNULL(cast(Sales_VAT as float),0.0)) AS SAP_AMOUNT
--     from 
--         [ODS_SAP].[Sales_Ticket]
--     where
--         ISNULL(Quantity,0.0)>=0
--     group by 
--         CASE
--             WHEN LEN(ticket_hour) = 3 THEN '0' + CAST(ticket_hour AS NVARCHAR) 
--             ELSE CAST(ticket_hour AS NVARCHAR)
--         END,
--         CASE 
--             WHEN LEN(ticket_hour) = 3 and left(ticket_hour, 1) < '3' then format(dateadd(day,1, cast(Ticket_Date as varchar)), 'yyyyMMdd')
--             WHEN len(ticket_hour) = 4 and left(ticket_hour, 2) < '03' then format(dateadd(day,1, cast(Ticket_Date as varchar)), 'yyyyMMdd')
--             ELSE CAST(Ticket_Date AS NVARCHAR)
--         END,
--         Material_Code,
--         store_code,
--         Till_Number,
--         Transaction_Number   
-- )

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
    t.smartba_flag as is_smartba,
    t.item_sku_code,
    t.item_sku_name,
    t.item_quantity,
    t.item_total_amount,
    t.item_apportion_amount,
    t.item_discount_amount,
    a.animation_name,
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
    t.crm_qty,
    t.crm_amount,
    t.source,
    CURRENT_TIMESTAMP
from
(
    select
        so.sales_order_number,
        so.purchase_order_number,
        so.invoice_id,
        so.channel_code,
        so.channel_name,
        so.sub_channel_code,
        so.sub_channel_name,
        so.store_code,
        so.province as province,
        so.city as city,
        so.district as district,
        so.type_code as type_code,
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
        so.virtual_sku_code,
        so.virtual_quantity,
        so.virtual_apportion_amount,
        so.virtual_discount_amount,
        so.virtual_bind_quantity,
        so.shipping_time,
        so.shipping_amount,
        so.def_warehouse,
        so.actual_warehouse,
        so.pos_sync_time,
        so.pos_sync_status,
        sap.Transaction_Number as sap_transaction_number,
        sap.item_quantity as sap_quantity,
        sap.item_amount as sap_amount,
        sap.Store_Code as sap_store_code,
        crm.invoice_no as crm_invc_no,
        crm.trans_type as crm_trans_type,
        crm.order_time as crm_trans_time,
        crm.item_quantity as crm_qty,
        crm.item_apportion_amount as crm_amount,
        so.source
    from
    (
        select * from sales_order 
        union all
        select * from pos_order
        union all
        select * from hub_order
    ) so
    left join
        DW_SAP.DWS_Sales_Ticket sap
    on so.source = sap.source
    and so.item_sku_code = sap.item_sku_code
    and so.store_code = sap.store_code
    and so.invoice_id = sap.combine_number
    left join
    (
        select *, row_number() over(partition by invoice_no, store_code, item_sku_code order by payment_time desc, member_card desc) row_num 
        from crm_order 
        where channel_code = 'OFF_LINE' or (trans_type <> 3 and member_card is not null)
    ) crm
    on so.item_sku_code  = crm.item_sku_code
    and so.store_code= crm.store_code
    and so.invoice_no = crm.invoice_no
    and crm.row_num = 1
    -- and so.member_card = crm.member_card
    left join
        DWD.DIM_Member_Info m
    on isnull(so.member_card, crm.member_card) = m.member_card


    union all
    -- CRM_History
    select
        a.sales_order_number,
        a.purchase_order_number,
        a.invoice_id,
        a.channel_code,
        a.channel_name,
        a.sub_channel_code,
        a.sub_channel_name,
        a.store_code,
        isnull(a.province, b.nso_province) as province,
        isnull(a.city, b.nso_city) as city,
        b.nso_district as district,
        null as type_code,
        a.member_card,
        a.member_card_grade,
        a.order_status,
        a.order_time,
        a.payment_status,
        a.payment_time,
        a.is_placed,
        a.place_time,
        0 as smartba_flag,
        a.item_sku_code,
        a.item_sku_name,
        a.item_quantity,
        a.item_total_amount,
        a.item_apportion_amount,
        a.item_discount_amount,
        null virtual_sku_code ,
        null virtual_quantity ,
        null virtual_apportion_amount ,
        null virtual_discount_amount ,
        null virtual_bind_quantity ,
        null shipping_time,
        null shipping_amount,
        null def_ware_house,
        null actual_ware_house,
        null pos_sync_time,
        null pos_sync_status,
        null sap_transaction_number,
        null sap_quantity,
        null sap_amount,
        null sap_store_code,
        a.purchase_order_number as crm_invc_no,
        a.trans_type as crm_trans_type,
        a.order_time as crm_trans_time,
        null crm_quantity,
        null crm_amount,
        'CRM' source
    from
        crm_order a
    left join
        pos_order pos
    ON 
        pos.invoice_no = a.invoice_no
    left join
        DWD.Dim_Store b
    on a.store_code = b.store_code
    where
        a.channel_code = 'OFF_LINE'
    and pos.invoice_no is null
    and b.crm_country = 'CN'
    and a.order_time < '2021-01-01'
) t
left join
    DWD.Dim_Animation a
on t.item_sku_code = a.sku_code
and t.place_time between a.Start_Date and a.End_Date
;
END
GO
