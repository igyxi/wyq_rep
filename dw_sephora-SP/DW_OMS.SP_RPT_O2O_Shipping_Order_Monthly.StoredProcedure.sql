/****** Object:  StoredProcedure [DW_OMS].[SP_RPT_O2O_Shipping_Order_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_OMS].[SP_RPT_O2O_Shipping_Order_Monthly] @dt [VARCHAR](10) AS
delete from [DW_OMS].[RPT_O2O_Shipping_Order_Monthly] where mth = substring(@dt,1,7);
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-01-27       tali           delete collate
-- ========================================================================================
with po as 
(
    select       
        a.purchase_order_item_sys_id, 
        a.purchase_order_number,
        b.sales_order_sys_id,
        cast(b.order_time as date) as order_date,
        cast(a.pos_sync_time as date) as pos_date,
        case when oss.status is not null and oss.status = 'CANCELLED' and oss. process_time is not null then cast(oss.process_time as date) else null end as cancel_date,
        cast(a.ors_create_time as date) as store_sales_date,
        a.invoice_id,
        case a.internal_status
            when 'CANT_CONTACTED' then N'联系不到客户'
            when 'PENDING' then N'等待处理'
            when 'DELIVERY_FAILURE' then N'配送失败'
            when 'SHIPPED' then N'已发货'
            when 'SPLITED' then N'已拆分'
            when 'WAIT_STKOUT' then N'下发出库单'
            when 'EXCEPTION' then N'异常'
            when 'REJECTED' then N'拒收'
            when 'WAIT_PROCESS' then N'等待csr处理'
            when 'CANCELLED' then N'取消'
            when 'WAIT_JDPROCESS' then N'京东待处理'
            when 'SIGNED' then N'已签收'
            when 'WAIT_SAPPROCESS' then N'等待sap处理'
            when 'PARTAIL_CANCEL' then N'部分取消'
            else '' 
        end as order_status,
        a.item_sale_price,
        a.item_apportion_unit_price,
        a.item_quantity,
        a.item_apportion_amount,
        a.item_sku_cd,
        replace(a.item_name, '\r', '') as item_name,
        a.member_card as oms_member_card,
        b.buyer_memo as store,
        substring(b.buyer_memo,1,4) as store_id,
        case when a.type_cd = 8 then 'COD' else c.payment_method end as payment_method,
        a.order_actual_ware_house,
        a.province,
        a.city,
        a.item_delivery_flag,
        a.basic_status
    from
    (
        select 
            * 
        from 
            [DW_OMS].[DWS_Purchase_Order]
        where 
            create_time > '2018-08-26' 
        and channel_cd = 'O2O'
        and split_type <>'SPLIT_ORIGIN'
        and item_type in('NORMAL','VALUE_SET','BUNDLE') 
        and item_apportion_unit_price <> 0 
    ) a
    left join 
        [STG_OMS].[OMS_Sap_Shipping] oss
    on 
        a.purchase_order_number = oss.order_id
    left join 
        [STG_OMS].[Sales_Order] b
    on 
        a.sales_order_sys_id = b.sales_order_sys_id
    left join 
        [STG_OMS].[Sales_Order_Payment] c
    on 
        b.sales_order_sys_id = c.sales_order_sys_id
    where 
        c.payment_status = 'PAID'
),
sap_po as 
(
    select 
        b.oms_order_refund_sys_id,
        b.oms_exchange_apply_order_sys_id,
        b.sync_type,
        cast(b.sync_time as date) as store_sales_date,
        po.sales_order_sys_id,
        po.purchase_order_item_sys_id,
        po.purchase_order_number,
        po.order_date,
        po.pos_date,
        po.cancel_date,
        po.invoice_id,
        po.order_status,
        po.item_sale_price,
        po.item_apportion_unit_price,
        po.item_quantity,
        po.item_apportion_amount,
        po.item_sku_cd,
        po.item_name,
        po.oms_member_card,
        po.store,
        po.store_id,
        po.payment_method,
        po.order_actual_ware_house,
        po.province,
        po.city,
        po.item_delivery_flag,
        po.basic_status
    from 
    (
        select 
            purchase_order_number,
            oms_order_refund_sys_id,
            oms_exchange_apply_order_sys_id,
            sync_time,
            sync_type
        from 
            [STG_OMS].[OMS_Sync_Orders_To_SAP]
        where 
            sync_status = 'Y'
            and cast(sync_time as date) between DATEADD(DD,1,EOMONTH(@dt, -1)) and @dt
            and sync_type in  ('REJECT','RETURN','EXCHANGE_RETURN')
    ) b
    join 
        po 
    on b.purchase_order_number = po.purchase_order_number                         
)

insert into DW_OMS.RPT_O2O_Shipping_Order_Monthly
select 
    substring(@dt,1,7) as statistic_month,
    t.order_number,
    t.order_date,
    t.pos_date,
    t.cancel_date,
    t.store_sales_date,
    t.invoice_id,
    t.order_status,
    t.item_sale_price,
    t.item_apportion_unit_price,
    t.item_quantity,
    t.item_apportion_amount,
    t.item_sku_cd,
    t.item_name,
    i.item_brand,
    i.item_category,
    t.oms_member_card,
    t.payment_method,
    t.order_actual_ware_house,
    t.province,
    t.city,
    t.store,
    t.store_id,
    current_timestamp as insert_timestamp,
    substring(@dt,1,7) as mth
from 
(
    select 
        po.purchase_order_number as order_number,
        po.sales_order_sys_id,
        po.order_date,
        po.pos_date,
        po.cancel_date,
        po.store_sales_date,
        po.invoice_id,
        po.order_status,
        po.item_sale_price,
        po.item_apportion_unit_price,
        po.item_quantity,
        po.item_apportion_amount,
        po.item_sku_cd,
        po.item_name,
        po.oms_member_card,
        po.payment_method,
        po.order_actual_ware_house,
        po.province,
        po.city,
        po.store,
        po.store_id
    from 
        po
    where 
        po.store_sales_date is not null
    and po.pos_date between DATEADD(DD,1,EOMONTH(@dt, -1)) and @dt 
    and po.item_delivery_flag<>0 
    
    union all
    select
        cast(isnull(try_cast(sap_po.purchase_order_number as bigint),0) + 400000000 as varchar) as order_number,
        sap_po.sales_order_sys_id,
        sap_po.order_date,
        sap_po.pos_date,
        sap_po.cancel_date,
        sap_po.store_sales_date,
        sap_po.invoice_id,
        sap_po.order_status,
        sap_po.item_sale_price,
        sap_po.item_apportion_unit_price,
        sap_po.item_quantity,
        sap_po.item_apportion_amount,
        sap_po.item_sku_cd,
        sap_po.item_name,
        sap_po.oms_member_card,
        sap_po.payment_method,
        sap_po.order_actual_ware_house,
        sap_po.province,
        sap_po.city,
        sap_po.store,
        sap_po.store_id
    from
        sap_po
    where 
        sap_po.sync_type = 'REJECT'

    union all
    select
        cast(isnull(try_cast(b.purchase_order_number as bigint),0) + 400000000 as varchar) as order_number,
        b.sales_order_sys_id,
        b.order_date,
        b.pos_date,
        b.cancel_date,
        b.store_sales_date,
        b.invoice_id,
        b.order_status,
        b.item_sale_price,
        0- b.item_apportion_unit_price,
        d.item_quantity as item_quantity,
        0 - b.item_apportion_unit_price * d.item_quantity,
        d.item_sku as item_sku_cd,
        b.item_name,
        b.oms_member_card,
        b.payment_method,
        b.order_actual_ware_house,
        b.province,
        b.city,
        b.store,
        b.store_id
    from 
    (
        select * from sap_po where sync_type = 'RETURN'
    ) b
    left join 
        [STG_OMS].[OMS_Order_Return] c
    on c.source_order_code = b.purchase_order_number
    left join
        [STG_OMS].[OMS_Order_Return_Item] d
    on d.oms_order_return_sys_id = c.oms_order_return_sys_id
    and d.oms_order_item_sys_id = b.purchase_order_item_sys_id

    union all
    select 
        cast(isnull(try_cast(b.purchase_order_number as bigint),0) + 400000000 as varchar) as order_number,
        b.sales_order_sys_id,
        b.order_date,
        b.pos_date,
        b.cancel_date,
        b.store_sales_date,
        b.invoice_id,
        b.order_status,
        b.item_sale_price,
        0-b.item_apportion_unit_price,
        c.item_qty,
        0-b.item_apportion_amount*c.item_qty,
        b.item_sku_cd,
        b.item_name,
        b.oms_member_card,
        b.payment_method,
        b.order_actual_ware_house,
        b.province,
        b.city,
        b.store,
        b.store_id
    from 
    (
        select * from sap_po where sync_type = 'EXCHANGE_RETURN'
    ) b
    join 
    (
        select * from [DW_OMS].[DWS_OMS_Exchange_Apply_Order] where process_status = 'APPROVED' and item_kind = 'BE'
    ) c
    on c.purchase_order_number = b.purchase_order_number
    and c.item_sku_cd = b.item_sku_cd
) t
left join
    [STG_OMS].[Sales_Order_Item] i
on t.item_sku_cd = i.item_sku
and t.sales_order_sys_id = i.sales_order_sys_id

END



GO
