/****** Object:  StoredProcedure [STG_SIS].[TRANS_SIS_Activity_Goods]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SIS].[TRANS_SIS_Activity_Goods] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-26       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_SIS.SIS_Activity_Goods;
insert into STG_SIS.SIS_Activity_Goods
select 
		id,
		activity_id,
		case when trim(sku_code) in ('','null') then null else trim(sku_code) end as sku_code,
		case when trim(product_name_cn) in ('','null') then null else trim(product_name_cn) end as product_name_cn,
		case when trim(product_name_en) in ('','null') then null else trim(product_name_en) end as product_name_en,
		brand_id,
		case when trim(product_image) in ('','null') then null else trim(product_image) end as product_image,
		case when trim(specification) in ('','null') then null else trim(specification) end as specification,
		promotion_price,
		market_price,
		ttl_plan_stock,
		case when trim(expiration_date) in ('','null') then null else trim(expiration_date) end as expiration_date,
		case when trim(packing) in ('','null') then null else trim(packing) end as packing,
		case when trim(sku_images) in ('','null') then null else trim(sku_images) end as sku_images,
		case when trim(product_introduction_cn) in ('','null') then null else trim(product_introduction_cn) end as product_introduction_cn,
		case when trim(product_introduction_en) in ('','null') then null else trim(product_introduction_en) end as product_introduction_en,
		case when trim(bar_code) in ('','null') then null else trim(bar_code) end as bar_code,
		case when trim(explosive_flag) in ('','null') then null else trim(explosive_flag) end as explosive_flag,
		status,
		case when trim(location_id) in ('','null') then null else trim(location_id) end as location_id,
		case when trim(location_id_description) in ('','null') then null else trim(location_id_description) end as location_id_description,
		case when trim(warehouse) in ('','null') then null else trim(warehouse) end as warehouse,
		max_stock,
		init_stock,
		case when trim(category_name_cn) in ('','null') then null else trim(category_name_cn) end as category_name_cn,
		case when trim(category_name_en) in ('','null') then null else trim(category_name_en) end as category_name_en,
		case when trim(collect_orders) in ('','null') then null else trim(collect_orders) end as collect_orders,
		case when trim(whether_check) in ('','null') then null else trim(whether_check) end as whether_check,
		case when trim(customer_number) in ('','null') then null else trim(customer_number) end as customer_number,
		case when trim(gross_weight) in ('','null') then null else trim(gross_weight) end as gross_weight,
		case when trim(label_name) in ('','null') then null else trim(label_name) end as label_name,
		case when trim(explosive_recommend) in ('','null') then null else trim(explosive_recommend) end as explosive_recommend,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from      
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_SIS.SIS_Activity_Goods
) t
where rownum = 1
END
GO
