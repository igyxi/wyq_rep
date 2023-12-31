/****** Object:  StoredProcedure [STG_PIMHub].[TRANS_MeiTuan_Store_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_PIMHub].[TRANS_MeiTuan_Store_Mapping] AS
BEGIN
truncate table STG_PIMHub.MeiTuan_Store_Mapping;
insert into STG_PIMHub.MeiTuan_Store_Mapping
select 
    store_code_mapping_sys_id,
    case when trim(lower(meituan_store_id)) in ('null','') then null else trim(meituan_store_id) end as meituan_store_id,
    case when trim(lower(open_shop_uuid)) in ('null','') then null else trim(open_shop_uuid) end as open_shop_uuid,
    case when trim(lower(station_no)) in ('null','') then null else trim(station_no) end as station_no,    
    case when trim(lower(sephora_store_code)) in ('null','') then null else trim(sephora_store_code) end as sephora_store_code,
    case when trim(lower(store_name)) in ('null','') then null else trim(store_name) end as store_name,
    case when trim(lower(store_address)) in ('null','') then null else trim(store_address) end as store_address,
    case when trim(lower(store_tel)) in ('null','') then null else trim(store_tel) end as store_tel,
    case when trim(lower(city)) in ('null','') then null else trim(city) end as city,
    case when trim(lower(status)) in ('null','') then null else trim(status) end as status,
    is_delete,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by store_code_mapping_sys_id order by dt desc) rownum from ODS_PIMHub.MeiTuan_Store_Mapping
) t
where rownum = 1
END


GO
