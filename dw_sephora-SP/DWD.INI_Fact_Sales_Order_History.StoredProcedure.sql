/****** Object:  StoredProcedure [DWD].[INI_Fact_Sales_Order_History]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[INI_Fact_Sales_Order_History] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-12-30       wangzhichun    Initial Version
-- 2023-05-03       tali           update
-- ========================================================================================
truncate table DWD.Fact_Sales_Order_History;
insert into DWD.Fact_Sales_Order_History 
select
    cast(trans_id as nvarchar) as sales_order_number,
    case when s.channel_code is null then '66' + invc_no else invc_no end as purchase_order_number,
    invc_id,
    case when t.channel_code in ('JDDJ', 'DIANPING', 'MEITUAN') then t.channel_code
         when t.channel_code is not null then 'SOA'
         when s.channel_code is null then 'OFF_LINE'
         else s.channel_code 
    end as channel_code,
    case when t.channel_code in ('JDDJ', 'DIANPING', 'MEITUAN') then t.channel_name
         when t.channel_code is not null then N'官网'
         when s.channel_code is null then N'线下'
         else s.channel_name 
    end as channel_name,
    case when t.channel_code is not null then t.channel_code
        when s.sub_channel_code is null then 'OFF_LINE' 
        else s.sub_channel_code
    end as sub_channel_code,
    case when t.channel_code is not null then t.channel_name
        when s.sub_channel_code is null then N'线下' 
        else s.sub_channel_name
    end as sub_channel_name,
    t.store_code,
    isnull(s.nso_province, t.province) as province,
    isnull(s.nso_city, t.city) as city,
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
    item_sku_name as item_sku_name,
    item_quantity as item_quantity,
    item_total_amount as item_total_amount,
    item_apportion_amount as item_apportion_amount,
    item_discount_amount as item_discount_amount,
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
    DW_CRM.DW_Trans_Order_With_SKU t
left join
    DWD.DIM_Store s
on t.store_code = s.store_code
left join
    DWD.Dim_Animation a
on t.item_sku_code = a.sku_code
and t.sap_time between a.Start_Date and a.End_Date
where 
    order_time < '2019-01-01'
and item_quantity >= 0

END

GO
