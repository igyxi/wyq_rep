/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Stkin_DTL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Stkin_DTL] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_OMS.OMS_Stkin_DTL ;
insert into STG_OMS.OMS_Stkin_DTL
select 
    oms_stkin_dtl_sys_id,
    case when trim(r_oms_stkin_sys_id) in ('null','') then null else trim(r_oms_stkin_sys_id) end as r_oms_stkin_sys_id,
    oms_stkin_hd_sys_id,
    case when trim(r_oms_order_item_sys_id) in ('null','') then null else trim(r_oms_order_item_sys_id) end as r_oms_order_item_sys_id,
    oms_order_item_sys_id,
    case when trim(item_sku) in ('null','') then null else trim(item_sku) end as item_sku,
    case when trim(item_name) in ('null','') then null else trim(item_name) end as item_name,
    item_quantity,
    good_quantity,
    def_quantity,
    receive_quantity,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    create_time,
    update_time,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,
    field5,
    version,
    case when trim(item_status) in ('null','') then null else trim(item_status) end as item_status,
    case when trim(item_size) in ('null','') then null else trim(item_size) end as item_size,
    case when trim(item_color) in ('null','') then null else trim(item_color) end as item_color,
    item_weight,
    case when trim(confirm_code) in ('null','') then null else trim(confirm_code) end as confirm_code,
    case when trim(confirm_reson) in ('null','') then null else trim(confirm_reson) end as confirm_reson,
    case when trim(barcode) in ('null','') then null else trim(barcode) end as barcode,
    case when trim(item_type) in ('null','') then null else trim(item_type) end as item_type,
    case when trim(r_oms_order_return_item_sys_id) in ('null','') then null else trim(r_oms_order_return_item_sys_id) end as r_oms_order_return_item_sys_id,
    oms_order_return_item_sys_id,
    is_delete,
    case when trim(virtual_stkin_flag) in ('null','') then null else trim(virtual_stkin_flag) end as virtual_stkin_flag,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.OMS_Stkin_DTL
where dt = @dt
END
GO
