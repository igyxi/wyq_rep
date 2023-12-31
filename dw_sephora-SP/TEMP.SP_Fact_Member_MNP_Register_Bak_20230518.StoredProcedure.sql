/****** Object:  StoredProcedure [TEMP].[SP_Fact_Member_MNP_Register_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_Fact_Member_MNP_Register_Bak_20230518] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-03-08       Tali           Initial Version
-- 2022-03-25       Tali           change source from olap to oltp
-- 2022-08-30       Tali           set null for moblie
-- 2022-12-12       Tali           change source from wechatcenter
-- ========================================================================================

truncate table [DWD].[Fact_Member_MNP_Register];
insert into [DWD].[Fact_Member_MNP_Register]
-- select 
--     a.account_miniprogram_id,
--     b.store_code,
--     a.register_time as miniprogram_register_time,
--     a.bind_mobile_time as miniprogram_bind_mobile_time,
--     null as bind_mobile,
--     -- a.mobile as bind_mobile,
--     -- a.account_id,
--     a.bind_card_num as account_number,
--     -- c.store_code,
--     a.channel as bind_channel,
--     a.sub_channel as bind_sub_channel,
--     a.card_type,
--     case 
--         when a.card_type = 0 then 'PINK'
--         when a.card_type = 1 then 'WHITE'
--         when a.card_type = 2 then 'BLACK'
--         when a.card_type = 3 then 'GOLD'
--         else null
--     end as card_type_name,
--     a.unionid,
--     a.openid,
--     a.create_date,
--     a.update_date,
--     a.[status],
--     'CRM' as source,
--     CURRENT_TIMESTAMP as insert_timestamp
-- from 
--     ODS_CRM.account_miniprogram a
-- left join 
--     DW_CRM.Dim_Store b
-- on a.place_id = b.store_id
SELECT
    id,
    [mnp_register_store_code],
    [mnp_register_time],
    [mnp_bind_mobile_time],
    [bind_mobile],
    [member_card],
    [bind_channel],
    [bind_sub_channel],
    [card_type],
    [card_type_name],
    unionid,
    openid,
    create_time,
    update_time,
    [status],
    [source],
    [insert_timestamp]

FROM
(
    SELECT 
        ROW_NUMBER() OVER(partition BY unionid order by update_time desc) as [row], 
        *
    FROM 
    (
        SELECT
            a.id, 
            a.registerstore as [mnp_register_store_code],
            a.registertime as [mnp_register_time],
            b.bindtime as [mnp_bind_mobile_time],
            null as [bind_mobile],
            c.card_no as [member_card],
            ISNULL(a.registerchannel, 'SEPHORA') as [bind_channel],
            -- 'SEPHORA' as [bind_channel],
            -- ISNULL(b.attachedchannel,'') as [bind_channel],
            -- ISNULL(b.subchannel,'') as [bind_sub_channel],
            ISNULL(a.registersubchannel, '') as [bind_sub_channel],
            null as [card_type],
            null as [card_type_name],
            a.unionid,
            a.openid,
            a.create_time,
            a.update_time,
            1 as [status],
            'WechatCenter' as [source],
            CURRENT_TIMESTAMP as insert_timestamp
        FROM 
            STG_WechatCenter.Wechat_Register_Info a
        LEFT JOIN 
            STG_WechatCenter.Wechat_Bind_Mobile_List b
        ON a.openid = b.openid
        and b.isactive = 1
        LEFT JOIN 
            STG_User.User_Profile c
        ON c.user_id = b.userid
        WHERE a.unionid IS NOT NULL
    ) t
) a
where [row] = 1
END
GO
