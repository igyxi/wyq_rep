/****** Object:  StoredProcedure [STG_Product].[TRANS_PROD_Product_Sku_Rel]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Product].[TRANS_PROD_Product_Sku_Rel] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-06       hsq        Initial Version
-- ========================================================================================
truncate table STG_Product.PROD_Product_Sku_Rel ;
insert into STG_Product.PROD_Product_Sku_Rel
select
    id,
	product_id,
	sku_id,
	create_time,
	update_time,
    case when trim(create_user) in ('null', '') then null else trim(create_user) end as create_user,
    case when trim(update_user) in ('null', '') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Product.PROD_Product_Sku_Rel
) t
where rownum = 1
END
GO
