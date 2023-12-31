/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_ATTR]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_ATTR] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Product.PROD_ATTR ;
insert into STG_Product.PROD_ATTR
select 
    id,
    case when trim(seo_key) in ('null', '') then null else trim(seo_key) end as seo_key,
    case when trim(name) in ('null', '') then null else trim(name) end as name,
    sequence, 
    type, 
    is_deleted, 
    is_disabled, 
    update_time,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    wcs_id, 
    is_search, 
    is_show, 
    use_sequence,
    create_time,    
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_ATTR
where dt = @dt
END
GO
