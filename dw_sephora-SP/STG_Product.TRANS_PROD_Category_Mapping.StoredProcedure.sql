/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Category_Mapping]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Category_Mapping] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-16       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Product.PROD_Category_Mapping;
insert into STG_Product.PROD_Category_Mapping
select 
		case when trim(category) in ('','null') then null else trim(category) end as category,
		case when trim(category_sub) in ('','null') then null else trim(category_sub) end as category_sub,
        case when trim(category_level1_cn) in ('','null') then null else trim(category_level1_cn) end as category_sub,
        current_timestamp as insert_timestamp
from    
    ODS_Product.PROD_Category_Mapping
END
GO
