/****** Object:  StoredProcedure [TEMP].[SP_DW_Sales_Order_With_SKU_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_Sales_Order_With_SKU_Bak_20230518] AS
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
-- 2023-05-06       zhailonglong   add sys_create_time & add sys_update_time
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
    td.province as province,
    td.city as city,
    td.district,
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
(
    select
        a.sales_order_sys_id,
        a.sales_order_number,
        a.store_id,
        si.channel_id as channel_code,
        si.channel_name,
        case when a.store_id = 'S001' then a.channel_id
            when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006'
            else a.store_id
        end as sub_channel_code,
        case
            when a.store_id = 'S001' then a.channel_id
            when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then N'天猫WEI旗舰店'
            else si.store_name
        end as sub_channel_name,
        si.store_name,
        a.type,
        a.member_id,
        case when si.channel_id = 'JD' and a.member_card like 'JD%' then SUBSTRING(a.member_card, 3, len(a.member_card)-2) else a.member_card end as member_card,
        COALESCE(a.member_card_grade, b.group_name) as member_card_grade,
        a.order_internal_status,
        a.order_time,
        a.payment_status,
        a.payment_time,
        a.payed_amount,
        case when a.basic_status <> 'DELETED'
            and a.store_id not in ('TMALL002', 'GWP001')
            and a.type not in (2, 9)
            and ((a.payment_status = 1 and a.payment_time is not null) or a.type = 8)
            and a.product_total > 1 then 1
            else 0
        end as is_placed,
        case when a.type = 8 then a.order_time
            else COALESCE(a.payment_time, a.order_time)
        end as place_time,
        case when a.smartba_flag is not null then a.smartba_flag
             when os.order_id is not null and a.channel_id = 'MINIPROGRAM' then 1
            else 0
        end as smartba_flag
    from
        STG_OMS.Sales_Order a
    left join
    (
        select order_id, group_name from STG_Order.Orders where group_name <> 'O2O'
    ) b
    on a.sales_order_number = b.order_id
    left join
        STG_OMS.OMS_Store_Info si
    on case when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006' else a.store_id end = si.store_id
    left join
    (
        select distinct
            order_id
        from
            STG_Order.Order_Source
        where
            utm_campaign = 'BA'
        and
            utm_medium ='seco'
    ) os
    on  a.sales_order_number = os.order_id
    -- where a.basic_status <> 'DELETED' -- 2023-03-14 取消过滤条件
) ta
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
-- and tb.item_sku = tc.bind_sku_code
left join
(
    select
        sales_order_sys_id,
        opcm.crm_province as province,
        opcm.crm_city as city,
        soa.district,
        row_number() over(partition by sales_order_sys_id order by create_time desc) rn
    from
        STG_OMS.Sales_order_Address soa
    left join
        STG_OMS.OMS_Province_City_Mapping opcm
    on soa.province = opcm.oms_province
    and isnull(soa.city, '') = isnull(opcm.oms_city, '')
    where
        soa.is_delete = 0
) td
on ta.sales_order_sys_id = td.sales_order_sys_id
and td.rn = 1

left join
    STG_OMS.OMS_Store_Mapping m
on ta.store_id = m.store_id
and tb.order_actual_ware_house = m.warehouse
END


GO
