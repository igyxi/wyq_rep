/****** Object:  StoredProcedure [TEMP].[MDL_DIM_Product_Bak20220831]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[MDL_DIM_Product_Bak20220831] AS
begin
truncate table  DW_Product.DIM_Product;
insert into DW_Product.DIM_Product
select 
    id as product_id,
    type as type_cd,
    name_en,
    name_cn,
    origin_name_en,
    origin_name_cn,
    series_en as series_name_en,
    series_cn as series_name_cn,
    publish_time,
    unpublish_time,
    store as store_list,
    status as status_cd,
    o2o as is_o2o_flag,
    [offline] as is_offline_flag,
    is_search as is_search_flag,
    is_black as is_blacklist_flag,
    desc_text as description,
    slogan as slogan_json,
    desc_attr as attr_desc_json,
    null as create_time,
    update_time,
    current_timestamp as insert_timestamp
from
    STG_Product.PROD_Product;
end


GO
