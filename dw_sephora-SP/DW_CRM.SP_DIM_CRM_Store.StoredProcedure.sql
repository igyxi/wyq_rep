/****** Object:  StoredProcedure [DW_CRM].[SP_DIM_CRM_Store]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_CRM].[SP_DIM_CRM_Store] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-21       tali           Initial Version
-- ========================================================================================
truncate table DW_CRM.DIM_CRM_Store;
insert into DW_CRM.DIM_CRM_Store
select 
    place_id,   
    CASE WHEN LEN(place_code)<4 AND P.country_id = 1 THEN CAST('6'+right('00'+place_code,3) as NVARCHAR(4)) ELSE place_code END as store_code,    
    CASE WHEN p.place_name LIKE '6%' THEN SUBSTRING(p.place_name,6,LEN(p.place_name)) ELSE p.place_name END as store_name,
    case when place_name_en like '6%' then substring(place_name_en,6,len(place_name_en)) else place_name_en end as store_name_en,
    CASE WHEN s.region NOT LIKE '%Region%' THEN RTRIM(s.region) + ' Region'   
        WHEN s.region LIKE 'EBUSINESS%' THEN 'EBUSINESS'   
        ELSE replace(s.region, 'region', 'Region')
    END as region,  
    case when trim(s.area) = '' then null else trim(s.area) end as area,  
    s.district,
    -- s.country_code,
    CASE WHEN s.country_code IS NULL THEN c.country_code ELSE s.country_code END country_code,
    pc.province_name_en,
    pc.province_name,
    pc.city_name_en,
    pc.city_name,
    -- CASE when o.city IS NULL OR o.city = '' THEN c.city_name_en   
    --     ELSE o.city   
    -- END city,  --isnull(o.city,c.city_name_en) city,   
    ISNULL(convert(date, s.opening_date, 112), p.openning_date) open_date,  
    ISNULL(convert(date, s.closing_date, 112), p.close_date) close_date, 
    s.Distribution_channel_1 as store_channel,
    s.distribution_channel_2 as store_sub_channel, 
    -- CASE 
    --     WHEN s.Distribution_channel_1 = 'Retail' THEN 1   
    --     WHEN s.Distribution_channel_1 = 'Web' OR s.Distribution_channel_1 = 'Online' OR s.store_code = '6999' THEN 2   
    --     ELSE 3   
    -- END store_channel_id,  
    -- CASE WHEN ocs.store_code IS NOT NULL THEN 1 ELSE 0 END is_comparable_store,  
    s.store_ABC_1 as store_abc, 
    s.city_tiers,  
    s.geography_city_tier,
    s.qualify_the_offer,
    s.geography,
    -- s.atypical,  
    s.street_access,
    s.social_status,  
    s.customers,
    s.competition,  
    s.neighboring_anchor,  
    s.sales_surface,  
    -- s.VAT ,  
    -- s.reserved1 ,  
    -- s.reserved2 ,  
    p.place_code as store_code_crm,
    CURRENT_TIMESTAMP as insert_timestamp
from 
    ODS_CRM.place p 
-- left join ODS_imp_Stores o on p.store_code=o.store_code  
left join 
    ODS_CRM.CN_stores s 
ON CASE WHEN LEN(p.place_code)<4 AND p.country_id = 1 THEN '6'+right('00'+p.place_code,3) ELSE place_code END = s.store_code
left join
    ODS_CRM.knCountry c
on p.country_id = c.country_id
left join (
    select distinct
        c.city_id,
        c.city_name,
        c.city_name_en,
        p.province_name,
        p.province_name_en
    from 
        ODS_CRM.city c
    join 
        ODS_CRM.province p on c.province_id = p.province_id
) pc 
on p.city_id=pc.city_id;
end
GO
