/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Group]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Group] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Product.PROD_Group ;
insert into STG_Product.PROD_Group
select 
    id,
    parent_id,
    case when trim(name_cn) in ('null', '') then null else trim(name_cn) end as name_cn,
    case when trim(name_en) in ('null', '') then null else trim(name_en) end as name_en,
    case when trim(image_path) in ('null', '') then null else trim(image_path) end as image_path,
    case when trim(short_description) in ('null', '') then null else trim(short_description) end as short_description,
    case when trim(long_description) in ('null', '') then null else trim(long_description) end as long_description,
    case when trim(origin) in ('null', '') then null else trim(origin) end as origin,
    case when trim(seo) in ('null', '') then null else trim(seo) end as seo,
    sequence,
    level,
    is_exclusive,
    is_selective,
    is_delete,
    is_disable,
    has_story,
    catalog_id,
    update_time,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    case when trim(seo_nickname) in ('null', '') then null else trim(seo_nickname) end as seo_nickname,
    case when trim(brand_nick_name) in ('null', '') then null else trim(brand_nick_name) end as brand_nick_name,
    case when trim(store) in ('null', '') then null else trim(store) end as store,
    create_time,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    quantity,
    amount,
    position,
    sku_count,
	label_image_status,
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_Group
where dt = @dt
END


GO
