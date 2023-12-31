/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Sensor_User_Info]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Sensor_User_Info] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       eddie.zhang    Initial Version
-- 2022-07-18       tali           add HarmonyOS for android_id
-- ========================================================================================
delete from DW_Sensor.DWS_Sensor_User_Info where dt = @dt;
insert into DW_Sensor.DWS_Sensor_User_Info
select distinct
    a.user_id,
    coalesce(a.vip_card,b.vip_card_no,b.vip_card) as card_no,
    case
        when PATINDEX('%[^0-9]%',a.userid) = 0 and len(a.userid) between 1 and 10 then a.userid
        when len(b.userId) between 1 and 10 and b.userId > 0 then cast(b.userId as varchar(8000))
        when PATINDEX('%[^0-9]%',a.distinct_id) = 0 and len(a.distinct_id) between 1 and 10 and CHARINDEX('-',a.distinct_id) = 0 and CHARINDEX('.',a.distinct_id) = 0 then a.distinct_id
        when PATINDEX('%[^0-9]%',b.second_id) = 0 and len(b.second_id) between 1 and 10 and CHARINDEX('-',b.second_id) = 0 and CHARINDEX('.',b.second_id) = 0 then b.second_id
        when PATINDEX('%[^0-9]%',b.first_id) = 0 and len(b.first_id) between 1 and 10 and CHARINDEX('-',b.first_id) = 0 and CHARINDEX('.',b.first_id) = 0 then b.first_id
        else NULL
    end as sephora_user_id,
    case
        when a.platform_type = 'app' and ss_os = 'iOS' and ((ISNUMERIC(a.ss_device_id) = 0 and len(a.ss_device_id) <= 10) or (len(a.ss_device_id) > 10)) then a.ss_device_id
        when a.platform_type = 'app' and ss_os = 'iOS' and (CHARINDEX('-',a.distinct_id) = 9 and CHARINDEX('-',a.distinct_id,10) = 14 and CHARINDEX('-',a.distinct_id,15) = 19 and CHARINDEX('-',a.distinct_id,20) = 24 and PATINDEX('%[^A-Z0-9-]%',a.distinct_id) = 0) then a.distinct_id
        when b.idfa is not null then b.idfa
        when a.platform_type = 'app' and ss_os = 'iOS' and (CHARINDEX('-',b.first_id) = 9 and CHARINDEX('-',b.first_id,10) = 14 and CHARINDEX('-',b.first_id,15) = 19 and CHARINDEX('-',b.first_id,20) = 24 and PATINDEX('%[^A-Z0-9-]%',b.first_id) = 0) then b.first_id
        when a.platform_type = 'app' and ss_os = 'iOS' and (CHARINDEX('-',b.second_id) = 9 and CHARINDEX('-',b.second_id,10) = 14 and CHARINDEX('-',b.second_id,15) = 19 and CHARINDEX('-',b.second_id,20) = 24 and PATINDEX('%[^A-Z0-9-]%',b.second_id) = 0) then b.second_id 
        else null
    end as idfa,
    case 
        when a.platform_type = 'app' and ss_os in ('Android', 'HarmonyOS') and len(a.ss_device_id) between 13 and 16 and PATINDEX('%[^a-f0-9]%',a.ss_device_id) = 0 then a.ss_device_id
        when a.platform_type = 'app' and ss_os in ('Android', 'HarmonyOS') and len(a.distinct_id) between 13 and 16 and PATINDEX('%[^a-f0-9]%',a.distinct_id) = 0 then a.distinct_id
        when b.androidid is not null then b.androidid
        when a.platform_type = 'app' and ss_os in ('Android', 'HarmonyOS') and len(b.first_id) between 13 and 16 and PATINDEX('%[^a-f0-9]%',b.first_id) = 0 then b.first_id
        when a.platform_type = 'app' and ss_os in ('Android', 'HarmonyOS') and len(b.second_id) between 13 and 16 and PATINDEX('%[^a-f0-9]%',b.second_id) = 0 then b.second_id
        else null
    end as android_id,
    case 
        when a.platform_type = 'app' and ss_os in ('Android', 'HarmonyOS') and PATINDEX('%[^0-9]%',a.ss_device_id) = 0 and len(a.ss_device_id) between 15 and 17 then a.ss_device_id
        when a.platform_type = 'app' and ss_os in ('Android', 'HarmonyOS') and PATINDEX('%[^0-9]%',a.distinct_id) = 0 and len(a.distinct_id) between 15 and 17 then a.distinct_id
        when b.imei is not null then b.imei
        when a.platform_type = 'app' and ss_os in ('Android', 'HarmonyOS') and PATINDEX('%[^0-9]%',b.first_id) = 0 and len(b.first_id) between 15 and 17 then b.first_id
        when a.platform_type = 'app' and ss_os in ('Android', 'HarmonyOS') and PATINDEX('%[^0-9]%',b.second_id) = 0 and len(b.second_id) between 15 and 17 then b.second_id
        else null
    end as imei,
    b.oaid,
    case
        when a.platform_type = 'MiniProgram' and left(upper(a.distinct_id),3) = 'OQ6' then a.distinct_id
        when a.platform_type = 'MiniProgram' and left(upper(b.first_id),3) = 'OQ6' then b.first_id
        when a.platform_type = 'MiniProgram' and left(upper(b.second_id),3) = 'OQ6' then b.second_id
        else b.unionId
    end as union_id,
    case
        when a.platform_type = 'MiniProgram' and (left(upper(a.distinct_id),3) = 'O8X' or left(upper(a.distinct_id),3) = 'OCO' or left(upper(a.distinct_id),3) = 'OQK') then a.distinct_id
        when a.platform_type = 'MiniProgram' and (left(upper(b.first_id),3) = 'O8X' or left(upper(b.first_id),3) = 'OCO' or left(upper(b.first_id),3) = 'OQK') then b.first_id
        when a.platform_type = 'MiniProgram' and (left(upper(b.second_id),3) = 'O8X' or left(upper(b.second_id),3) = 'OCO' or left(upper(b.second_id),3) = 'OQK') then b.second_id
        else b.openId
    end as open_id,
    case 
        when a.platform_type = 'MiniProgram' and (left(upper(a.distinct_id),3) <> 'OQ6' and left(upper(a.distinct_id),3) <> 'O8X' and left(upper(a.distinct_id),3) <> 'OCO' and left(upper(a.distinct_id),3) <> 'OQK' and len(a.distinct_id) > 10 or (ISNUMERIC(a.distinct_id) = 0 and len(a.distinct_id) <= 10)) then a.distinct_id
        when a.platform_type = 'MiniProgram' and (left(upper(b.first_id),3) <> 'OQ6' and left(upper(b.first_id),3) <> 'O8X' and left(upper(b.first_id),3) <> 'OCO' and left(upper(b.first_id),3) <> 'OQK' and len(b.first_id) > 10 or (ISNUMERIC(b.first_id) = 0 and len(b.first_id) <= 10)) then b.first_id
        when a.platform_type = 'MiniProgram' and (left(upper(b.second_id),3) <> 'OQ6' and left(upper(b.second_id),3) <> 'O8X' and left(upper(b.second_id),3) <> 'OCO' and left(upper(b.second_id),3) <> 'OQK' and len(b.second_id) > 10 or (ISNUMERIC(b.second_id) = 0 and len(b.second_id) <= 10)) then b.second_id
        else NULL
    end as mnp_uuid,
    case 
        when a.platform_type not in ('app','MiniProgram') and ((ISNUMERIC(a.distinct_id) = 0 and len(a.distinct_id) <= 10) or (len(a.distinct_id) > 10)) then a.distinct_id
        when a.platform_type not in ('app','MiniProgram') and ((ISNUMERIC(b.first_id) = 0 and len(b.first_id) <= 10) or (len(b.first_id) > 10)) then b.first_id
        when a.platform_type not in ('app','MiniProgram') and ((ISNUMERIC(b.second_id) = 0 and len(b.second_id) <= 10) or (len(b.second_id) > 10)) then b.second_id
        else NULL
    end as js_id,
    b.first_id,
    b.second_id,
    current_timestamp as insert_timestamp,
    @dt as dt
from 
(
    select distinct
        user_id,
        distinct_id,
        platform_type,
        ss_os,
        ss_device_id,
        userid,
        vip_card
    from
        [STG_Sensor].[Events]
    where 
        dt = @dt
) a
left join 
    [STG_Sensor].[Users] b
on a.user_id = b.id;
update statistics DW_Sensor.DWS_Sensor_User_Info;
END
GO
