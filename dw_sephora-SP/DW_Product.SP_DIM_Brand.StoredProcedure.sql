/****** Object:  StoredProcedure [DW_Product].[SP_DIM_Brand]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Product].[SP_DIM_Brand] AS 
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- ========================================================================================
truncate table DW_Product.DIM_Brand;
insert into DW_Product.DIM_Brand
select 
    id as brand_id,
    name_en,
    name_cn,
    brand_nick_name as nick_name,
    is_exclusive,
    case when is_disable = 1 then 0 else 1 end as is_disable,
    is_delete,
    has_story,
    create_time,
    update_time,
    current_timestamp as insert_timestamp
from 
    STG_Product.PROD_Group
where 
    catalog_id = 10056 
and parent_id = 0
end

GO
