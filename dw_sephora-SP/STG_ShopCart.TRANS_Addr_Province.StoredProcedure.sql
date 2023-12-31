/****** Object:  StoredProcedure [STG_ShopCart].[TRANS_Addr_Province]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ShopCart].[TRANS_Addr_Province] @dt [varchar](10) AS 
BEGIN
truncate table STG_ShopCart.Addr_Province;
insert into STG_ShopCart.Addr_Province
select 
    id,
    case when trim(province_name) in ('null','') then null else trim(province_name) end as province_name,
    status,
    case when trim(description) in ('null','') then null else trim(description) end as description,
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    case when trim(cod) in ('null','') then null else trim(cod) end as cod,
    current_timestamp as insert_timestamp
from 
    ODS_ShopCart.Addr_Province
where 
    dt=@dt;
END
GO
