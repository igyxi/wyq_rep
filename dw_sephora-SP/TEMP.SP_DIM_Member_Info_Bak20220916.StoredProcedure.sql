/****** Object:  StoredProcedure [TEMP].[SP_DIM_Member_Info_Bak20220916]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Member_Info_Bak20220916] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-01-06       Eric           Initial Version
-- 2022-01-24       Tali           add eb_registration
-- 2022-01-27       Tali           delete collate
-- 2022-02-23       Tali           filter duplicate member card in  DimAccount and add eb user id
-- 2022-02-24       Tali           add account_status_desc
-- 2022-03-08       Tali           add begin_date end date for card type. and some column from crm
-- 2022-03-16       Tali           change dimaccount to  acount
-- 2022-03-21       Tali           change to Dim_CRM_Store
-- 2022-03-28       Tali           add account_encode_extend and change city
-- 2022-03-29       Tali           filter city aa
-- 2022-04-21       Tali           add purchase_days
-- 2022-05-25       Tali           add is_skincare_premium_tag
-- 2022-06-01       Tali           add upgrade counter / total counter / register_channel
-- 2022-06-17       Tali           fix email_address data
-- 2022-06-21       Tali           feat change is_skincare_premium_tag to makeup
-- 2022-08-22       Tali           feat change is_skincare_premium_tag to skincare_p
-- ========================================================================================

truncate table DWD.DIM_Member_Info;
insert into DWD.DIM_Member_Info
select
    a.account_id as member_id, 
    a.account_number as member_card, 
    a.account_status,
    a.account_status_desc,
    a.card_type, 
    a.begin_date,
    a.end_date,
    a.segmentation,
    a.register_source, 
    a.register_date, 
    a.register_store_code,
    a.register_channel,
    a.activation_date,
    a.account_balance,
    t.user_id as eb_user_id,
    t.registration as eb_register_time,
    a.full_name,
    a.mobile,
    a.gender,
    a.birthday,
    a.nickname,
    a.phone,
    a.email_address,
    a.post_code,
    a.province,
    a.city,
    a.address ,
    a.address_validate,
    a.is_employee,
    a.is_foreigner, 
    a.valid_dm,
    a.valid_edm,
    a.valid_sms,
    a.valid_mms,
    a.contactability,
    a.living_city,
    a.prefer_city,
    a.prefer_store_code,
    a.single_pink_card_validate_type,
    a.purchase_days,
    case when p.account_id is not null then 1 else 0 end as is_skincare_premium_tag,
    l.first_login_channel as first_login_channel,
    l.app_first_login_time as app_first_login_time,
    a.upgrade_counter,
    a.total_upgrade_counter,
    'CRM'  as source,
    CURRENT_TIMESTAMP  as  insert_timestamp
from 
(
    SELECT
        acc.account_id,
        acc.account_number,
        acc.account_status,
        case when acc.account_status = 0 then N'未激活'
            when acc.account_status = 1 then N'有效的'
            when acc.account_status = 2 then N'被合并的'
            when acc.account_status = 3 then N'被注销掉的'
            when acc.account_status = 4 then N'调用接口被注销'
            else N'未知'
        end as account_status_desc,
        acc.card_type,
        acc.effective_card_level_start_date as begin_date,
        acc.effective_card_level_end_date as end_date,    
        acc.segmentation_value_id segmentation,
        case when p.civilization_title_id = 2 then 1 else 0 end gender,
        acc.create_source as register_source,
        case when acc.create_source=1 then acc.creation_date else acc.register_date end register_date,
        s2.store_code as register_store_code,
        case when s2.store_channel = 'Retail' then 'OFF_LINE'
            when s2.store_id in ('1231','1232', '1192','3','1019','1023','1303') then 'SOA'
            when s2.store_id in ('999','1017','1018','1210','1211','1413','1440','1392') then 'JD'
            when s2.store_id in ('254','1087','1304','1339') then 'TMALL'
            when s2.store_id in ('1283','1284') then 'REDBOOK'
            when s2.store_id in ('1324','1393') then 'MEITUAN'
            when s2.store_id in ('1346','1347','1348','1419') then 'DOUYIN'
        end register_channel,
        acc.activated_time as activation_date,
        acc.account_balance as account_balance,
        acc.full_name,
        -- acc.mobile,
        aee.[mobile],
        p.birthday,
        p.pin_yin as nickname,
        p.phone,
        case when  PATINDEX('%[^0-9A-Za-z_@.-]%', REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(trim(p.email_address), CHAR(10), ''), CHAR(13), ''), CHAR (31), ''), CHAR (31), ''), '\','')) > 0 then null 
            else REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(trim(p.email_address), CHAR(10), ''), CHAR(13), ''), CHAR (31), ''), CHAR (31), ''), '\','')
        end as email_address,
        p.post_code ,
        pv.province_name as province,
        ci.city_name as city, 
        p.address,
        p.address_validate_flag as address_validate,
        acc.is_employee,
        p.is_foreigner,
        CASE WHEN ISNULL(p.address_validate_flag, 0) = 1
                    AND ISNULL(p.postal_address_option, 'Y') = 'Y'
                    AND p.full_name IS NOT NULL
                    AND p.[ADDRESS] IS NOT NULL THEN 1
                ELSE 0
        END valid_DM,
        CASE WHEN ISNULL(p.email_validate_flag, 0) = 1
                    AND ISNULL(p.email_option, 'Y') = 'Y' THEN 1
                ELSE 0
        END valid_EDM,
        CASE WHEN ISNULL(sms_validate_flag, 0) = 1
                    AND ISNULL(mobile_option, 'Y') = 'Y' THEN 1
                ELSE 0
        END valid_SMS,
        CASE WHEN ISNULL(mms_validate_flag, 0) = 1
                    AND ISNULL(mobile_option, 'Y') = 'Y' THEN 1
                ELSE 0
        END valid_MMS,
        CASE WHEN ISNULL(p.address_validate_flag, 0) = 1 AND ISNULL(p.postal_address_option, 'Y') = 'Y'
            AND (ISNULL(p.sms_validate_flag, 0) = 0 OR ISNULL(p.mobile_option, 'Y') = 'N')
            AND (ISNULL(p.email_validate_flag, 0) = 0 OR ISNULL(p.email_option, 'Y') = 'N') 
            THEN 1
            WHEN (ISNULL(p.address_validate_flag, 0) = 0 OR ISNULL(p.postal_address_option, 'Y') = 'N')
            AND (ISNULL(p.sms_validate_flag, 0) = 0 OR ISNULL(p.mobile_option, 'Y') = 'N')
            AND ISNULL(p.email_validate_flag, 0) = 1 AND ISNULL(p.email_option, 'Y') = 'Y' 
            THEN 2
            WHEN (ISNULL(p.address_validate_flag, 0) = 0 OR ISNULL(p.postal_address_option, 'Y') = 'N')
            AND ISNULL(p.sms_validate_flag, 0) = 1 AND ISNULL(p.mobile_option, 'Y') = 'Y'
            AND (ISNULL(p.email_validate_flag, 0) = 0 OR ISNULL(p.email_option, 'Y') = 'N') 
            THEN 3
            WHEN ISNULL(p.address_validate_flag, 0) = 1 AND ISNULL(p.postal_address_option, 'Y') = 'Y'
            AND (ISNULL(p.sms_validate_flag, 0) = 0 OR ISNULL(p.mobile_option, 'Y') = 'N')
            AND ISNULL(p.email_validate_flag, 0) = 1 AND ISNULL(p.email_option, 'Y') = 'Y'
            THEN 4
            WHEN ISNULL(p.address_validate_flag, 0) = 1 AND ISNULL(p.postal_address_option, 'Y') = 'Y'
            AND ISNULL(p.sms_validate_flag, 0) = 1 AND ISNULL(p.mobile_option, 'Y') = 'Y'
            AND (ISNULL(p.email_validate_flag, 0) = 0 OR ISNULL(p.email_option, 'Y') = 'N') 
            THEN 5
            WHEN (ISNULL(p.address_validate_flag, 0) = 0 OR ISNULL(p.postal_address_option, 'Y') = 'N')
            AND ISNULL(p.sms_validate_flag, 0) = 1 AND ISNULL(p.mobile_option, 'Y') = 'Y'
            AND ISNULL(p.email_validate_flag, 0) = 1 AND ISNULL(p.email_option, 'Y') = 'Y'
            THEN 6
            WHEN ISNULL(p.address_validate_flag, 0) = 1 AND ISNULL(p.postal_address_option, 'Y') = 'Y'
            AND ISNULL(p.sms_validate_flag, 0) = 1 AND ISNULL(p.mobile_option, 'Y') = 'Y'
            AND ISNULL(p.email_validate_flag, 0) = 1 AND ISNULL(p.email_option, 'Y') = 'Y'
            THEN 7
            ELSE 8
        END contactability,
        ci.city_name as living_city,
        s.city_name as prefer_city,
        s.store_code as prefer_store_code,
        pt.single_pink_card_validate_type as single_pink_card_validate_type,
        acc.purchase_days,
        acc.upgrade_counter,
        acc.total_upgrade_counter
    FROM 
        ODS_CRM.account acc
    left join 
        [ODS_CRM].[account_encode_extend] aee
    ON acc.account_id = aee.account_id
    left join 
    (
        select 
            c.bind_card_num, 
            c.place_id, 
            row_number() over(partition by c.bind_card_num order by create_time) rownum 
        from 
            ODS_CRM.account_wechat c 
    ) aw
    on acc.account_number = aw.bind_card_num
    and aw.rownum = 1
    left JOIN 
        ODS_CRM.person p 
    on acc.person_id=p.person_id
    LEFT JOIN 
        ODS_CRM.province pv 
    ON p.province_id = pv.province_id
    LEFT JOIN 
    (
        select * from ODS_CRM.city where city_name <> 'aa'
    ) ci 
    ON p.city_id = ci.city_id
    and p.province_id = ci.province_id
    left join 
    (
        select account_id, min(single_pink_card_validate_type) as single_pink_card_validate_type from ODS_CRM.account_pink_card_tag group by account_id
    )pt 
    on acc.account_id = pt.account_id
    left join
        DW_CRM.Dim_Store s
    on acc.prefer_place_id = s.store_id
    left join
        DW_CRM.Dim_Store s2
    on ISNULL(aw.place_id, acc.register_place_id) = s2.store_id
    left join
        ODS_CRM.deleted_obj_record d
    on acc.account_id = d.obj_id
    and d.from_table_name = 'account'
    where 
        acc.account_number is not null
    and d.obj_id is null
) a
left join
(
    select 
        b.card_no,
        b.user_id,
        c.registration,
        row_number() over(partition by card_no order by last_update desc) rownum 
    from 
        [STG_User].User_Profile b
    left join
        [STG_User].[User] c
    on b.user_id = c.id
    where 
        card_no is not null 
) t
on a.account_number = t.card_no
and t.rownum = 1
left join 
(
    select distinct account_id 
    from ods_crm.DimAccount_Extension 
    where 
        tag_type = 2 
    and segmentation_purachase_tag_id = 5
    and end_date  >= dateadd(day, 1, @dt)
    and begin_date < end_date
) p
on a.account_id = p.account_id
left join
(
    select 
        card_no,
        max(case when rownum = 1 then platform_type else null end) as first_login_channel,
        max(case when platform_rownum = 1  and platform_type = 'app' then first_time else null end) as app_first_login_time
    from 
    (
        select 
            *, 
            row_number() over(partition by card_no order by first_time) rownum , 
            row_number() over(partition by card_no, platform_type order by first_time) platform_rownum  
        from 
            DW_Sensor.DWS_Sensor_User_First_Login
        where
            platform_type is not null
    ) t
    group by card_no
) l on a.account_number = l.card_no
;
UPDATE STATISTICS DWD.DIM_Member_Info;
END

GO
