/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_SYNC_Store_INV_Data]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_SYNC_Store_INV_Data] @dt [varchar](10) AS
BEGIN
truncate table STG_OMS.OMS_SYNC_Store_INV_Data ;
insert into STG_OMS.OMS_SYNC_Store_INV_Data
select 
    oms_sync_store_inv_data_sys_id,
    case when trim(sku) in ('null','') then null else trim(sku) end as sku,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(soa_qty) in ('null','') then null else trim(soa_qty) end as soa_qty,
    case when trim(jd_qty) in ('null','') then null else trim(jd_qty) end as jd_qty,
    case when trim(tmall_qty) in ('null','') then null else trim(tmall_qty) end as tmall_qty,
    case when trim(redbook_qty) in ('null','') then null else trim(redbook_qty) end as redbook_qty,
    case when trim(tmall_wei_qty) in ('null','') then null else trim(tmall_wei_qty) end as tmall_wei_qty,
    case when trim(douyin_qty) in ('null','') then null else trim(douyin_qty) end as douyin_qty,
    case when trim(qty_json_data) in ('null','') then null else trim(qty_json_data) end as qty_json_data,
    current_timestamp as insert_timestamp
from 
    ODS_OMS.OMS_SYNC_Store_INV_Data
where 
    dt = @dt
END

GO
