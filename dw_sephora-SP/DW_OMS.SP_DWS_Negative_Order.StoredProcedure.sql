/****** Object:  StoredProcedure [DW_OMS].[SP_DWS_Negative_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DWS_Negative_Order] AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-01-27       tali           delete collate
-- ========================================================================================
truncate table DW_OMS.DWS_Negative_Order;
with refund_order as 
(
    select  
        a.*,
        coalesce(so.store_id, a.store_id) as store_cd,
        coalesce(so.channel_id, a.channel_id) as channel_cd,
        coalesce(so.payment_time, a.pay_time) as payment_time,
        case when b.online_return_apply_order_sys_id is not null then b.purchase_order_number
            when c.oms_refund_apply_order_sys_id is not null then c.purchase_order_number
            else null 
        end as purchase_order_number,
        case when b.online_return_apply_order_sys_id is not null then b.item_name
            when c.oms_refund_apply_order_sys_id is not null then c.item_name
            else null 
        end as item_sku_name,
        case when b.online_return_apply_order_sys_id is not null then b.item_sku_cd
            when c.oms_refund_apply_order_sys_id is not null then c.item_sku_cd
            
            else null 
        end as item_sku_cd,
        case when b.online_return_apply_order_sys_id is not null then b.purchase_apply_qty
            when c.oms_refund_apply_order_sys_id is not null then c.item_apply_qty
            
            else null 
        end as item_apply_qty,
        case when b.online_return_apply_order_sys_id is not null then b.item_apply_unit_price
            when c.oms_refund_apply_order_sys_id is not null then c.item_sales_price
            
            else null 
        end as item_apply_unit_price,
        case when b.online_return_apply_order_sys_id is not null then b.item_apply_amount
            when c.oms_refund_apply_order_sys_id is not null then c.item_amount
            
            else null 
        end as item_apply_amount
    from
        stg_oms.oms_order_refund a
    left join
        stg_oms.sales_order so
    on a.oms_order_code = so.sales_order_number
    left join
        dw_oms.dws_online_return_apply_order b
    on a.online_return_apply_order_sys_id = b.online_return_apply_order_sys_id
    and a.online_return_apply_order_sys_id is not null
    left join
        dw_oms.dws_oms_refund_apply_order c
    on a.oms_refund_apply_order_sys_id = c.oms_refund_apply_order_sys_id
    and a.oms_refund_apply_order_sys_id is not null
)

insert into DW_OMS.DWS_Negative_Order
select 
    t.oms_order_refund_sys_id,
    t.oms_refund_apply_order_sys_id,
    t.online_return_apply_order_sys_id,
    t.oms_order_return_sys_id,
    t.order_cancellation_sys_id,
    t.oms_order_sys_id,
    t.basic_status,
    t.oms_order_code as sales_order_number,
    t.store_cd,
    t.channel_cd,
    t.payment_time,
    t.refund_no,
    t.refund_sum,
    t.refund_status,
    t.refund_op,
    t.refund_type,
    t.refund_time,
    t.refund_reason,
    t.refund_mobile,
    t.refund_source,
    t.defult_product_fee,
    t.defult_post_fee,
    t.defult_sum as defult_amount,
    t.product_fee,
    t.delivery_fee,
    t.customer_post_fee,
    t.seller_post_fee,
    t.exp_indemnity,
    t.product_in_status,
    t.product_out_status,
    t.account_name,
    null as account_number,
    t.account_bank,
    t.payment_method,
    t.payment_transaction_id,
    t.alipay_account,
    t.customer_name,
    t.pay_method_order_no,
    t.batch_number,
    t.update_reason,
    t.assign_to,
    t.serivice_note,
    t.financial_remark,
    t.comments,
    t.related_order_code,
    t.super_order_id,
    t.tmall_refund_id,
    t.offline_flag,
    t.return_pos_flag,
    t.apply_time,
    t.purchase_order_number as purchase_order_number,
    po.order_internal_status as purchase_order_status,
    case when po.order_internal_status in ('SHIPPED','SIGNED') and t.refund_type in('FULL_ITEM_REFUND') then N'整单取消退款'
         when po.order_internal_status in ('SHIPPED','SIGNED') and t.refund_type in('RETURN_REFUND') then N'退货退款'
         when po.order_internal_status in ('SHIPPED','SIGNED') and t.refund_type in('ONLINE_RETURN_REFUND') then N'线上退货退款'
         when po.order_internal_status is null then 'NO DETAIL'
    else i.order_status_cn end as negative_type,
    -- coalesce(m.sync_type, n.sync_type) as sync_type,
    -- coalesce(m.sync_status, n.sync_status) as sync_status,
    -- coalesce(m.sync_time, n.sync_time) as sync_time,
    -- coalesce(m.invoice_id, n.invoice_id) as invoice_id,
    -- coalesce(m.return_id, n.return_id) as return_id,
    coalesce(m.sync_type, n.sync_type, o.sync_type) as sync_type,
    coalesce(m.sync_status, n.sync_status, o.sync_status) as sync_status,
    coalesce(m.sync_time, n.sync_time, o.sync_time) as sync_time,
    coalesce(m.invoice_id, n.invoice_id, o.invoice_id) as invoice_id,
    coalesce(m.return_id, n.return_id, o.return_id) as return_id,
    t.item_sku_name,
    t.item_sku_cd,
    t.item_apply_qty,
    t.item_apply_unit_price,
    t.item_apply_amount,
    t.create_time as create_time,
    t.update_time as update_time,
    t.version,
    t.is_delete,
    current_timestamp as insert_timestamp
from
    refund_order t
left join 
    stg_oms.purchase_order po
on t.purchase_order_number = po.purchase_order_number
left join 
(
    select * from  stg_oms.oms_sync_orders_to_sap where oms_order_refund_sys_id is not null
)m
on t.oms_order_refund_sys_id = m.oms_order_refund_sys_id
and t.purchase_order_number = m.purchase_order_number
left join 
(
    select * from  stg_oms.oms_sync_orders_to_sap where oms_order_refund_sys_id is null and sync_type in ('RETURN','ONLINE_RETURN')
)n
on t.oms_order_refund_sys_id = n.oms_order_sys_id
and t.purchase_order_number = n.purchase_order_number
left join 
(
    select * from  stg_oms.oms_sync_orders_to_sap where oms_order_refund_sys_id is null and sync_type not in ('RETURN','ONLINE_RETURN')
) o
on t.oms_order_sys_id = o.oms_order_sys_id
and t.purchase_order_number = o.purchase_order_number
left join
    dw_oms.DIM_Purchase_Order_Status i
on po.order_internal_status = i.order_status_en
where store_cd<>'GWP001'
;
end

GO
