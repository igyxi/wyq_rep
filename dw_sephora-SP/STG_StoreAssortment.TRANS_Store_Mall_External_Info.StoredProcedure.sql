/****** Object:  StoredProcedure [STG_StoreAssortment].[TRANS_Store_Mall_External_Info]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_StoreAssortment].[TRANS_Store_Mall_External_Info] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-27       wangzhichun        Initial Version
-- ========================================================================================
truncate table [STG_StoreAssortment].[Store_Mall_External_Info];
insert into [STG_StoreAssortment].[Store_Mall_External_Info]
select 
    store_code,
    case when trim(store_name) in ('null','') then null else trim(store_name) end as store_name,
    case when trim(mall_id) in ('null','') then null else trim(mall_id) end as mall_id,
    case when trim(mall_type) in ('null','') then null else trim(mall_type) end as mall_type,
    case when trim(mall_name) in ('null','') then null else trim(mall_name) end as mall_name,
    case when trim(mall_city) in ('null','') then null else trim(mall_city) end as mall_city,
    case when trim(brand_name) in ('null','') then null else trim(brand_name) end as brand_name,
    case when trim(store_floor) in ('null','') then null else trim(store_floor) end as store_floor,
    case when trim(store_effect_rating) in ('null','') then null else trim(store_effect_rating) end as store_effect_rating,
    case when trim(brand_type) in ('null','') then null else trim(brand_type) end as brand_type,
    case when trim(n_malls) in ('null','') then null else trim(n_malls) end as n_malls,
    case when trim(n_boutiques_same_mall) in ('null','') then null else trim(n_boutiques_same_mall) end as n_boutiques_same_mall,
    case when trim(n_boutiques) in ('null','') then null else trim(n_boutiques) end as n_boutiques,
    shop_total,
    current_timestamp as insert_timestamp
from 
    [ODS_StoreAssortment].[Store_Mall_External_Info]
END


GO
