/****** Object:  StoredProcedure [STG_ShopCart].[TRANS_Addr_City]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ShopCart].[TRANS_Addr_City] @dt [varchar](10) AS 
BEGIN
truncate table STG_ShopCart.Addr_City;
insert into STG_ShopCart.Addr_City
select 
    id,
    case when trim(city_name) in ('null','') then null else trim(city_name) end as city_name,
    status,
    case when trim(description) in ('null','') then null else trim(description) end as description,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    case when trim(province_id) in ('null','') then null else trim(province_id) end as province_id,
    case when trim(display_level) in ('null','') then null else trim(display_level) end as display_level,
    case when trim(default_ordinate) in ('null','') then null else trim(default_ordinate) end as default_ordinate,
    case when trim(google_map_places) in ('null','') then null else trim(google_map_places) end as google_map_places,
    case when trim(cod) in ('null','') then null else trim(cod) end as cod,
    current_timestamp as insert_timestamp 
from 
    ODS_ShopCart.Addr_City
where 
    dt=@dt;
END



GO
