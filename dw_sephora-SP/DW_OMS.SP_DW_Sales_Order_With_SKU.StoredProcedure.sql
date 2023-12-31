/****** Object:  StoredProcedure [DW_OMS].[SP_DW_Sales_Order_With_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DW_Sales_Order_With_SKU] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-14       tali           Initial Version
-- 2022-03-18       tali           change the member_card logic for jd
-- 2022-03-21       tali           change the logic for item_sku_name
-- 2022-03-21       tali           filter dupilcate in purchase_to_sap
-- 2022-03-30       tali           add province city mapping
-- 2022-04-18       tali           replace char(160) for sku_code
-- 2022-05-19       tali           add district
-- 2022-05-30       wangzhichun    add smartba_flag
-- 2022-07-14       tali           change logic
-- 2022-07-25       tali           fix purchase_order_item
-- 2022-08-18       tali           fix vb_sku_rel
-- 2022-09-08       tali           delete bind_quantity
-- 2022-09-20       tali           add trp001 as shipping sku
-- 2022-09-29       tali           update smartba_flag
-- 2022-12-10       tali           update the OMS_Province_City_Mapping
-- 2023-02-20       houshuangqiang add sales_order_sys_id/basic_status/merge_flag
-- 2023-02-21       houshuangqiang add payment_amount/logistics_company/logistics_number & filter basic_status <> 'DELETED'
-- 2023-03-14       houshuangqiang 取消so单中basic_status <> 'DELETED'的限制，因为ps两张报表数据切换数据源时，影响到这边的数据了
-- 2023-05-06       LeoZhai        add sys_create_time & add sys_update_time
-- 2023-05-17       wangzhichun    update OMS_Store_Info&OMS_Store_Mapping schema
-- 2023-06-09       LeoZhai        change the source table to DWD.DW_Sales_Order
-- ========================================================================================
truncate table DW_OMS.DW_Sales_Order_With_SKU;
insert into DW_OMS.DW_Sales_Order_With_SKU
select
    ta.sales_order_number as sales_order_number,
    tb.purchase_order_number as purchase_order_number,
    tb.purchase_order_number as invoice_no,
    tb.invoice_id as invoice_id,
    ta.channel_code,
    ta.channel_name,
    ta.sub_channel_code,
    ta.sub_channel_name,
    m.store_code as store_code,
    ta.province as province,
    ta.city as city,
    ta.district,
    isnull(tb.[type], ta.[type]) as type_code,
    tb.merge_flag as sub_type_code,
    ta.member_id,
    ta.member_card,
    ta.member_card_grade,
    ta.payment_status as payment_status,
    ta.payed_amount as payment_amount,
    isnull(tb.order_internal_status, ta.order_internal_status) as order_status,
    ta.order_time,
    ta.payment_time,
    ta.is_placed,
    ta.place_time,
    ta.smartba_flag AS smartba_flag,
    tb.item_sku as item_sku_code,
    tb.item_name as item_sku_name,
    tb.item_quantity as item_quantity,
    tb.item_sale_price as item_sale_price,
    tb.item_total_amount as item_total_amount,
    tb.item_apportion_amount as item_apportion_amount,
    tb.item_adjustment_total as item_discount_amount,
    isnull(tb.virtual_sku, tc.vb_sku) as virtual_sku_code,
    tc.vb_quantity as virtual_quantity,
    tc.vb_apportion_amount as virtual_apportion_amount,
    tc.vb_adjustment_amount as virtual_discount_amount,
    tb.logistics_shipping_company as logistics_company,
    tb.logistics_number,
    tb.shipping_time,
    tb.shipping_total as shipping_amount,
    tb.order_def_ware_house as def_warehouse,
    tb.order_actual_ware_house as actual_warehouse,
    tb.pos_sync_time,
    tb.pos_sync_status,
	tb.sys_create_time,
	tb.sys_update_time,
    CURRENT_TIMESTAMP as insert_timestamp
from
    DW_OMS.DW_Sales_Order ta
left join
(
    select
        a.sales_order_sys_id,
        a.purchase_order_number,
        a.[type],
        a.order_def_ware_house,
        a.order_actual_ware_house,
        a.shipping_time,
        a.shipping_total,
        a.order_internal_status,
        s.invoice_id,
        s.pos_sync_time,
        s.pos_sync_status,
        a.merge_flag,
        a.logistics_shipping_company,
        a.logistics_number,
        a.sys_create_time,
        a.sys_update_time,
        replace(replace(b.item_sku,'?',''), char(160), '') as item_sku,
        max(b.item_name) as item_name,
        max(b.item_sale_price) as item_sale_price,
        sum(b.item_quantity) as item_quantity,
        sum(b.apportion_amount + abs(item_adjustment_total)) as item_total_amount,
        sum(b.apportion_amount) as item_apportion_amount,
        sum(abs(b.item_adjustment_total)) as item_adjustment_total,
        max(b.virtual_sku) as virtual_sku
    from
    (
        select *, row_number() over(partition by purchase_order_number order by sys_create_time desc) rownum from STG_OMS.Purchase_Order
    ) a
    join
    (
        select
            purchase_order_sys_id,
            item_sku,
            item_name,
            item_quantity,
            item_sale_price,
            apportion_amount,
            item_adjustment_total,
            virtual_sku
            
        from STG_OMS.Purchase_Order_item
        union all
        select
            purchase_order_sys_id,
            'TRP001' as item_sku,
            N'EB虚拟券' as item_name,
            1 as item_quantity,
            0 as item_sale_price,
            shipping_total as apportion_amount,
            0 as item_adjustment_total,
            null as virtual_sku
        from STG_OMS.Purchase_Order
        where shipping_total > 0
        and (split_type <> 'SPLIT_ORIGIN' or split_type is null)
        and basic_status <> 'DELETED'
        and type <> 2
    )b
    on a.purchase_order_sys_id = b.purchase_order_sys_id
    left join
        STG_OMS.Purchase_To_SAP s
    ON a.purchase_order_sys_id = s.purchase_order_sys_id
    -- and s.pos_sync_time is not null
    where
        (a.split_type <> 'SPLIT_ORIGIN' or a.split_type is null)
    and a.basic_status <> 'DELETED'
    and a.type <> 2
    and a.rownum = 1
    group by
        a.sales_order_sys_id,
        a.purchase_order_number,
        a.[type],
        a.order_def_ware_house,
        a.order_actual_ware_house,
        a.shipping_time,
        a.shipping_total,
        a.order_internal_status,
        s.invoice_id,
        s.pos_sync_time,
        s.pos_sync_status,
        replace(replace(item_sku,'?',''), char(160), ''),
        a.merge_flag,
        a.logistics_shipping_company,
        a.logistics_number,
        a.sys_create_time,
        a.sys_update_time
) tb
on ta.sales_order_sys_id = tb.sales_order_sys_id
left join
(
    -- select
    --     t.*, v.bind_sku_code, v.quantity as bind_quantity
    -- from
    -- (
    select
        sales_order_sys_id,
        item_sku as vb_sku,
        sum(item_quantity) as vb_quantity,
        sum(apportion_amount) as vb_apportion_amount,
        sum(item_adjustment_total) as vb_adjustment_amount
    from
        STG_OMS.Sales_Order_item i
    where
        item_sku like 'V%'
    group by
        sales_order_sys_id,
        item_sku
    -- )t
    -- left join
    -- (
    --     select vb_sku_code, bind_sku_code, sum(quantity) as quantity  from STG_Product.PROD_VB_SKU_REL group by vb_sku_code, bind_sku_code
    -- )v
    -- on t.vb_sku = v.vb_sku_code
) tc
on ta.sales_order_sys_id = tc.sales_order_sys_id
and tb.virtual_sku = tc.vb_sku
left join
    ODS_OMS.OMS_Store_Mapping m
on ta.store_id = m.store_id
and tb.order_actual_ware_house = m.warehouse
END


GO
