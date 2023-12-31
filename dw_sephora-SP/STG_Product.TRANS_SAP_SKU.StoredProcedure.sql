/****** Object:  StoredProcedure [STG_Product].[TRANS_SAP_SKU]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_SAP_SKU] AS
BEGIN
truncate table STG_Product.SAP_SKU ;
insert into STG_Product.SAP_SKU
select 
    id,
    case when trim(sku_code) in ('null', '') then null else trim(sku_code) end as sku_code,
    case when trim(sku_name) in ('null', '') then null else trim(sku_name) end as sku_name,
    case when trim(brand) in ('null', '') then null else trim(brand) end as brand,
    sap_price,
    case when trim(sap_desc) in ('null', '') then null else trim(sap_desc) end as sap_desc,
    case when trim(barcode) in ('null', '') then null else trim(barcode) end as barcode,
    case when trim(taxrate) in ('null', '') then null else trim(taxrate) end as taxrate,
    case when trim(weight) in ('null', '') then null else trim(weight) end as weight,
    status,
    create_time,
    case when trim(value) in ('null', '') then null else trim(value) end as value,
    update_time,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    case when trim(country) in ('null', '') then null else trim(country) end as country,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Product.SAP_SKU
) t
where rownum = 1
END


GO
