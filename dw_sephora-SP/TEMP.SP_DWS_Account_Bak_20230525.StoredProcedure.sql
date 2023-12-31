/****** Object:  StoredProcedure [TEMP].[SP_DWS_Account_Bak_20230525]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Account_Bak_20230525] @dt [nvarchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-09-16       Tali           Initial Version
-- ========================================================================================
TRUNCATE TABLE [DW_CRM].[DWS_Account];
INSERT INTO [DW_CRM].[DWS_Account]
select
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
    acc.segmentation_value_id as segmentation,
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
    case when p.civilization_title_id = 2 then 1 else 0 end gender,
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
    case when tag.account_id is not null then 1 else 0 end as is_skincare_premium_tag,
    acc.upgrade_counter,
    acc.total_upgrade_counter,
    CURRENT_TIMESTAMP as insert_timestamp
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
left join
    DW_CRM.Dim_Store s2
on ISNULL(aw.place_id, acc.register_place_id) = s2.store_id
left JOIN 
    ODS_CRM.person p 
on acc.person_id=p.person_id
LEFT JOIN 
    ODS_CRM.province pv 
ON p.province_id = pv.province_id
LEFT JOIN 
    ODS_CRM.city ci 
ON p.city_id = ci.city_id
and p.province_id = ci.province_id
and ci.city_name <> 'aa'
left join 
(
    select account_id, min(single_pink_card_validate_type) as single_pink_card_validate_type from ODS_CRM.account_pink_card_tag group by account_id
)pt 
on acc.account_id = pt.account_id
left join
    DW_CRM.Dim_Store s
on acc.prefer_place_id = s.store_id
left join
    ODS_CRM.deleted_obj_record d
on acc.account_id = d.obj_id
and d.from_table_name = 'account'
left join 
(
    select 
        distinct account_id 
    from 
        ODS_CRM.DimAccount_Extension 
    where 
        tag_type = 2 
    and segmentation_purachase_tag_id = 5
    and end_date >= dateadd(day, 1, @dt)
    and begin_date < end_date
) tag
on acc.account_id = tag.account_id
where 
    acc.account_number is not null
and d.obj_id is null
;
END

-- GO
GO
