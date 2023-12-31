/****** Object:  StoredProcedure [DWD].[SP_DIM_Store]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Store] AS
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
-- 2023-05-16       wangzhichun    update StoreInfo\OMS_Store_Info to ods       
-- 2023-06-06       wangziming     add column CityEnName & ComparableStore
-- ========================================================================================
truncate table DWD.DIM_Store;
with new_store as
(
	select 
		a.StoreNo,
		a.StoreNameCN,
		a.StoreNameEN,
		case when b.province_short_name is not null then b.province_short_name else a.Province end as province,
		case when c.city_name is not null then c.city_name else a.city end as city,
		a.District,
		a.Address,
		a.GreatRegion,
		a.Region,
		a.DistrictRegion,
		a.StoreOpenDate,
		a.PhoneNumber,
		a.BusinessHour,
		a.StoreStaffMail,
		a.Status,
		a.Location,
		a.Makeup15min,
		a.FullMakeUp,
		a.Area,
		a.StoreType,
		a.SEG,
		a.relooking_start_date,
		a.relooking_end_date,
		a.lease_start_date,
		a.lease_end_date,
		a.close_date,
		a.cityenname,
		a.comparablestore
	from 
	(
		select *, row_number() over(partition by StoreNo order by StoreOpenDate desc) rownum from ODS_NSO.StoreInfo 
	) a
	left join 
	(
		select distinct province_short_name, province_name from DW_Common.DIM_Area
	) b 
	on a.province = b.province_name 
	left join 
	(
		select distinct case when city_short_name = N'重庆' then N'重庆市' else city_name end as city_name, city_short_name from DW_Common.DIM_Area
	) c
	on a.city = c.city_short_name
	where 
		a.rownum = 1
)

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
	ns.cityenname,
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
	ns.comparablestore,
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
	new_store ns
on ss.store_code = ns.storeno
left join
    ODS_OMS.OMS_Store_Mapping osm
on ss.Store_Code = osm.store_code
left join
    ODS_OMS.OMS_Store_Info os
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
	null as nso_store_name_en,
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
	null as nso_comparable_store,
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
	new_store ns
on ss.store_code = ns.storeno
left join
    ODS_OMS.OMS_Store_Mapping osm
on ss.Store_Code = osm.store_code
left join
    ODS_OMS.OMS_Store_Info os
on osm.store_id = os.store_id
where ss.store_code is null
END
GO
