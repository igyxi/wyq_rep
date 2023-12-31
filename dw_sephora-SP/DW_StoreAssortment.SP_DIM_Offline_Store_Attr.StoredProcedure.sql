/****** Object:  StoredProcedure [DW_StoreAssortment].[SP_DIM_Offline_Store_Attr]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_StoreAssortment].[SP_DIM_Offline_Store_Attr] @dt [VARCHAR](10) AS
BEGIN
truncate table DW_StoreAssortment.DIM_Offline_Store_Attr;
insert into DW_StoreAssortment.DIM_Offline_Store_Attr
select 
    store_id,
    a.store_code,
    -- a.store_name as store_name_en,
    b.store_name,
    store_type,
    open_date,
    close_date,
    region,
    c.city,
    c.province,
    region_gov,
    region_client,
    c.city_tier,
    c.city_rank,
    CURRENT_TIMESTAMP
from
(
    select 
        store_code, 
        store as store_name, 
        store_type, 
        TRY_CONVERT([date], opening_date) as open_date, 
        closing_date 
    from 
        ODS_SAP.Dim_Store
    
    where Country_Code = 'CN' 
    and Sales_Area not in ('Head Office China', 'eStore China')
) a
left join
(
    select 
        [store_id], 
        [store_code], 
        [region],
        [city], 
        [close_date],
        [store_name]
    from 
        ods_crm.dimstore 
) b
on a.store_code = b.store_code collate Chinese_PRC_CS_AI_WS
left join
(
    select 
        city, 
        province, 
        region_gov, 
        region_client, 
        city_tier, 
        city_rank 
    from 
        ods_storeassortment.dim_city 
    where
        dt = '2021-11-25'
) c
on lower(b.city) = lower(c.city) collate Chinese_PRC_CS_AI_WS;
END

GO
