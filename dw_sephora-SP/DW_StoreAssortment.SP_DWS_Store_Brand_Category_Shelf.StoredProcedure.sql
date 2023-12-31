/****** Object:  StoredProcedure [DW_StoreAssortment].[SP_DWS_Store_Brand_Category_Shelf]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_StoreAssortment].[SP_DWS_Store_Brand_Category_Shelf] AS
BEGIN
TRUNCATE table DW_StoreAssortment.DWS_Store_Brand_Category_Shelf;
with chloe_store as (
    select distinct t.store from 
    (
        select a.store, a.sapcode, a.mini
        from ods_jda.cn_mini a 
        join ( select max(dt) dt from ods_jda.cn_mini ) b 
        on a.dt = b.dt
    ) t
    join 
    (
        select distinct store_code from DW_StoreAssortment.DIM_Offline_Store_Attr
    ) s
    on t.store = s.store_code
    join
    (
        select distinct
            b.product_id, 
            b.brand_type, 
            b.brand, 
            b.category, 
            b.sku_code, 
            b.[target], 
            b.product_name, 
            b.product_name_en, 
            b.[Range], 
            b.Segment, 
            b.skincare_function, 
            b.brand_code
        from 
            DW_StoreAssortment.DWS_TXN_Store_SKU_SDL a 
        join 
            ODS_CRM.DimProduct b 
        on a.product_id = b.product_id 
    ) t1
    on t.sapcode = t1.sku_code
    where t1.brand = 'CHLOE' and t1.category = 'FRAGRANCE' and product_name_en like '%ATELIER DES FLEURS%'
), 
shelf_agg as (
    select 
        store_code,
        brand,
        category,
        sum(shelf) as shelf
    from
    (
        select 
            store_code, 
            pog_name, 
            pog_version, 
            brand, 
            try_cast(shelf as float) as shelf, 
            country, 
            case 
                when category in ('SKIN CARE', 'DEVICE', 'MEN SKIN') then 'SKINCARE' 
                when category = 'HAIR CARE' then 'HAIRCARE' 
                when pog_name = 'TWEEZERMAN/SHO-BI' then 'ACCESSORIES' 
                else upper(category) 
            end as category, 
            fp_live_date, 
            start_date, 
            end_date, 
            a.dt as weekstartdate 
        from 
            ODS_JDA.Space_Shelf_Meter a 
        join 
            (select max(dt) dt from ODS_JDA.Space_Shelf_Meter) b 
        on a.dt = b.dt 
    ) t
    where 
        category in ('SKINCARE', 'MAKE UP', 'FRAGRANCE')
    and pog_name <> 'MEN SC'
    group by 
        store_code,
        brand,
        category
),
store_shelf_opp as (
    select d.Store_Code, c.brand, c.category, c.tagging
    from 
        ODS_StoreAssortment.Dim_Shelf_Opportunity c 
    join 
    (select distinct store_code from shelf_agg) d
    on 1=1
    where c.dt = '2021-11-25'
),
store_category_brand as (
    select distinct store_code,brand,category
    from
    (
        select Store_Code, brand, category from store_shelf_opp
        union all
        select store_code, brand, category from shelf_agg
    ) t
)
insert into DW_StoreAssortment.DWS_Store_Brand_Category_Shelf
select 
    s.Store_Code,
    s.brand,
    s.category,
    t.shelf,
    r.tagging,
    case when t.shelf is not null or r.tagging = 'Opportunity' then 1 else 0 end as ind_opportunity,
    case when r.tagging = 'Already removed' then 1 else 0 end as ind_already_remove,
    CURRENT_TIMESTAMP
from 
    store_category_brand s
left join
(
    select a.store_code, a.Brand, a.category, a.shelf from shelf_agg a left join chloe_store b on a.Brand = 'CHLOE' and a.Store_Code = b.store where b.store is null
    union all
    select a.Store_Code, a.Brand, a.category, a.shelf/2 as shelf from shelf_agg a join chloe_store b on a.Brand = 'CHLOE' and a.Store_Code = b.store
    union all
    select a.Store_Code, a.Brand, 'CHLOE_ADF' as category, a.shelf - a.shelf/2 as shelf from shelf_agg a join chloe_store b on a.Brand = 'CHLOE' and a.Store_Code = b.store
) t
on 
    s.Store_Code = t.Store_Code
and s.Brand = t.brand
and s.category = t.category
left join
    store_shelf_opp r
on s.Store_Code =r.Store_Code
and s.brand = r.brand
and s.category = r.category;
END
GO
