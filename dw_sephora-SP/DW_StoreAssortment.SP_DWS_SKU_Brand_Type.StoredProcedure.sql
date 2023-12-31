/****** Object:  StoredProcedure [DW_StoreAssortment].[SP_DWS_SKU_Brand_Type]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_StoreAssortment].[SP_DWS_SKU_Brand_Type] AS 
BEGIN
truncate table DW_StoreAssortment.DWS_SKU_Brand_Type;
with franchise_sku as
(
    select * from
    (
        select 
            sku_code, 
            c.brand, 
            case when c.franchise = 'Men' and b.sap_target_description = 'MEN' then c.brand_type
                when c.franchise = 'HOME FRAGRANCES' and b.sap_range_description = 'HOME FRAGRANCE' then c.brand_type
                when c.franchise in ('ALLEGRA', 'ATELIER DES FLEURS', 'COLOGNE') and b.sap_sub_brand_name = c.franchise then c.brand_type
                else null
            end brand_type, 
            c.target_category
        from 
            STG_StoreAssortment.Dim_Brand_Type c
        left join
            DWD.DIM_SKU_Info b
        on b.sap_category_description = c.category
        and b.sap_brand_name = c.brand
        and c.franchise is not null
    ) t
    where t.brand_type is not null
)

insert into DW_StoreAssortment.DWS_SKU_Brand_Type
select 
    b.sku_code, 
    c.brand, 
    c.brand_type, 
    c.target_category, 
    CURRENT_TIMESTAMP
from 
    STG_StoreAssortment.Dim_Brand_Type c
left join
    DWD.DIM_SKU_Info b
on (b.sap_category_description = c.category or c.target_category = 'HAIRCARE')
and b.sap_brand_name = c.brand
and c.franchise is null
left join
    franchise_sku t
on b.sku_code = t.sku_code
where t.sku_code is null

union all
select 
    *, 
    CURRENT_TIMESTAMP 
from 
    franchise_sku
END
GO
