/****** Object:  StoredProcedure [DW_OMS].[SP_DWS_OMS_Sync_To_SAP]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_DWS_OMS_Sync_To_SAP] AS
BEGIN
truncate table [DW_OMS].[DWS_OMS_Sync_To_SAP];
insert into DW_OMS.DWS_OMS_Sync_To_SAP
select
    b.oms_sync_orders_to_sap_sys_id,
    b.oms_order_sys_id,
    b.purchase_order_number,
    b.sync_type,
    b.sync_status,
    b.sync_time,
    b.invoice_id,
    b.return_id,
    b.oms_order_refund_sys_id,
    b.oms_exchange_apply_order_sys_id,
    case when d.oms_refund_apply_order_sys_id is not null then d.item_sku_cd
         when e.online_return_apply_order_sys_id is not null then e.item_sku_cd
        --  when f.oms_exchange_apply_order_sys_id is not null then f.item_sku_cd
    end as item_sku_cd,
    case when d.oms_refund_apply_order_sys_id is not null then d.item_apply_qty
         when e.online_return_apply_order_sys_id is not null then e.purchase_apply_qty
        --  when f.oms_exchange_apply_order_sys_id is not null then f.item_qty
    end as item_qty,
    case when d.oms_refund_apply_order_sys_id is not null then d.item_amount
         when e.online_return_apply_order_sys_id is not null then e.purchase_apply_qty * e.item_apply_unit_price
        --  when f.oms_exchange_apply_order_sys_id is not null then f.item_total_price
    end as item_total_price,
    b.create_time,
    b.update_time,
    current_timestamp as insert_timestamp
from 
    STG_OMS.OMS_Sync_Orders_To_Sap b
left join
    STG_OMS.OMS_Order_Refund c
on b.oms_order_refund_sys_id = c.oms_order_refund_sys_id
and b.oms_order_refund_sys_id is not null
left join 
    DW_OMS.DWS_OMS_Refund_Apply_Order d
on c.oms_refund_apply_order_sys_id  = d.oms_refund_apply_order_sys_id
and c.oms_refund_apply_order_sys_id is not null
left join
(
    select * from DW_OMS.DWS_Online_Return_Apply_Order
) e
on c.online_return_apply_order_sys_id = e.online_return_apply_order_sys_id
and c.online_return_apply_order_sys_id is not null;

END 

GO
