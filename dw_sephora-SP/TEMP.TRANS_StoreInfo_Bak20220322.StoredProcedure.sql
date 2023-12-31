/****** Object:  StoredProcedure [TEMP].[TRANS_StoreInfo_Bak20220322]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[TRANS_StoreInfo_Bak20220322] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-02-21       Eric           Creat TRANS
-- ========================================================================================
truncate table STG_NSO.StoreInfo;
insert into STG_NSO.StoreInfo
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
    current_timestamp as insert_timestamp
from
    ODS_NSO.StoreInfo
where 
    dt = @dt
-- (
--     select *, row_number() over(partition by merge_order_sys_id order by dt desc) rownum from ODS_OMS.Merge_Order_Log
-- ) t
-- where rownum = 1
END

GO
