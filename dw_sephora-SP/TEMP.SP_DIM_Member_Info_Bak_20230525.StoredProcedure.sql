/****** Object:  StoredProcedure [TEMP].[SP_DIM_Member_Info_Bak_20230525]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Member_Info_Bak_20230525] AS
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
    a.card_type_begin_time,
    a.card_type_end_time,
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
    a.birth_date,
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
    a.is_dm_valid,
    a.is_edm_valid,
    a.is_sms_valid,
    a.is_mms_valid,
    a.contactability,
    a.living_city,
    a.prefer_city,
    a.prefer_store_code,
    a.single_pink_card_validate_type,
    a.purchase_days as crm_purchase_days,
    a.is_skincare_premium_tag,
    l.first_login_channel as first_login_channel,
    l.app_first_login_time as app_first_login_time,
    a.upgrade_counter,
    a.total_counter,
    'CRM'  as source,
    CURRENT_TIMESTAMP  as  insert_timestamp
from 
    [DW_CRM].[DWS_Account] a
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
-- left join 
-- (
--     select distinct account_id 
--     from ods_crm.DimAccount_Extension 
--     where 
--         tag_type = 2 
--     and segmentation_purachase_tag_id = 5
--     and end_date  >= dateadd(day, 1, @dt)
--     and begin_date < end_date
-- ) p
-- on a.account_id = p.account_id
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
) l 
on a.account_number = l.card_no
;
END

GO
