/****** Object:  StoredProcedure [DWD].[SP_Fact_Exchange_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_Fact_Exchange_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-16       wangzhichun           Initial Version
-- ========================================================================================
truncate table DWD.Fact_Exchange_Order;
insert into DWD.Fact_Exchange_Order
select 
    a.sales_order_number,
    a.purchase_order_number,
    a.related_order_number,
    s.invoice_id as invoice_id,
    a.order_internal_status as order_status,
    a.[type] as order_type,
    a.member_id,
    a.member_card,
    case when a.store_id = 'S001' then a.channel_id
        when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006'
        else a.store_id
    end as sub_channel_code,
    si.channel_id as channel_code,
    m.store_code as store_code,
    a.order_time,
    a.shipping_time,
    a.payed_amount as payment_amount,
    a.merge_flag as sub_type_code,
    a.smartba_flag as is_smartba,
    replace(replace(b.item_sku,'?',''), char(160), '') as item_sku_code,
    b.item_name as item_sku_name,
    b.item_type,
    b.item_quantity,
    b.item_sale_price,
    b.apportion_amount as item_apportion_amount,
    b.item_adjustment_total as item_discount_amount,
    t.old_sku_code as exchange_sku_code,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    STG_OMS.Purchase_Order a
left join
    STG_OMS.Purchase_Order_Item b
on a.purchase_order_sys_id = b.purchase_order_sys_id
left join
    STG_OMS.Purchase_To_SAP s
on a.purchase_order_sys_id = s.purchase_order_sys_id
left join
    STG_OMS.OMS_Store_Info si
on case when a.store_id = 'TMALL001' and a.shop_id = 'TM2' then 'TMALL006' else a.store_id end = si.store_id
left join
    STG_OMS.OMS_Store_Mapping m
on a.store_id = m.store_id
and a.order_actual_ware_house = m.warehouse
left join
(
    select c.oms_order_code, c.source_order_code, c.sap_exchange_number, d.sku_code, d.old_sku_code
    from STG_OMS.OMS_Exchange_Apply_Order c
    left join STG_OMS.OMS_Exchange_Apply_Order_Item d
    on c.oms_exchange_apply_order_sys_id = d.oms_exchange_apply_order_sys_id
    and d.item_kind = 'AE'
    group by c.oms_order_code, c.source_order_code, c.sap_exchange_number, d.sku_code, d.old_sku_code
) t
on a.sales_order_number = t.oms_order_code
and a.related_order_number = t.source_order_code
and a.purchase_order_number = t.sap_exchange_number
and b.item_sku = t.sku_code
where a.[type] = 2
and (a.split_type <> 'SPLIT_ORIGIN' or a.split_type is null)
END

GO
