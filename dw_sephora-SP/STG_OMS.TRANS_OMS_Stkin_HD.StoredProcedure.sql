/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Stkin_HD]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Stkin_HD] AS
BEGIN
truncate table STG_OMS.OMS_Stkin_HD ;
insert into STG_OMS.OMS_Stkin_HD
select 
    oms_stkin_hd_sys_id,
    case when trim(r_oms_stkin_sys_id) in ('null','') then null else trim(r_oms_stkin_sys_id) end as r_oms_stkin_sys_id,
    case when trim(r_oms_order_return_sys_id) in ('null','') then null else trim(r_oms_order_return_sys_id) end as r_oms_order_return_sys_id,
    oms_order_return_sys_id,
    case when trim(store_id) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(channel_id) in ('null','') then null else trim(channel_id) end as channel_id,
    case when trim(returner_name) in ('null','') then null else trim(returner_name) end as returner_name,
    case when trim(oms_order_code) in ('null','') then null else trim(oms_order_code) end as oms_order_code,
    case when trim(source_order_code) in ('null','') then null else trim(source_order_code) end as source_order_code,
    case when trim(oms_stkin_no) in ('null','') then null else trim(oms_stkin_no) end as oms_stkin_no,
    case when trim(stkin_rtn_orders) in ('null','') then null else trim(stkin_rtn_orders) end as stkin_rtn_orders,
    case when trim(stkin_remark) in ('null','') then null else trim(stkin_remark) end as stkin_remark,
    case when trim(create_op) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(update_op) in ('null','') then null else trim(update_op) end as update_op,
    create_time,
    update_time,
    receive_time,
    case when trim(field1) in ('null','') then null else trim(field1) end as field1,
    case when trim(field2) in ('null','') then null else trim(field2) end as field2,
    field5,
    case when trim(process_status) in ('null','') then null else trim(process_status) end as process_status,
    case when trim(basic_status) in ('null','') then null else trim(basic_status) end as basic_status,
    version,
    sync_status,
    case when trim(oms_stkin_type) in ('null','') then null else trim(oms_stkin_type) end as oms_stkin_type,
    case when trim(return_shipping_mtd) in ('null','') then null else trim(return_shipping_mtd) end as return_shipping_mtd,
    case when trim(return_tracking_no) in ('null','') then null else trim(return_tracking_no) end as return_tracking_no,
    post_fee,
    case when trim(who_pay_post) in ('null','') then null else trim(who_pay_post) end as who_pay_post,
    stkin_invoice_flag,
    is_delete,
    case when trim(ware_house_code) in ('null','') then null else trim(ware_house_code) end as ware_house_code,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_stkin_hd_sys_id order by dt desc) rownum from ODS_OMS.OMS_Stkin_HD 
) t
where rownum = 1
END


GO
