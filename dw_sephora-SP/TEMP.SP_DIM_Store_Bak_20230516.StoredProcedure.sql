/****** Object:  StoredProcedure [TEMP].[SP_DIM_Store_Bak_20230516]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Store_Bak_20230516] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-10       Tali           Initial Version
-- 2022-03-03       Tali           add STG_NSO.StoreInfo
-- 2022-03-21       tali           remove STG_NSO.StoreInfo
-- 2022-06-01       Tali           add crm_store_channel
-- 2022-07-25       Tali           add nso and channel
-- 2022-12-01       wangzhichun    add storetype and seg
-- 2023-01-06       wangzhichun    add column 
-- ========================================================================================
truncate table DWD.DIM_Store;
insert into DWD.DIM_Store
select 
	ss.Store_Code,
	ss.Store as sap_store_name,
	ss.Network_Code,
	ss.Network,
	ss.Sales_Area_Code,
	ss.Sales_Area,
	ss.Company_Code,
	ss.Company,
	ss.Country_Code,
	ss.Country,
	ss.City,
	ss.Street,
	ss.Long_Store_Code,
	TRY_CONVERT(date, ss.Opening_Date, 112) as open_Date,
	TRY_CONVERT(date, ss.Closing_Date, 112) as close_date,
	ss.Store_Type,
	ss.Sales_Surface,
	ss.Area_Unit,
	ss.Block_Reason,
	TRY_CONVERT(date, ss.Block_Start_Date, 112) as Block_Start_Date,
	TRY_CONVERT(date, ss.Block_End_Date, 112) as Block_End_Date,
	ss.Postal_Code,
	ss.Geographical_Area,
	cs.store_name,
	cs.store_name_en,
	cs.region,
	cs.area,
	cs.district,
	cs.open_date,
	cs.close_date,
	cs.country_code,
	cs.province_name,
	cs.city_name,
	cs.store_ABC,
    cs.store_channel,
	cs.store_sub_channel,
	cs.qualify_the_offer,
	cs.geography,
	cs.street_access,
	cs.social_status,
	cs.customers,
	cs.competition,
	cs.neighboring_anchor,
	cs.sales_surface as crm_sales_surface,
    ns.storenamecn,
    ns.storenameen,
    ns.province,
    ns.city,
    ns.district,
    ns.address,
    ns.greatregion,
    ns.region,
    ns.districtregion,
    ns.storeopendate,
    ns.status,
    ns.location,
    ns.makeup15min,
    ns.fullmakeup,
    try_cast(ns.area as decimal),
    ns.storetype,
    ns.seg,
	ns.relooking_start_date,
	ns.relooking_end_date,
	ns.lease_start_date,
	ns.lease_end_date,
	ns.close_date,
    os.channel_id,
    os.channel_name,
    os.store_id,
    os.store_name,
	'SAP' as source,
	current_timestamp as insert_timestamp
from 
	[ODS_SAP].[Dim_Store] ss 
left join 
	[DW_CRM].[DIM_Store] cs
on ss.store_code=cs.store_code
left join
	STG_NSO.StoreInfo ns
on ss.store_code =convert(nvarchar(500), ns.storeno)
left join
    stg_oms.OMS_Store_Mapping osm
on ss.Store_Code = osm.store_code
left join
    STG_OMS.OMS_Store_Info os
on osm.store_id = os.store_id
union all 
select 
	cs.Store_Code,
	ss.Store as sap_store_name,
	ss.Network_Code,
	ss.Network,
	ss.Sales_Area_Code,
	ss.Sales_Area,
	ss.Company_Code,
	ss.Company,
	ss.Country_Code,
	ss.Country,
	ss.City,
	ss.Street,
	ss.Long_Store_Code,
	TRY_CONVERT(date, ss.Opening_Date, 112) as open_Date,
	TRY_CONVERT(date, ss.Closing_Date, 112) as close_date,
	ss.Store_Type,
	ss.Sales_Surface,
	ss.Area_Unit,
	ss.Block_Reason,
	ss.Block_Start_Date,
	ss.Block_End_Date,
	ss.Postal_Code,
	ss.Geographical_Area,
	cs.store_name,
	cs.store_name_en,
	cs.region,
	cs.area,
	cs.district,
	cs.open_date,
	cs.close_date,
	cs.country_code,
	cs.province_name,
	cs.city_name,
	cs.store_ABC,
    cs.store_channel,
	cs.store_sub_channel,
	cs.qualify_the_offer,
	cs.geography,
	cs.street_access,
	cs.social_status,
	cs.customers,
	cs.competition,
	cs.neighboring_anchor,
	cs.sales_surface as crm_sales_surface,
	ns.storenamecn,
    ns.storenameen,
    ns.province,
    ns.city,
    ns.district,
    ns.address,
    ns.greatregion,
    ns.region,
    ns.districtregion,
    ns.storeopendate,
    ns.status,
    ns.location,
    ns.makeup15min,
    ns.fullmakeup,
    try_cast(ns.area as decimal),
    ns.storetype,
    ns.seg,
	ns.relooking_start_date,
	ns.relooking_end_date,
	ns.lease_start_date,
	ns.lease_end_date,
	ns.close_date,
    os.channel_id,
    os.channel_name,
    os.store_id,
    os.store_name,
	'crm' as source,
	current_timestamp as insert_timestamp
from 
	[DW_CRM].[DIM_Store] cs
left join 
	[ODS_SAP].[Dim_Store] ss 
on cs.store_code=ss.store_code
left join
	STG_NSO.StoreInfo ns
on ss.store_code =convert(nvarchar(500), ns.storeno)
left join
    stg_oms.OMS_Store_Mapping osm
on ss.Store_Code = osm.store_code
left join
    STG_OMS.OMS_Store_Info os
on osm.store_id = os.store_id
where ss.store_code is null
-- left join 
-- (
-- 	select 
-- 		b.province_name,
-- 		c.city_name,
-- 		a.storeno,
-- 		a.storenamecn,
-- 		a.storenameen,
-- 		a.province,
-- 		a.city,
-- 		a.district,
-- 		a.address,
-- 		a.greatregion,
-- 		a.region,
-- 		a.districtregion,
-- 		a.storeopendate,
-- 		a.[location],
-- 		a.area
-- 	from 
-- 		STG_NSO.StoreInfo a 
-- 	left join 
-- 	(
-- 		select distinct province_short_name, province_name from DW_Common.DIM_Area
-- 	) b 
-- 	on a.province = b.province_short_name 
-- 	left join 
-- 	(
-- 		select distinct case when city_short_name = N'重庆' then N'重庆市' else city_name end as city_name, city_short_name from DW_Common.DIM_Area
-- 	) c
-- 	on a.city = c.city_short_name 
-- ) RT
-- on a.store_code = RT.storeno
END

GO
