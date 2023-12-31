/****** Object:  StoredProcedure [TEMP].[TRANS_PROD_SKU_Bak_20230608]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_PROD_SKU_Bak_20230608] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Product.PROD_SKU ;
insert into STG_Product.PROD_SKU
select 
    sku_id,
    case when trim(sku_type) in ('null', '') then null else trim(sku_type) end as sku_type,
    case when trim(sku_name) in ('null', '') then null else trim(sku_name) end as sku_name,
    product_id,
    case when trim(brand) in ('null', '') then null else trim(brand) end as brand,
    case when trim(value) in ('null', '') then null else trim(value) end as value,
    case when trim(tags) in ('null', '') then null else trim(tags) end as tags,
    case when trim(sku_code) in ('null', '') then null else trim(sku_code) end as sku_code,
    case when trim(sale_attr) in ('null', '') then null else trim(sale_attr) end as sale_attr,
    sap_price,
    custom_price_flag,
    case when trim(custom_price_name) in ('null', '') then null else trim(custom_price_name) end as custom_price_name,
    custom_price,
    is_default,
    status,
    first_pubilsh_time,
    last_publish_time,
    last_unpublish_time,
    sch_publish_time,
    sch_unpublish_time,
    case when trim(sap_desc) in ('null', '') then null else trim(sap_desc) end as sap_desc,
    case when trim(recommend_reason) in ('null', '') then null else trim(recommend_reason) end as recommend_reason,
    case when trim(barcode) in ('null', '') then null else trim(barcode) end as barcode,
    case when trim(taxrate) in ('null', '') then null else trim(taxrate) end as taxrate,
    case when trim(weight) in ('null', '') then null else trim(weight) end as weight,
    update_time,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    sequence,
    is_show,
    case when trim(expiration) in ('null', '') then null else trim(expiration) end as expiration,
    case when trim(net_volume) in ('null', '') then null else trim(net_volume) end as net_volume,
    case when trim(sale_channel) in ('null', '') then null else trim(sale_channel) end as sale_channel,
    case when trim(platform) in ('null', '') then null else trim(platform) end as platform,
    return_policy,
    auto_manage_type,
    case when trim(store) in ('null', '') then null else trim(store) end as store,
    case when trim(tool_model_number) in ('null', '') then null else trim(tool_model_number) end as tool_model_number,
    case when trim(skin_model_number) in ('null', '') then null else trim(skin_model_number) end as skin_model_number,
    case when trim(sales_ids) in ('null', '') then null else trim(sales_ids) end as sales_ids,
    limit_amount,
    limit_time,
    create_time,
    case when trim(marketing_language) in ('null', '') then null else trim(marketing_language) end as marketing_language,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    is_delete,      
    case when trim(country) in ('null', '') then null else trim(country) end as country,        
    case when trim(customer_tags) in ('null', '') then null else trim(customer_tags) end as customer_tags,      
    case when trim(gift_event_id) in ('null', '') then null else trim(gift_event_id) end as gift_event_id,  
    link_sku_id,
    case when trim(link_sku_code) in ('null', '') then null else trim(link_sku_code) end as link_sku_code, 
    sku_average_score,
	sku_average_count,
    case when trim(image_tags) in ('null', '') then null else trim(image_tags) end as image_tags,
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_SKU
where dt = @dt;
END
GO
