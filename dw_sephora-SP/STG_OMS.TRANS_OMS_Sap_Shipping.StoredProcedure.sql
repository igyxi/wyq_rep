/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_Sap_Shipping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_Sap_Shipping] AS
BEGIN
truncate table STG_OMS.OMS_Sap_Shipping;
insert into STG_OMS.OMS_Sap_Shipping
select 
    oms_sap_shipping_sys_id,
    case when trim(lower(osu_file)) in ('null','') then null else trim(osu_file) end as osu_file,
    case when trim(lower(recode_header)) in ('null','') then null else trim(recode_header) end as recode_header,
    case when trim(lower(order_id)) in ('null','') then null else trim(order_id) end as order_id,
    case when trim(lower(suborder_id)) in ('null','') then null else trim(suborder_id) end as suborder_id,
    case when trim(lower(status)) in ('null','') then null else trim(status) end as status,
    case when trim(lower(tracking_number)) in ('null','') then null else trim(tracking_number) end as tracking_number,
    case when trim(lower(shipped_date)) in ('null','') then null else trim(shipped_date) end as shipped_date,
    create_time,
    case when trim(lower(process_status)) in ('null','') then null else trim(process_status) end as process_status,
    process_time,
    case when trim(lower(temp_status)) in ('null','') then null else trim(temp_status) end as temp_status,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_sap_shipping_sys_id order by dt desc) rownum from ODS_OMS.OMS_Sap_Shipping
) t
where rownum = 1
END


GO
