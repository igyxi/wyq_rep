/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_SKU_Attrval_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_SKU_Attrval_REL] AS
BEGIN
truncate table STG_Product.PROD_SKU_Attrval_REL ;
insert into STG_Product.PROD_SKU_Attrval_REL
select 
    sku_id, 
    attr_id, 
    attrval_id, 
    sequence, 
    type,
    create_time,        
    update_time,        
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,        
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,        
    is_delete, 
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by sku_id, attr_id, attrval_id order by dt desc) rownum from ODS_Product.PROD_SKU_Attrval_REL
) t
where rownum = 1
END


GO
