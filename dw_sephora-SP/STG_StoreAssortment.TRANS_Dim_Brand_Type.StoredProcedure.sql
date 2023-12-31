/****** Object:  StoredProcedure [STG_StoreAssortment].[TRANS_Dim_Brand_Type]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_StoreAssortment].[TRANS_Dim_Brand_Type] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-08       wangzhichun        Initial Version
-- ========================================================================================
truncate table [STG_StoreAssortment].[Dim_Brand_Type];
insert into [STG_StoreAssortment].[Dim_Brand_Type]
select 

    case when trim(category) in ('null','') then null else trim(category) end as category,
    case when trim(brand) in ('null','') then null else trim(brand) end as brand,
    case when trim(franchise) in ('null','') then null else trim(franchise) end as franchise,
    case when trim(brand_type) in ('null','') then null else trim(brand_type) end as brand_type,
    case when trim(target_category) in ('null','') then null else trim(target_category) end as target_category,
    case when trim(brand_topn_cluster) in ('null','') then null else trim(brand_topn_cluster) end as brand_topn_cluster,
    case when trim(new_brand) in ('null','') then null else trim(new_brand) end as new_brand,
    case when trim(tentative_shelf) in ('null','') then null else trim(tentative_shelf) end as tentative_shelf,
    current_timestamp as insert_timestamp
from 
    [ODS_StoreAssortment].[Dim_Brand_Type] where dt=@dt
END

GO
