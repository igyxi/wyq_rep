/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_CN_Database]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_CN_Database] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-08-16       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Product.PROD_CN_Database;
insert into STG_Product.PROD_CN_Database
select 
		case when trim(material) in ('','null') then null else trim(material) end as material,
		case when trim(vendor) in ('','null') then null else trim(vendor) end as vendor,
		case when trim([name]) in ('','null') then null else trim([name]) end as name,
		case when trim(brand_name) in ('','null') then null else trim(brand_name) end as brand_name,
		case when trim(brand) in ('','null') then null else trim(brand) end as brand,
		case when trim(sub_brand) in ('','null') then null else trim(sub_brand) end as sub_brand,
		case when trim(sub_brand_2) in ('','null') then null else trim(sub_brand_2) end as sub_brand_2,
		case when trim(ean_upc) in ('','null') then null else trim(ean_upc) end as ean_upc,
		case when trim(created_on) in ('','null') then null else trim(created_on) end as created_on,
		case when trim(tester_code) in ('','null') then null else trim(tester_code) end as tester_code,
		case when trim(material_description) in ('','null') then null else trim(material_description) end as material_description,
		case when trim(description_for_unit) in ('','null') then null else trim(description_for_unit) end as description_for_unit,
		case when trim(additional_description) in ('','null') then null else trim(additional_description) end as additional_description,
		case when trim(till_description_in_additional_language) in ('','null') then null else trim(till_description_in_additional_language) end as till_description_in_additional_language,
		case when trim(net_contents) in ('','null') then null else trim(net_contents) end as net_contents,
		case when trim(content_unit) in ('','null') then null else trim(content_unit) end as content_unit,
		case when trim(moh_certific) in ('','null') then null else trim(moh_certific) end as moh_certific,
		case when trim(moh_date) in ('','null') then null else trim(moh_date) end as moh_date,
		case when trim(product_origin) in ('','null') then null else trim(product_origin) end as product_origin,
		case when trim(platform) in ('','null') then null else trim(platform) end as platform,
		case when trim(loading_group) in ('','null') then null else trim(loading_group) end as loading_group,
		case when trim(vendor_material_no) in ('','null') then null else trim(vendor_material_no) end as vendor_material_no,
		case when trim(delivery_rounding) in ('','null') then null else trim(delivery_rounding) end as delivery_rounding,
		case when trim(rounding_profile) in ('','null') then null else trim(rounding_profile) end as rounding_profile,
		case when trim(plant_sp_matl_status) in ('','null') then null else trim(plant_sp_matl_status) end as plant_sp_matl_status,
		case when trim(valid_from) in ('','null') then null else trim(valid_from) end as valid_from,
		case when trim(dchain_spec_status) in ('','null') then null else trim(dchain_spec_status) end as dchain_spec_status,
		case when trim(pp) in ('','null') then null else trim(pp) end as pp,
		case when trim(moving_price) in ('','null') then null else trim(moving_price) end as moving_price,
		case when trim(rsp) in ('','null') then null else trim(rsp) end as rsp,
		case when trim(last_price_modif_date) in ('','null') then null else trim(last_price_modif_date) end as last_price_modif_date,
		case when trim(material_group) in ('','null') then null else trim(material_group) end as material_group,
		case when trim(market_description) in ('','null') then null else trim(market_description) end as market_description,
		case when trim(range_desc) in ('','null') then null else trim(range_desc) end as range_desc,
		case when trim(category_name) in ('','null') then null else trim(category_name) end as category_name,
		case when trim(target_description) in ('','null') then null else trim(target_description) end as target_description,
		case when trim(sls_typ_desc) in ('','null') then null else trim(sls_typ_desc) end as sls_typ_desc,
		case when trim(mrp_profile) in ('','null') then null else trim(mrp_profile) end as mrp_profile,
		case when trim(condition_currency) in ('','null') then null else trim(condition_currency) end as condition_currency,
        current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by material order by additional_description desc) rownum from ODS_Product.PROD_CN_Database where dt = @dt
) t
where rownum = 1
END

GO
