/****** Object:  StoredProcedure [STG_StoreAssortment].[TRANS_Dim_City]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_StoreAssortment].[TRANS_Dim_City] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-27       wangzhichun        Initial Version
-- ========================================================================================
truncate table [STG_StoreAssortment].[Dim_City];
insert into [STG_StoreAssortment].[Dim_City]
select 
    case when trim(city) in ('null','') then null else trim(city) end as city,
    case when trim(province) in ('null','') then null else trim(province) end as province,
    case when trim(region_gov) in ('null','') then null else trim(region_gov) end as region_gov,
    case when trim(region_client) in ('null','') then null else trim(region_client) end as region_client,
    case when trim(city_tier) in ('null','') then null else trim(city_tier) end as city_tier,
    case when trim(city_rank) in ('null','') then null else trim(city_rank) end as city_rank,
    current_timestamp as insert_timestamp
from 
    [ODS_StoreAssortment].[Dim_City] where dt=@dt
END


GO
