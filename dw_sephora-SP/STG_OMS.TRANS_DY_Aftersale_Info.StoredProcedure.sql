/****** Object:  StoredProcedure [STG_OMS].[TRANS_DY_Aftersale_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_DY_Aftersale_Info] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-22       litao           Initial Version 
-- ========================================================================================
truncate table STG_OMS.Dy_Aftersale_Info;
insert into  STG_OMS.Dy_Aftersale_Info
select
    dy_aftersale_info_sys_id,
    case when trim(aftersale_id) in ('null','') then null else trim(aftersale_id) end as aftersale_id,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(shop_order_id) in ('null','') then null else trim(shop_order_id) end as shop_order_id,
    case when trim(item_sku) in ('null','') then null else trim(item_sku) end as item_sku,
    aftersale_order_type,
    aftersale_type,
    aftersale_status,
    case when trim(related_id) in ('null','') then null else trim(related_id) end as related_id,
    apply_time,
    dy_update_time,
    status_deadline,
    refund_amount,
    refund_post_amount,
    aftersale_num,
    part_type,
    aftersale_refund_type,
    refund_type,
    arbitrate_status,
    dy_create_time,
    refund_tax_amount,
    left_urge_sms_count,
    case when trim(return_logistics_code) in ('null','') then null else trim(return_logistics_code) end as return_logistics_code,
    risk_decision_code,
    case when trim(risk_decision_reason) in ('null','') then null else trim(risk_decision_reason) end as risk_decision_reason,
    case when trim(risk_decision_description) in ('null','') then null else trim(risk_decision_description) end as risk_decision_description,
    return_promotion_amount,
    refund_status,
    arbitrate_blame,
    case when trim(return_logistics_company_name) in ('null','') then null else trim(return_logistics_company_name) end as return_logistics_company_name,
    case when trim(exchange_logistics_company_name) in ('null','') then null else trim(exchange_logistics_company_name) end as exchange_logistics_company_name,
    case when trim(remark) in ('null','') then null else trim(remark) end as remark,
    got_pkg,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    oms_refund_status,
    case when trim(process_status) in ('null','') then null else trim(process_status) end as process_status,
    case when trim(reason) in ('null','') then null else trim(reason) end as reason,
    case when trim(oms_refund_type) in ('null','') then null else trim(oms_refund_type) end as oms_refund_type,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by aftersale_id order by update_time desc) rownum from [ODS_OMS].Dy_Aftersale_Info
) t
where rownum = 1
END
GO
