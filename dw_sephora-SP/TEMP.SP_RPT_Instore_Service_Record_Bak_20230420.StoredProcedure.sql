/****** Object:  StoredProcedure [TEMP].[SP_RPT_Instore_Service_Record_Bak_20230420]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Instore_Service_Record_Bak_20230420] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun    Initial Version
-- 2022-01-27       tali           delete collate
-- 2022-01-28       tali           delete collate
-- ========================================================================================
truncate table [DW_Marketing].[RPT_Instore_Service_Record];
insert into [DW_Marketing].[RPT_Instore_Service_Record]
select
    masbu.store_code,
    masbu.open_id,
    up.card_no as card_num,
    substring(dcas.card_type_name, 3, 50) as card_type,
    (
        case
            when masbu.is_canceled = 1 then N'已取消'
            when masbu.sign_code IS NOT NULL then N'已签到'
            else N'已预约'
        end
    ) as status,
    masbu.create_time as created_at,
    masbu.[remark] as booking_remark,
    masbu.channel as source,
    masbu.start_time as book_time,
    ds.name as store_name,
    case
        when masbu.sign_code IS NOT NULL
        and masbu.is_canceled <> 1 then masbu.update_time
        else NULL
    end as checkin_time,
    msa.event_name as service_code,
    current_timestamp as insert_timestamp
FROM
    [STG_Marketing].[Activity_Store_Book_User] masbu
    JOIN [STG_Marketing].[Store_Activity] msa ON masbu.activity_id = msa.activity_id
    JOIN [STG_Marketing].[Store] ds ON masbu.store_code = ds.code
    LEFT JOIN [STG_User].[User_Profile] up ON masbu.user_id = up.user_id
    LEFT JOIN [DW_CRM].[DIM_CRM_Account_SCD] dcas ON dcas.[account_number] = up.card_no 
    AND masbu.start_time BETWEEN dcas.start_time
    AND dcas.end_time
union all
SELECT
    [store_code] ,
    [open_id] ,
    [card_num] ,
    [card_type],
    [status],
    cast([create_time] as datetime) as created_at,
    [booking_remark] ,
    [source] ,
    NULL,
    [store_name] ,
    cast([签到时间] as datetime) as checkin_time,
    N'玩美丝芙兰' as service_code,
    current_timestamp as insert_timestamp
FROM
    [STG_Marketing].[Activity_Store_Book_User_History_Keep];
END

GO
