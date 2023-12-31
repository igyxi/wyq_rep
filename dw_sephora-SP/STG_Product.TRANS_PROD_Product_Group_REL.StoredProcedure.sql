/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Product_Group_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Product_Group_REL] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-31       wangzhichun        Initial Version
-- 2023-06-02       Leozhai            Add logic to convert varbinary
-- ========================================================================================
truncate table STG_Product.PROD_Product_Group_REL ;
insert into STG_Product.PROD_Product_Group_REL
select 
    id,
    product_id,
    case when trim(group_data) in ('null', '') then null else trim(group_data) end as group_data,
    --APPLY(varchar(4000),group_data,0) as group_data,
    sequence,
    catalog_id,
    create_time,        
    update_time,        
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,        
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,        
    is_delete,
    current_timestamp as insert_timestamp
from 
    ODS_Product.PROD_Product_Group_REL
where dt = @dt
END
GO
