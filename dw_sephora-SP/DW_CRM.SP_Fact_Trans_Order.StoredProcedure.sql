/****** Object:  StoredProcedure [DW_CRM].[SP_Fact_Trans_Order]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_CRM].[SP_Fact_Trans_Order] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-10       tali           Initial Version
-- ========================================================================================
truncate table DW_CRM.Fact_Trans_Order;
insert into DW_CRM.Fact_Trans_Order
select
    trans.declaration_id as trans_id,
    case when c.store_code is null then '66'+ trans.invc_no else trans.invc_no end as invc_no,
    trans.invc_id as invc_id,
    case when c.channel_id is null then 'OFFLINE' else c.store_code end as channel_code,
    case when c.channel_id is null then N'线下' else c.channel_name end as channel_name,
    c.store_id as sub_channel_code,
    c.store_name as sub_channel_name,
    dStore.store_code,
    dStore.province,
    dStore.city,
    trans.transaction_type as type_code,
    trans.account_id as member_id,
    trans.account_number as member_card,
    purchase_date as order_time,
    transaction_date as trans_time,
    purchase_date_from_sap as sap_time,
    dProd.sku as item_sku_code,
    replace(dProd.product_name,' ','')  as item_sku_name,
    d.product_qty as item_quantity,
    d.ori_amount as item_total_amount,
    d.real_amount as item_apportion_amount,
    d.ori_amount - isnull(d.real_amount, 0.0) as item_discount_amount,
    valid_flag,
    trans.created_date,
    modified_date,
    CURRENT_TIMESTAMP as insert_timestamp
FROM
    ODS_CRM.declaration trans 
LEFT JOIN
    ODS_CRM.purchase_detail d
ON trans.declaration_id = d.declaration_id
LEFT JOIN
    ODS_CRM.crm_product dProd 
ON d.crm_product_id = dProd.crm_product_id 
LEFT JOIN
    ODS_CRM.DimStore dStore
ON trans.place_id = dStore.store_id
left join
(
    select 
        a.store_code, b.channel_id, b.channel_name, b.store_id, b.store_name
    from 
        STG_OMS.OMS_Store_Mapping a
    join
        STG_OMS.OMS_Store_Info b
    on a.store_id = b.store_id
) c
on dStore.store_code = c.store_code
END
GO
