/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Brand_Type]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Brand_Type] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-16       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Product.PROD_Brand_Type;
insert into STG_Product.PROD_Brand_Type
select 
		case when trim(sap_brand) in ('','null') then null else trim(sap_brand) end as sap_brand,
		case when trim(market) in ('','null') then null else trim(market) end as market,
        current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by sap_brand order by market desc) rownum from ODS_Product.PROD_Brand_Type where dt = @dt
) t
where rownum = 1
END

GO
