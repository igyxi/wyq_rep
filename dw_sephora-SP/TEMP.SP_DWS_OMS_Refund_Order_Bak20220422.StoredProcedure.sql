/****** Object:  StoredProcedure [TEMP].[SP_DWS_OMS_Refund_Order_Bak20220422]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_OMS_Refund_Order_Bak20220422] AS
BEGIN
truncate table DW_OMS.DWS_OMS_Refund_Order;
with refund_order as
(
    select 
        a.*,
        coalesce(m.purchase_order_number,n.purchase_order_number) as purchase_order_number,
        coalesce(m.sync_type,n.sync_type) as sync_type,
        coalesce(m.sync_status,n.sync_status) as sync_status,
        coalesce(m.sync_time,n.sync_time) as sync_time,
        coalesce(m.invoice_id,n.invoice_id) as invoice_id,
        coalesce(m.return_id,n.return_id) as return_id
    from
        STG_OMS.OMS_Order_Refund a
    left join 
        STG_OMS.OMS_Sync_Orders_To_Sap m
    on a.oms_order_refund_sys_id = m.oms_order_refund_sys_id
    left join 
        STG_OMS.OMS_Sync_Orders_To_Sap n
    on a.oms_order_refund_sys_id = n.oms_order_sys_id
)

insert into [DW_OMS].[DWS_OMS_Refund_Order]
select 
    t.oms_order_refund_sys_id,
    t.oms_refund_apply_order_sys_id,
    t.online_return_apply_order_sys_id,
    t.oms_order_return_sys_id,
    t.order_cancellation_sys_id,
    t.oms_order_sys_id,
    t.basic_status,
    t.oms_order_code as sales_order_number,
    t.refund_no,
    t.refund_sum,
    t.refund_status,
    t.refund_op,
    t.refund_type,
    t.refund_time,
    t.refund_reason,
    t.refund_mobile,
    t.refund_source,
    t.customer_post_fee,
    t.seller_post_fee,
    t.exp_indemnity,
    t.product_in_status,
    t.product_out_status,
    t.account_name,
    t.account_number,
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
    coalesce(t.source_order_code, t.purchase_order_number, d.purchase_order_number) as purchase_order_number,
    t.sync_type,
    t.sync_status,
    t.sync_time,
    t.invoice_id,
    t.return_id,
    case when b.online_return_apply_order_sys_id is not null then b.item_name
         when c.oms_refund_apply_order_sys_id is not null then c.item_name
         when d.oms_refund_apply_order_sys_id is not null then d.item_name
        else null 
    end as item_sku_name,
    case when b.online_return_apply_order_sys_id is not null then b.item_sku_cd
         when c.oms_refund_apply_order_sys_id is not null then c.item_sku_cd
         when d.oms_refund_apply_order_sys_id is not null then d.item_sku_cd
        else null 
    end as item_sku_cd,
    case when b.online_return_apply_order_sys_id is not null then b.purchase_apply_qty
         when c.oms_refund_apply_order_sys_id is not null then c.item_apply_qty
         when d.oms_refund_apply_order_sys_id is not null then d.item_apply_qty
        else null 
    end as item_apply_qty,
    case when b.online_return_apply_order_sys_id is not null then b.item_apply_unit_price
         when c.oms_refund_apply_order_sys_id is not null then c.item_sales_price
         when d.oms_refund_apply_order_sys_id is not null then d.item_sales_price
        else null 
    end as item_apply_unit_price,
    case when b.online_return_apply_order_sys_id is not null then b.item_apply_amount
         when c.oms_refund_apply_order_sys_id is not null then c.item_amount
         when d.oms_refund_apply_order_sys_id is not null then d.item_amount
        else null 
    end as item_apply_amount,
    t.create_time as create_time,
    t.update_time as update_time,
    t.version,
    t.is_delete,
    current_timestamp as insert_timestamp
from
    refund_order t
left join
    [DW_OMS].[DWS_Online_Return_Apply_Order] b
on t.online_return_apply_order_sys_id = b.online_return_apply_order_sys_id
and t.purchase_order_number = b.purchase_order_number
and t.online_return_apply_order_sys_id is not null
left join
(
    select * from [DW_OMS].[DWS_OMS_Refund_Apply_Order] where purchase_order_number is not null
)c
on t.oms_refund_apply_order_sys_id = c.oms_refund_apply_order_sys_id
and t.purchase_order_number = c.purchase_order_number
and t.oms_refund_apply_order_sys_id is not null
left join
    [DW_OMS].[DWS_OMS_Refund_Apply_Order] d
on t.oms_refund_apply_order_sys_id = c.oms_refund_apply_order_sys_id
and c.oms_refund_apply_order_sys_id is null
and t.oms_refund_apply_order_sys_id is not null
;
END 

GO
