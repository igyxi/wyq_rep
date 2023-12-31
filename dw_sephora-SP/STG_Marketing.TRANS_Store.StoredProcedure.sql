/****** Object:  StoredProcedure [STG_Marketing].[TRANS_Store]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Marketing].[TRANS_Store] AS
BEGIN
truncate table STG_Marketing.Store;
insert into STG_Marketing.Store
select 
    case when trim(code) in ('null','') then null else trim(code) end as code,
    case when trim(name) in ('null','') then null else trim(name) end as name,
    case when trim(pinyin_name) in ('null','') then null else trim(pinyin_name) end as pinyin_name,
    case when trim(business_hours) in ('null','') then null else trim(business_hours) end as business_hours,
    case when trim(province) in ('null','') then null else trim(province) end as province,
    case when trim(city) in ('null','') then null else trim(city) end as city,
    case when trim(district) in ('null','') then null else trim(district) end as district,
    case when trim(address) in ('null','') then null else trim(address) end as address,
    case when trim(phone_number) in ('null','') then null else trim(phone_number) end as phone_number,
    case when trim(meta_title) in ('null','') then null else trim(meta_title) end as meta_title,
    case when trim(meta_desc) in ('null','') then null else trim(meta_desc) end as meta_desc,
    case when trim(url) in ('null','') then null else trim(url) end as url,
    case when trim(images) in ('null','') then null else trim(images) end as images,
    case when trim(geo_lat) in ('null','') then null else trim(geo_lat) end as geo_lat,
    case when trim(geo_long) in ('null','') then null else trim(geo_long) end as geo_long,
    case when trim(email) in ('null','') then null else trim(email) end as email,
    case when trim(address_api) in ('null','') then null else trim(address_api) end as address_api,
    create_time,
    update_time,
    is_delete,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,        
    case when trim(size) in ('null','') then null else trim(size) end as size,        
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by code order by dt desc) rownum from ODS_Marketing.Store
) t
where rownum = 1
END
GO
