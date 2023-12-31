/****** Object:  StoredProcedure [STG_OMS].[TRANS_Purchase_To_Sap]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Purchase_To_Sap] AS
BEGIN
truncate table STG_OMS.Purchase_To_Sap ;
insert into STG_OMS.Purchase_To_Sap
select 
    purchase_to_sap_sys_id,
    purchase_order_sys_id,
    case when trim(lower(pos_filename)) in ('null','') then null else pos_filename end as pos_filename,
    ors_create_time,
    m50_sync_time,
    pos_sync_status,
    pos_sync_time,
    case when trim(lower(ors_filename)) in ('null','') then null else ors_filename end as ors_filename,
    case when trim(lower(purchase_order_number)) in ('null','') then null else purchase_order_number end as purchase_order_number,
    ors_generated_status,
    case when trim(lower(ors_model)) in ('null','') then null else ors_model end as ors_model,
    case when trim(lower(store_location_id)) in ('null','') then null else store_location_id end as store_location_id,
    create_time,
    update_time,
    m50_generated_status,
    ors_num,
    case when trim(lower(invoice_id)) in ('null','') then null else invoice_id end as invoice_id,
    case when trim(lower(create_user)) in ('null','') then null else create_user end as create_user,		
    case when trim(lower(update_user)) in ('null','') then null else update_user end as update_user,		
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by purchase_to_sap_sys_id order by dt desc) rownum from ODS_OMS.Purchase_To_Sap
) t
where rownum = 1;
END


GO
