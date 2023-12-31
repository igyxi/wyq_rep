/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Classification]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Classification] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-16       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Product.PROD_Classification;
insert into STG_Product.PROD_Classification
select 
		case when trim(category) in ('','null') then null else trim(category) end as category,
		case when trim(mat) in ('','null') then null else trim(mat) end as mat,
		case when trim(description) in ('','null') then null else trim(description) end as description,
		case when trim(brand_description) in ('','null') then null else trim(brand_description) end as brand_description,
		case when trim(description_ch) in ('','null') then null else trim(description_ch) end as description_ch,
		case when trim(franchise) in ('','null') then null else trim(franchise) end as franchise,
		case when trim(range) in ('','null') then null else trim(range) end as range,
		case when trim(segment) in ('','null') then null else trim(segment) end as segment,
		case when trim(first_function) in ('','null') then null else trim(first_function) end as first_function,
		case when trim(sub_segment) in ('','null') then null else trim(sub_segment) end as sub_segment,
		case when trim(remark) in ('','null') then null else trim(remark) end as remark,
        current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by mat order by dt desc) rownum from ODS_Product.PROD_Classification where dt = @dt
) t
where rownum = 1
END

GO
