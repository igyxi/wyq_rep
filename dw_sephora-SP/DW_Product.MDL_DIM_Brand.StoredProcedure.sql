/****** Object:  StoredProcedure [DW_Product].[MDL_DIM_Brand]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Product].[MDL_DIM_Brand] AS 
begin
truncate table DW_Product.DIM_Brand;
insert into DW_Product.DIM_Brand
select 
    a.id as brand_id,
    a.name_en,
    a.name_cn,
    a.brand_nick_name as nick_name,
    c.brand_type as type_cd,
    a.is_exclusive,
    case when a.is_disable = 1 then 0 else 1 end as is_disable,
    a.is_delete,
    a.has_story,
    null create_time,
    a.update_time,
    current_timestamp as insert_timestamp
from 
(
    select * from STG_Product.PROD_Group where catalog_id = 10056 and parent_id = 0
) a
left join
(
    select distinct brand, brand_type from stg_Product.SKU_Mapping
) c
on upper(a.name_en) = upper(c.brand);
end
GO
