/****** Object:  StoredProcedure [DW_CRM].[SP_DW_Trans_Order_With_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_CRM].[SP_DW_Trans_Order_With_SKU] AS 
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-14       tali           Initial Version
-- 2022-03-17       tali           change the province city to cn
-- 2022-03-21       tali           update DW_CRM.DIM_SKU
-- 2022-05-25       tali           change sub_channel_code, sub_channel_name
-- 2022-06-07       tali           add DWS_Trans_Order_With_SKU
-- 2022-06-08       tali           fix item_discount_amount
-- 2022-06-28       tali           fix province and city
-- 2022-07-15       tali           feat unique columns 
-- ========================================================================================
truncate table DW_CRM.DW_Trans_Order_With_SKU;
insert into DW_CRM.DW_Trans_Order_With_SKU
select 
    trans_id,
    invc_no,
    invc_id,
    channel_code,
    channel_name,
    -- sub_channel_code,
    -- sub_channel_name,
    store_code,
    province,
    city,
    type_code,
    member_id,
    member_card,
    order_time,
    trans_time,
    sap_time,
    item_sku_code,
    max(item_sku_name) as item_sku_name,
    sum(item_quantity) as item_quantity,
    sum(item_total_amount) as item_total_amount,
    sum(item_apportion_amount) as item_apportion_amount,
    sum(item_discount_amount) as item_discount_amount,
    account_offer_id,
    valid_flag,
    created_date,
    modified_date,
    CURRENT_TIMESTAMP as insert_timestamp
from
(
    select
        trans.declaration_id as trans_id,
        trans.invc_no as invc_no,
        trans.invc_id as invc_id,
        dsm.oms_sub_channel_code as channel_code,
        dsm.oms_sub_channel_name as channel_name,
        -- case when dsm.oms_sub_channel_code in ('JDDJ', 'DIANPING', 'MEITUAN') then dsm.oms_sub_channel_code
        --      when dsm.oms_sub_channel_code is not null then 'SOA'
        --      when c.channel_id is null then 'OFF_LINE' 
        --      else c.channel_id
        -- end as channel_code,
        -- case when dsm.oms_sub_channel_code in ('JDDJ', 'DIANPING', 'MEITUAN') then dsm.oms_sub_channel_name
        --      when dsm.oms_sub_channel_code is not null then N'官网'
        --      when c.channel_id is null then N'线下' 
        --      else c.channel_name
        -- end as channel_name,
        -- case when dsm.crm_store_id is not null then dsm.oms_sub_channel_code
        --     when c.store_id is null then 'OFF_LINE'  
        --     else c.store_id
        -- end as sub_channel_code,
        -- case when dsm.crm_store_id is not null then dsm.oms_sub_channel_name
        --     when c.store_id is null then N'线下'  
        --     else c.store_name
        -- end as sub_channel_name,
        dStore.store_code,
        dstore.province_name as province,
        dstore.city_name as city,
        trans.transaction_type as type_code,
        trans.account_id as member_id,
        trans.account_number as member_card,
        purchase_date as order_time,
        transaction_date as trans_time,
        isnull(trans.purchase_date_from_sap, trans.purchase_date) as sap_time,
        dProd.sku_code as item_sku_code,
        dProd.sku_name as item_sku_name,
        d.product_qty as item_quantity,
        d.ori_amount as item_total_amount,
        d.real_amount as item_apportion_amount,
        case when abs(d.ori_amount) - abs(isnull(d.real_amount, 0.0)) < 0 then 0 else d.ori_amount - isnull(d.real_amount, 0.0) end as item_discount_amount,
        d.account_offer_id,
        valid_flag,
        trans.created_date,
        modified_date
    FROM
        ODS_CRM.declaration trans 
    left join
        ODS_CRM.deleted_obj_record dor
    on  trans.declaration_id = dor.obj_id  
    and dor.from_table_name='declaration' 
    LEFT JOIN
        ODS_CRM.purchase_detail d
    ON trans.declaration_id = d.declaration_id
    left join
        ODS_CRM.deleted_obj_record dor2
    on  d.purchase_detail_id = dor2.obj_id  
    and dor2.from_table_name='purchase_detail' 
    LEFT JOIN
        DW_CRM.DIM_SKU dProd
    ON d.crm_product_id = dProd.sku_id
    LEFT JOIN
        DW_CRM.DIM_Store dStore
    ON trans.place_id = dStore.store_id
    LEFT JOIN
        ODS_CRM.DIM_SUB_Channel_Mapping dsm
    ON trans.sub_place_id = dsm.crm_store_id
    -- left join
    --     stg_nso.storeinfo si
    -- on dStore.store_code = cast(si.storeno as nvarchar)
    -- left join
    -- (
    --     select 
    --         a.store_code, b.channel_id, b.channel_name, b.store_id, b.store_name
    --     from 
    --         STG_OMS.OMS_Store_Mapping a
    --     join
    --         STG_OMS.OMS_Store_Info b
    --     on a.store_id = b.store_id
    -- ) c
    -- on dStore.store_code = c.store_code
    where dor.obj_id is null 
    and dor2.obj_id is null
) t
group by 
    trans_id,
    invc_no,
    invc_id,
    channel_code,
    channel_name,
    store_code,
    province,
    city,
    type_code,
    member_id,
    member_card,
    order_time,
    trans_time,
    sap_time,
    item_sku_code,
    account_offer_id,
    valid_flag,
    created_date,
    modified_date,
    case when item_quantity < 0 then -1 else 1 end
;
END

GO
