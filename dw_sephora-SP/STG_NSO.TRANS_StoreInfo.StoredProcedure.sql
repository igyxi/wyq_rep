/****** Object:  StoredProcedure [STG_NSO].[TRANS_StoreInfo]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_NSO].[TRANS_StoreInfo] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-21       Eric           Creat TRANS
-- 2022-03-22       Tali           add DW_Common.DIM_Area
-- 2022-06-26       Tali           fix storeno duplicate
-- 2022-12-01       wangzhichun    add column
-- 2022-01-05       wangzhichun    add column 
-- ========================================================================================
truncate table STG_NSO.StoreInfo;
insert into STG_NSO.StoreInfo
select
    a.StoreNo,
    a.StoreNameCN,
    a.StoreNameEN,
    case when b.province_short_name is not null then b.province_short_name else a.Province end,
    case when c.city_name is not null then c.city_name else a.city end,
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
    current_timestamp as insert_timestamp
from
(
    select 
        StoreNo,
        case when trim(StoreNameCN) in ('null','') then null else trim(StoreNameCN) end as StoreNameCN,
        case when trim(StoreNameEN) in ('null','') then null else trim(StoreNameEN) end as StoreNameEN,
        case when trim(Province) in ('null','') then null else trim(Province) end as Province,
        case when trim(City) in ('null','') then null else trim(City) end as City,
        case when trim(District) in ('null','') then null else trim(District) end as District,
        case when trim(Address) in ('null','') then null else trim(Address) end as Address,
        case when trim(GreatRegion) in ('null','') then null else trim(GreatRegion) end as GreatRegion,
        case when trim(Region) in ('null','') then null else trim(Region) end as Region,
        case when trim(DistrictRegion) in ('null','') then null else trim(DistrictRegion) end as DistrictRegion,
        case when trim(StoreOpenDate) in ('null','') then null else trim(StoreOpenDate) end as StoreOpenDate,
        case when trim(PhoneNumber) in ('null','') then null else trim(PhoneNumber) end as PhoneNumber,
        case when trim(BusinessHour) in ('null','') then null else trim(BusinessHour) end as BusinessHour,
        case when trim(StoreStaffMail) in ('null','') then null else trim(StoreStaffMail) end as StoreStaffMail,
        case when trim(Status) in ('null','') then null else trim(Status) end as Status,
        case when trim(Location) in ('null','') then null else trim(Location) end as Location,
        case when trim(Makeup15min) in ('null','') then null else trim(Makeup15min) end as Makeup15min,
        case when trim(FullMakeUp) in ('null','') then null else trim(FullMakeUp) end as FullMakeUp,
        case when trim(Area) in ('null','') then null else trim(Area) end as Area,
        case when trim(StoreType) in ('null','') then null else trim(StoreType) end as StoreType,
        case when trim(SEG) in ('null','') then null else trim(SEG) end as SEG,
        relooking_start_date,
        relooking_end_date,
        lease_start_date,
        lease_end_date,
        close_date,
        row_number() over(partition by StoreNo order by StoreOpenDate desc) as rownum
    from
        ODS_NSO.StoreInfo
    where 
        dt = @dt
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
END

GO
