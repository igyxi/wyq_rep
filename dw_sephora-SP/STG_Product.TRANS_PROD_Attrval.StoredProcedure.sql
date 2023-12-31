/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Attrval]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Attrval] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_Product.PROD_Attrval ;
insert into STG_Product.PROD_Attrval
select 
    id, 
    attr_id, 
    case when trim(value) in ('null', '') then null else trim(value) end as value,
    sequence, 
    type, 
    is_deleted, 
    is_disable, 
    update_time,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    wcs_attr_id, 
    wcs_attrval_id, 
    is_search, 
    is_show,
    create_time,        
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_Attrval
where dt = @dt
END
GO
