/****** Object:  StoredProcedure [STG_StoreAssortment].[TRANS_Store_Mall_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_StoreAssortment].[TRANS_Store_Mall_Info] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-27       wangzhichun    Initial Version
-- ========================================================================================
truncate table [STG_StoreAssortment].[Store_Mall_Info];
insert into [STG_StoreAssortment].[Store_Mall_Info]
select 
    store_code,
    case when trim(store_name) in ('null','') then null else trim(store_name) end as store_name,
    case when trim(mall_name) in ('null','') then null else trim(mall_name) end as mall_name,
    case when trim(mall_type) in ('null','') then null else trim(mall_type) end as mall_type,
    shop_total,
    case when trim(brand_type) in ('null','') then null else trim(brand_type) end as brand_type,
    case when trim(brand) in ('null','') then null else trim(brand) end as brand,
    case when trim(is_in) in ('null','') then null else trim(is_in) end as is_in,
    case when trim(file_name) in ('null','') then null else trim(file_name) end as file_name,
    case when trim(sheet_name) in ('null','') then null else trim(sheet_name) end as sheet_name,
    current_timestamp as insert_timestamp
from 
    [ODS_StoreAssortment].[Store_Mall_Info] 
where 
    dt=@dt
END


GO
