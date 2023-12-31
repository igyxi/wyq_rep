/****** Object:  StoredProcedure [DW_Product].[SP_DIM_Category]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Product].[SP_DIM_Category] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- ========================================================================================
truncate table DW_Product.DIM_Category;
insert into DW_Product.DIM_Category
select
    id as category_id,
    name_en,
    name_cn,
    level as level_id,
    parent_id,
    case when is_disable = 1 then 0 else 1 end,
    is_delete,
    null create_time,
    update_time,
    current_timestamp as insert_timestamp
from
    STG_Product.prod_group
where 
    catalog_id = 10052;
end



GO
