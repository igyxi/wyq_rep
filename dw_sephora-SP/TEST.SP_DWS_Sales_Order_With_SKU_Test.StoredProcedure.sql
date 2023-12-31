/****** Object:  StoredProcedure [TEST].[SP_DWS_Sales_Order_With_SKU_Test]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_DWS_Sales_Order_With_SKU_Test] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-27       wangzhichun    Initial Version
-- ========================================================================================
truncate table Test.DWS_Sales_Order_With_SKU_Test;
insert into Test.DWS_Sales_Order_With_SKU_Test
select
    a.sales_order_number as sales_order_number,
    b.purchase_order_number as purchase_order_number,
    s.invoice_id as invoice_id,
    si.channel_id as channel_code,
    si.channel_name as channel_name,
    case when si.store_id = 'S001' then a.channel_id 
         when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006'
         else si.store_id 
    end as sub_channel_code,
    case 
        when si.store_id = 'S001' then a.channel_id
        when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then N'天猫WEI旗舰店' 
        else si.store_name 
    end as sub_channel_name,
    m.store_code as store_code,
    sa.province as province,
    sa.city as city,
    sa.district,
    b.[type] as type_code,
    a.member_id,
    case when si.channel_id = 'JD' and a.member_card like 'JD%' then SUBSTRING(a.member_card, 3, len(a.member_card)-2) else a.member_card end as member_card,
    COALESCE(a.member_card_grade, d.group_name) as member_card_grade,
    -- a.member_card_grade as member_card_grade,
    a.payment_status as payment_status,
    b.order_internal_status as order_status,
    a.order_time,
    a.payment_time,
    case when a.basic_status <> 'DELETED' and a.store_id not in ('TMALL002', 'GWP001') and a.type not in (2, 9)
        and ((a.payment_status = 1 and a.payment_time is not null) or a.type = 8)
        and a.product_total > 1 then 1
        else 0 
    end as is_placed,
    case when a.type = 8 then a.order_time 
        else COALESCE(a.payment_time, a.order_time)
    end as place_time,
    a.smartba_flag AS smartba_flag,
    c.item_sku as item_sku_code,
    c.item_name as item_sku_name,
    c.item_quantity as item_quantity,
    c.item_total_amount as item_total_amount,
    c.item_apportion_amount as item_apportion_amount,
    c.item_adjustment_total as item_discount_amount,
    c.virtual_sku as virtual_sku_code,
    i.item_quantity as virtual_quantity,
    i.apportion_amount as virtual_apportion_amount,
    i.item_adjustment_total as virtual_discount_amount,
    v.quantity as virtual_bind_quantity,
    b.shipping_time,
    a.shipping_total as shipping_amount,
    b.order_def_ware_house as def_warehouse,
    b.order_actual_ware_house as actual_warehouse,
    s.pos_sync_time,
    s.pos_sync_status,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    STG_OMS.Sales_Order a
left join
(
    select *, row_number() over(partition by purchase_order_number order by sys_create_time) rownum from STG_OMS.Purchase_Order
) b 
on a.sales_order_sys_id = b.sales_order_sys_id 
and b.split_type <> 'SPLIT_ORIGIN'
and b.basic_status <> 'DELETED'
and b.type <> 2
and b.rownum = 1
left join
(
    select order_id, group_name from STG_Order.Orders where group_name <> 'O2O'
) d
on a.sales_order_number = d.order_id
left join
    STG_OMS.OMS_Store_Mapping m
on a.store_id = m.store_id
and b.order_actual_ware_house = m.warehouse
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
    and soa.city = opcm.oms_city
    where 
        soa.is_delete = 0
) sa
on a.sales_order_sys_id = sa.sales_order_sys_id
and sa.rn = 1
left join 
    STG_OMS.OMS_Store_Info si
on case when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006' else a.store_id end = si.store_id
left join
(
    select  
        purchase_order_sys_id,
        replace(replace(item_sku,'?',''), char(160), '') as item_sku,
        max(item_name) as item_name,
        sum(item_quantity) as item_quantity,
        sum(apportion_amount + abs(item_adjustment_total)) as item_total_amount,
        sum(apportion_amount) as item_apportion_amount,
        sum(abs(item_adjustment_total)) as item_adjustment_total,
        max(virtual_sku) as virtual_sku
    from 
        STG_OMS.Purchase_Order_item 
    group by 
        purchase_order_sys_id,
        replace(replace(item_sku,'?',''), char(160), '') 
        -- max(item_name)
) c 
on b.purchase_order_sys_id = c.purchase_order_sys_id
left join
(
    select 
        sales_order_sys_id,
        item_sku, 
        sum(item_quantity) as item_quantity, 
        sum(apportion_amount) as apportion_amount, 
        sum(item_adjustment_total) as item_adjustment_total
    from 
        STG_OMS.Sales_Order_item 
    where
        item_sku like 'V%'
    group by 
        sales_order_sys_id,
        item_sku
) i
on a.sales_order_sys_id = i.sales_order_sys_id
and c.virtual_sku = i.item_sku
left join
    STG_Product.PROD_VB_SKU_REL v
on c.virtual_sku = v.vb_sku_code
and c.item_sku = v.bind_sku_code
left join 
(
    select *, row_number() over(partition by Purchase_order_number order by create_time desc) rownum from STG_OMS.Purchase_To_SAP 
)s 
ON b.Purchase_order_number=s.Purchase_order_number
and s.rownum = 1;
END

GO
