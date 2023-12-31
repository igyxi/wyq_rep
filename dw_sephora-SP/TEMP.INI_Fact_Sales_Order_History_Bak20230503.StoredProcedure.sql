/****** Object:  StoredProcedure [TEMP].[INI_Fact_Sales_Order_History_Bak20230503]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[INI_Fact_Sales_Order_History_Bak20230503] AS
BEGIN
truncate table DWD.Fact_Sales_Order_History;
insert into DWD.Fact_Sales_Order_History 
select
    cast(trans_id as nvarchar) as sales_order_number,
    invc_no as purchase_order_number,
    invc_id,
    channel_code,
    channel_name,
    sub_channel_code,
    sub_channel_name,
    store_code,
    province,
    city,
    null as district,
    trans_type,
    member_card,
    null as member_card_grade,
    null as order_status,
    order_time,
    null as payment_status,
    sap_time  as payment_time,
    1 as is_placed,
    sap_time as place_time,
    0 as is_smartba,
    item_sku_code,
    max(item_sku_name) as item_sku_name,
    sum(item_quantity) as item_quantity,
    sum(item_total_amount) as item_total_amount,
    sum(item_apportion_amount) as item_apportion_amount,
    sum(item_discount_amount) as item_discount_amount,
    null as item_animation_name,
    null as virtual_sku_code,
    null as virtual_quantity,
    null as virtual_apportion_amount,
    null as virtual_discount_amount,
    null as virtual_bind_quantity,
    null as shipping_time,
    null as shipping_amount,
    null as def_ware_house,
    null as actual_warehouse,
    null as pos_synctime,
    null as pos_sync_status,
    null as sap_transaction_number,
    null as SAP_QTY,
    null as SAP_AMOUNT,
    null as sap_store_code,
    invc_no as crm_invc_no,
    trans_type as crm_trans_type,
    order_time as crm_trans_time,
    null as crm_qty,
    null as crm_amount,
    'CRM' as source,
    CURRENT_TIMESTAMP
FROM 
    DW_CRM.DWS_Trans_Order_With_SKU t
left join
    DWD.Dim_Animation a
on t.item_sku_code = a.sku_code
and t.sap_time between a.Start_Date and a.End_Date
where 
    order_time < '2019-01-01'
and item_quantity >= 0
group by 
    trans_id,
    invc_no,
    invc_id,
    channel_code,
    channel_name,
    sub_channel_code,
    sub_channel_name,
    store_code,
    province,
    city,
    trans_type,
    member_card,
    order_time,
    sap_time,
    item_sku_code
END

GO
