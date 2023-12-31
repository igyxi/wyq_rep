/****** Object:  StoredProcedure [TEMP].[SP_DWS_Refund_Order_Bak20220720]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Refund_Order_Bak20220720] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-09       tali        Initial Version
-- ========================================================================================
truncate table DW_OMS.DWS_Refund_Order;
with refund_order as 
(
    select 
        a.refund_no,
        a.oms_order_sys_id,
        a.oms_order_refund_sys_id,
        si.channel_id as channel_code,
        si.store_id as sub_channel_code,
        a.refund_status,
        a.refund_type,
        a.refund_reason,
        a.apply_time,
        a.refund_time,
        a.refund_sum  as refund_amount,
        a.product_fee as product_amount,
        a.delivery_fee as delivery_amount,
        a.refund_mobile,
        a.comments,
        a.return_pos_flag,
        a.oms_order_code as sales_order_number,
        case when b.online_return_apply_order_sys_id is not null then b.purchase_order_number
            when c.oms_refund_apply_order_sys_id is not null then c.purchase_order_number
            else null 
        end as purchase_order_number,
        case when b.online_return_apply_order_sys_id is not null then b.skuCode
            when c.oms_refund_apply_order_sys_id is not null then c.sku_code
            else null 
        end as item_sku_code,
        case when b.online_return_apply_order_sys_id is not null then b.skuName
            when c.oms_refund_apply_order_sys_id is not null then c.sku_name
            else null 
        end as item_sku_name,
        case when b.online_return_apply_order_sys_id is not null then b.applyQty
            when c.oms_refund_apply_order_sys_id is not null then c.qty
            else null 
        end as item_qauntity,
        case when b.online_return_apply_order_sys_id is not null then b.total_amount
            when c.oms_refund_apply_order_sys_id is not null then c.total_amount
            else null 
        end as item_total_amount,
        case when b.online_return_apply_order_sys_id is not null then b.apportion_amount
            when c.oms_refund_apply_order_sys_id is not null then c.apportion_amount
            else null 
        end as item_apportion_amount,
        case when b.online_return_apply_order_sys_id is not null then b.discount_amount
            when c.oms_refund_apply_order_sys_id is not null then c.discount_amount
            else null 
        end as item_discount_amount,
        a.create_time as create_time,
        a.update_time as update_time,
        a.is_delete
    from
    (
        select *, row_number() over(partition by refund_no order by refund_time desc) rownum from stg_oms.oms_order_refund
    )a
    left join 
        STG_OMS.OMS_Store_Info si
    on a.store_id = si.store_id
    left join
    (
        select 
            online_return_apply_order_sys_id,
            purchase_order_number,
            skuCode,
            max(skuName) as skuName,
            sum(applyQty) as applyQty,
            sum(apportion_amount) as apportion_amount,
            sum(total_amount) as total_amount,
            sum(discount_amount) as discount_amount
        from
        (
            select 
                online_return_apply_order_sys_id, 
                purchase_order_number, 
                skuCode, 
                skuName,
                applyQty, 
                apportionAmountUnit * applyQty as apportion_amount, 
                salePriceUnit * applyQty as total_amount,
                (salePriceUnit - apportionAmountUnit) * applyQty as discount_amount
            from STG_OMS.Online_Return_Apply_Order_Item
                CROSS APPLY OPENJson(po_info) as root 
                    cross APPLY openjson(root.value)
                    with (
                        purchase_order_number nvarchar(512) '$.purchaseOrderNumber',
                        skuCode nvarchar(512) '$.skuCode',
                        skuName nvarchar(512) '$.skuName',
                        apportionAmountUnit decimal(20,5) '$.apportionAmountUnit',
                        salePriceUnit decimal(20,5) '$.salePriceUnit',
                        applyQty int '$.applyQty'
                    )
        ) t
        group by 
            online_return_apply_order_sys_id,
            purchase_order_number,
            skuCode
    ) b
    on a.online_return_apply_order_sys_id = b.online_return_apply_order_sys_id
    and a.online_return_apply_order_sys_id is not null
    left join
    (
        select 
            t0.oms_order_code as sales_order_number,
            t0.source_order_code as purchase_order_number,
            t1.oms_refund_apply_order_sys_id,
            t1.sku_code,
            max(t1.sku_name) as sku_name,
            sum(t1.qty) as qty,
            sum(abs(t1.total_price)) as apportion_amount,
            sum(abs(t1.total_adjustment)) as discount_amount,
            sum(t1.total_price) - sum(abs(t1.total_adjustment)) as total_amount
        from
            STG_OMS.OMS_Refund_Order_Items t1
        join
            STG_OMS.OMS_Refund_Apply_Order t0
        on 
            t0.oms_refund_apply_order_sys_id = t1.oms_refund_apply_order_sys_id
        group by 
            t0.oms_order_code,
            t0.source_order_code,
            t1.oms_refund_apply_order_sys_id,
            t1.sku_code
    ) c
    on a.oms_refund_apply_order_sys_id = c.oms_refund_apply_order_sys_id
    and a.oms_refund_apply_order_sys_id is not null
    where a.refund_no is not null and a.rownum = 1 and a.refund_status = 'REFUNDED'
)

insert into DW_OMS.DWS_Refund_Order
select 
    t.refund_no,
    t.channel_code,
    t.sub_channel_code,
    t.refund_status,
    t.refund_type,
    t.refund_reason,
    t.apply_time,
    t.refund_time,
    t.refund_amount,
    t.product_amount,
    t.delivery_amount,
    t.refund_mobile,
    t.comments,
    t.return_pos_flag,
    t.sales_order_number,
    t.purchase_order_number,
    t.item_sku_code,
    t.item_sku_name,
    t.item_qauntity,
    t.item_total_amount,
    t.item_apportion_amount,
    t.item_discount_amount,
    coalesce(m.sync_type, n.sync_type, o.sync_type) as sync_type,
    coalesce(m.sync_status, n.sync_status, o.sync_status) as sync_status,
    coalesce(m.sync_time, n.sync_time, o.sync_time) as sync_time,
    coalesce(m.invoice_id, n.invoice_id, o.invoice_id) as invoice_id,
    t.create_time,
    t.update_time,
    t.is_delete,
    CURRENT_TIMESTAMP
from 
    refund_order t
left join 
(
    select 
        *, 
        row_number() over( partition by oms_order_refund_sys_id, purchase_order_number order by create_time desc) rownum 
    from
        stg_oms.oms_sync_orders_to_sap 
    where 
        oms_order_refund_sys_id is not null
)m
on t.oms_order_refund_sys_id = m.oms_order_refund_sys_id
and t.purchase_order_number = m.purchase_order_number
and m.rownum = 1
left join 
(
    select 
        *, 
        row_number() over( partition by oms_order_sys_id, purchase_order_number order by create_time desc) rownum 
    from 
        stg_oms.oms_sync_orders_to_sap 
    where 
        oms_order_refund_sys_id is null 
        and sync_type in ('RETURN','ONLINE_RETURN')
)n
on t.oms_order_refund_sys_id = n.oms_order_sys_id
and t.purchase_order_number = n.purchase_order_number
and n.rownum = 1
left join 
(
    select *, row_number() over( partition by oms_order_sys_id, purchase_order_number order by create_time desc) rownum 
    from 
        stg_oms.oms_sync_orders_to_sap 
    where
        oms_order_refund_sys_id is null 
        and sync_type not in ('RETURN','ONLINE_RETURN')
) o
on t.oms_order_sys_id = o.oms_order_sys_id
and t.purchase_order_number = o.purchase_order_number
and o.rownum = 1
END
GO
