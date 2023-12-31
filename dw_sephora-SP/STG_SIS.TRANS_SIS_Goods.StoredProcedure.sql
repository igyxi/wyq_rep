/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Goods]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Goods] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-26       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Goods;
insert into STG_SIS.SIS_Goods
select 
		id,
		case when trim(sku_code) in ('','null') then null else trim(sku_code) end as sku_code,
		case when trim(brand_name) in ('','null') then null else trim(brand_name) end as brand_name,
		case when trim(product_name_cn) in ('','null') then null else trim(product_name_cn) end as product_name_cn,
		case when trim(product_name_en) in ('','null') then null else trim(product_name_en) end as product_name_en,
		case when trim(product_image) in ('','null') then null else trim(product_image) end as product_image,
		case when trim(specification) in ('','null') then null else trim(specification) end as specification,
		market_price,
		case when trim(packing) in ('','null') then null else trim(packing) end as packing,
		case when trim(sku_images) in ('','null') then null else trim(sku_images) end as sku_images,
		case when trim(product_introduction_cn) in ('','null') then null else trim(product_introduction_cn) end as product_introduction_cn,
		case when trim(product_introduction_en) in ('','null') then null else trim(product_introduction_en) end as product_introduction_en,
		case when trim(bar_code) in ('','null') then null else trim(bar_code) end as bar_code,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from    
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Goods
) t
where rownum = 1
END
GO
