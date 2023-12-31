/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Store_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Store_Info] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-28       Eric        Initial Version
-- ========================================================================================
truncate table STG_OMS.OMS_Store_Info;
insert into STG_OMS.OMS_Store_Info
select 
    oms_store_info_sys_id,
    case when trim(store_name) in ('null','') then null else trim(store_name) end as store_name,
    case when trim(po_number_prefix) in ('null','') then null else trim(po_number_prefix) end as po_number_prefix,
    case when trim(po_number_infix) in ('null','') then null else trim(po_number_infix) end as po_number_infix,
    case when trim(description) in ('null','') then null else trim(description) end as description,
    case when trim(channel_name) in ('null','') then null else trim(channel_name) end as channel_name,
    case when trim(channel_id) in ('null','') then null else trim(channel_id) end as channel_id,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(store_brief_name) in ('null','') then null else trim(store_brief_name) end as store_brief_name,
    case when trim(crm_store_id) in ('null','') then null else trim(crm_store_id) end as crm_store_id,
    invoice_flag,
    case when trim(invoice_code) in ('null','') then null else trim(invoice_code) end as invoice_code,
    division_rule_flag,
    gwp_split_flag,
    vb_split_flag,
    vb_inv_calc_flag,
    show_flag,
    inv_allocate_flag,
    case when trim(inv_allocate_type_code) in ('null','') then null else trim(inv_allocate_type_code) end as inv_allocate_type_code,
    case when trim(inv_allocate_export_code) in ('null','') then null else trim(inv_allocate_export_code) end as inv_allocate_export_code,
    inv_sync_flag,
    case when trim(area_def_store_id) in ('null','') then null else trim(area_def_store_id) end as area_def_store_id,
    case when trim(warehouse_def_store_id) in ('null','') then null else trim(warehouse_def_store_id) end as warehouse_def_store_id,
    case when trim(logistics_def_store_id) in ('null','') then null else trim(logistics_def_store_id) end as logistics_def_store_id,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(partial_cancel_def_store_id) in ('null','') then null else trim(partial_cancel_def_store_id) end as partial_cancel_def_store_id,
    auto_refund,
    speed_refund,
    estimate_con_time,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.OMS_Store_Info
where 
    dt = @dt

END


GO
