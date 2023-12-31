/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_OMS_Return_Exchange_Order_Daily]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_OMS_Return_Exchange_Order_Daily] AS
BEGIN
truncate table DW_OMS.RPT_OMS_Return_Exchange_Order_Daily;
insert into DW_OMS.RPT_OMS_Return_Exchange_Order_Daily
select 
    reo.refund_exchange_date,
    bt.store_cd,
    reo.sales_order_number,
    reo.purchase_order_number,
    reo.return_id as refund_order_number,
    bt.order_time as original_order_time,
    bt.order_date as original_order_date,
    reo.refund_amount,
    reo.refund_shipping_fee,
    reo.refund_sku_code,
    reo.refund_sku_amount,
    reo.return_type,
    reo.apply_reason,
    reo.apply_comment,
    current_timestamp as inser_timestamp
from 
(	
    select 
        format(ro.create_time,'yyyy-MM-dd') as refund_exchange_date,
        ro.sales_order_number,
        ro.purchase_order_number,
        ro.refund_amount as refund_amount,
        ra.item_sku_code as refund_sku_code,
        ra.apply_total_price as refund_sku_amount,
        ro.delivery_fee as refund_shipping_fee,
        ra.return_type,
        ra.return_reason as apply_reason,
        ra.apply_comment,
		ra.return_id
    from 
    (
        select 
            refund_no as refund_number,
            oms_order_code as sales_order_number,
            source_order_code as purchase_order_number,
            refund_sum as refund_amount,
            delivery_fee,
            create_time
        from 
            [STG_OMS].[OMS_Order_Refund]
        where 
            refund_type = 'RETURN_REFUND'
    ) ro
    left join
    (
        select 
            rao.oms_return_apply_order_sys_id,
            rao.sales_order_number,
            rao.return_number as refund_number,
            rao.return_type,
            rao.return_reason,
            rao.apply_comment,
            rao.item_sku_code,
            rao.item_total_price as apply_total_price,
            rao.source,
            sync.return_id
        from  
            [DW_OMS].[DWS_OMS_Return_Apply_Order] rao
        left join
            [STG_OMS].[OMS_Sync_Orders_To_SAP] sync
        on rao.oms_return_apply_order_sys_id = sync.oms_order_refund_sys_id
        where 
            rao.item_sku_flag = 1
            or rao.source = 'RETURN_REFUND'
    )ra
    on ro.refund_number = ra.refund_number

    union all

    select 
        format(a.create_time,'yyyy-MM-dd') as refund_exchange_date,
        a.sales_order_number,
        a.purchase_order_number,
        0 as refund_amount,
        a.item_sku_cd as refund_sku_code,
        0 as refund_sku_amount,
        0 as refund_shipping_fee, 
        'EXCHANGE' as type_of_return,
        a.exchange_reason as apply_reason,
        a.apply_comment,
		b.return_id
    from 
    (
        select 
            oms_exchange_apply_order_sys_id,
            sales_order_number,
            purchase_order_number,
            exchange_reason,
            apply_comment,
            create_time,
            item_sku_cd
        from 
            [DW_OMS].[DWS_OMS_Exchange_Apply_Order]
        where 
            item_kind = 'BE'
        and process_status = 'APPROVED'
    ) a
    left join
        [STG_OMS].[OMS_Sync_Orders_To_SAP] b
    on a.oms_exchange_apply_order_sys_id = b.oms_exchange_apply_order_sys_id
) reo
left join
(
    select 
        purchase_order_number,
        store_id as store_cd, 
        case when order_time = '1970-01-01 00:00:00' then null else order_time end as order_time,
        case when format(order_time,'yyyy-MM-dd') = '1970-01-01' then null else format(order_time,'yyyy-MM-dd') end as order_date
    from 
        [STG_OMS].[Purchase_Order]
) bt
on reo.purchase_order_number = bt.purchase_order_number;
END 
GO
