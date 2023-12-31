/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_SKU_Image]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_SKU_Image] AS
BEGIN
truncate table STG_Product.PROD_SKU_Image;
insert into STG_Product.PROD_SKU_Image
select 
    id,
    sku_id,
    type,
    case when trim(sku_code) in ('null','') then null else trim(sku_code) end as sku_code,
    case when trim(path) in ('null','') then null else trim(path) end as path,
    case when trim(videoId) in ('null','') then null else trim(videoId) end as videoId,
    sequence,
    update_time,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    create_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    is_delete,
    version,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Product.PROD_SKU_Image
) t
where rownum = 1
END
GO
