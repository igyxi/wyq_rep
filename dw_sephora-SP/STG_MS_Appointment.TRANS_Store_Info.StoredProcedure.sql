/****** Object:  StoredProcedure [STG_MS_Appointment].[TRANS_Store_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_MS_Appointment].[TRANS_Store_Info] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-14       hsq           Initial Version
-- ========================================================================================
truncate table STG_MS_Appointment.Store_Info;
insert into STG_MS_Appointment.Store_Info
select  case when trim(store_id) in ('','null') then null else trim(store_id) end as store_id,
        case when trim(node_id) in ('','null') then null else trim(node_id) end as node_id,
        case when trim(store_name) in ('','null') then null else trim(store_name) end as store_name,
        case when trim(store_short_name) in ('','null') then null else trim(store_short_name) end as store_short_name,
        case when trim(province_code) in ('','null') then null else trim(province_code) end as province_code,
        case when trim(city_code) in ('','null') then null else trim(city_code) end as city_code,
        case when trim(town_code) in ('','null') then null else trim(town_code) end as town_code,
        case when trim(store_address) in ('','null') then null else trim(store_address) end as store_address,
        case when trim(store_tel) in ('','null') then null else trim(store_tel) end as store_tel,
        case when trim(post_code) in ('','null') then null else trim(post_code) end as post_code,
        case when trim(contact_name) in ('','null') then null else trim(contact_name) end as contact_name,
        case when trim(contact_phone) in ('','null') then null else trim(contact_phone) end as contact_phone,
        case when trim(contact_email) in ('','null') then null else trim(contact_email) end as contact_email,
        case when trim(status) in ('','null') then null else trim(status) end as status,
        add_user,
        case when trim(province) in ('','null') then null else trim(province) end as province,
        case when trim(city) in ('','null') then null else trim(city) end as city,
        case when trim(town) in ('','null') then null else trim(town) end as town,
        case when trim(wx_poiid) in ('','null') then null else trim(wx_poiid) end as wx_poiid,
        case when trim(custom_no) in ('','null') then null else trim(custom_no) end as custom_no,
        sort,
        case when trim(latitude) in ('','null') then null else trim(latitude) end as latitude,
        case when trim(longitude) in ('','null') then null else trim(longitude) end as longitude,
        case when trim(business_hours) in ('','null') then null else trim(business_hours) end as business_hours,
        case when trim(meta_title) in ('','null') then null else trim(meta_title) end as meta_title,
        case when trim(meta_desc) in ('','null') then null else trim(meta_desc) end as meta_desc,
        case when trim(url) in ('','null') then null else trim(url) end as url,
        case when trim(images) in ('','null') then null else trim(images) end as images,
        case when trim(size) in ('','null') then null else trim(size) end as size,
        created_time,
        updated_time,
        case when trim(greate_region) in ('','null') then null else trim(greate_region) end as greate_region,
        case when trim(region) in ('','null') then null else trim(region) end as region,
        case when trim(district_region) in ('','null') then null else trim(district_region) end as district_region,
        case when trim(fax_number) in ('','null') then null else trim(fax_number) end as fax_number,
        open_date,
        is_snyc,
        current_timestamp as insert_timestamp
from    ODS_MS_Appointment.Store_Info
where   dt = @dt
END
GO
