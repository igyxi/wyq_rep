/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_MNP_Scene_Traffic]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_MNP_Scene_Traffic] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       eddie.zhang    Initial Version
-- 2021-01-08       tali           add cast nvarchar
-- 2022-01-27       mac            delete 'COLLATE Chinese_PRC_CS_AI_WS'
-- 2022-02-08       tali           change logic
-- 2022-03-01       wangzhichun    change logic
-- ========================================================================================
delete from DW_Sensor.RPT_MNP_Scene_Traffic where dt = @dt;
INSERT INTO DW_Sensor.RPT_MNP_Scene_Traffic
select 
    statistic_date,
    level_1_name,
    level_2_name,
    ss_latest_scene,
    pv,
    uv,
    CURRENT_TIMESTAMP as insert_timestamp,
    @dt
from 
(
    select 
        [date] as statistic_date,
        'SmartBA' as level_1_name,
        case when BD_value is not null then 'Store QR Code' 
            when store is not null or store_code is not null then 'Smart BA&WeChat Group'
        end as level_2_name,
        case when BD_value like 'MNP%' then N'扫描门店二维码进入公众号的绑定参数'
             when BD_value like 'Wechatwork%' then N'BA个人对话产地绑定'
             when BD_value = 'CRMcampaign' then N'CRMcampaign'
             when ISNULL(store, store_code) = '0000' then N'社群（景栗）'
             when ISNULL(store, store_code) = '1111' then N'社群（测试）'
             when ISNULL(store, store_code) = '2222' then N'社群（大宇宙）'
             when ISNULL(store, store_code) is not null then N'线下门店'
             else COALESCE(BD_value, store, store_code)
        end  as ss_latest_scene,
        count(1) as pv,
        count(distinct user_id) as uv
    from
    (
        SELECT 
            user_id,
            [date],
            [time],
            ss_latest_scene,
            dbo.parse_url_param_new(upper(cast(ss_url_query as nvarchar)),'BD') as BD_value,
            dbo.parse_url_param_new(upper(cast(ss_url_query as nvarchar)),'STORE') as store,
            dbo.parse_url_param_new(upper(cast(ss_url_query as nvarchar)),'STORECODE') as store_code,
            vip_card,
            vip_card_type
        FROM 
            STG_Sensor.Events with (nolock)
        WHERE 
            dt = @dt
        AND event = '$MPViewScreen'
    ) a
    where 
        BD_value is not null or store is not null or store_code is not null
    group by 
        [date],
        case when BD_value is not null then 'Store QR Code' 
            when store is not null or store_code is not null then 'Smart BA&WeChat Group'
        end,
        case when BD_value like 'MNP%' then N'扫描门店二维码进入公众号的绑定参数'
             when BD_value like 'Wechatwork%' then N'BA个人对话产地绑定'
             when BD_value = 'CRMcampaign' then N'CRMcampaign'
             when ISNULL(store, store_code) = '0000' then N'社群（景栗）'
             when ISNULL(store, store_code) = '1111' then N'社群（测试）'
             when ISNULL(store, store_code) = '2222' then N'社群（大宇宙）'
             when ISNULL(store, store_code) is not null then N'线下门店'
             else COALESCE(BD_value, store, store_code)
        end 

    union all

    select 
        [date] as statistic_date,
        case 
            when b.ss_latest_utm_source IN ('gdtcpc_uniclick','mnpcpc','gdtcpc','mnpcpm','paid','mplivestream_paid','mnplivestream_paid','wechatgroup_paid') and b.ss_latest_utm_medium = 'seco' then 'Paid'
            when b.ss_latest_utm_medium in ('cooperation','coop','coo','qr','qrcode') then 'Brand Cooperation'
            when b.ss_latest_utm_medium in ('display','offline','paidsocial','paidcontent') then 'Brand Marketing'
            else a.level_1_name 
        end as level_1_name,
        case 
            when b.ss_latest_utm_source IN ('gdtcpc_uniclick','mnpcpc','gdtcpc','mnpcpm','paid','mplivestream_paid','mnplivestream_paid','wechatgroup_paid') and b.ss_latest_utm_medium = 'seco' then N'Ads-朋友圈'
            when b.ss_latest_utm_medium in ('cooperation','coop','coo','qr','qrcode') then N'Ads-朋友圈'
            when b.ss_latest_utm_medium in ('display','offline','paidsocial','paidcontent') then N'Ads-朋友圈'
            else a.level_2_name 
        end as level_2_name,
        case 
            when b.ss_latest_utm_source IN ('gdtcpc_uniclick','mnpcpc','gdtcpc','mnpcpm','paid','mplivestream_paid','mnplivestream_paid','wechatgroup_paid') and b.ss_latest_utm_medium = 'seco' then null
            when b.ss_latest_utm_medium in ('cooperation','coop','coo','qr','qrcode') then null
            when b.ss_latest_utm_medium in ('display','offline','paidsocial','paidcontent') then null
            when c.scene_name is not null then trim(c.scene_name) collate Chinese_PRC_CS_AI_WS
            else b.ss_latest_scene
        end as ss_latest_scene,
        -- isnull(trim(c.scene_name), b.ss_latest_scene) as ss_latest_scene,
        count(1) as pv,
        count(distinct user_id) as uv
    from
    (
        SELECT 
            user_id,
            [date],
            [time],
            case when ss_latest_scene like 'wx-%' and len(ss_latest_scene)-3>0 then SUBSTRING(ss_latest_scene, 4, len(ss_latest_scene)-3) 
                else ss_latest_scene 
            end as ss_latest_scene,
            dbo.parse_url_param_new(upper(cast(ss_url_query as nvarchar)),'BD') as BD_value,
            dbo.parse_url_param_new(upper(cast(ss_url_query as nvarchar)),'STORE') as store,
            dbo.parse_url_param_new(upper(cast(ss_url_query as nvarchar)),'STORECODE') as store_code,
            ss_latest_utm_source,
            ss_latest_utm_medium,
            vip_card,
            vip_card_type
        FROM 
            STG_Sensor.Events with (nolock)
        WHERE 
            dt = @dt
        AND event = '$MPViewScreen'
    ) b
    left join
        DW_Sensor.DIM_MNP_Scene_List c
    on b.ss_latest_scene = cast(c.scene_id as varchar)
    left join
        DW_Sensor.DIM_MNP_Scene_List a
    on isnull(trim(c.scene_name), b.ss_latest_scene) = a.scene_name
    where 
        b.store is null and b.store_code is null and b.BD_value is null
    group by 
        [date],
        case 
            when b.ss_latest_utm_source IN ('gdtcpc_uniclick','mnpcpc','gdtcpc','mnpcpm','paid','mplivestream_paid','mnplivestream_paid','wechatgroup_paid') and b.ss_latest_utm_medium = 'seco' then 'Paid'
            when b.ss_latest_utm_medium in ('cooperation','coop','coo','qr','qrcode') then 'Brand Cooperation'
            when b.ss_latest_utm_medium in ('display','offline','paidsocial','paidcontent') then 'Brand Marketing'
            else a.level_1_name 
        end,
        case 
            when b.ss_latest_utm_source IN ('gdtcpc_uniclick','mnpcpc','gdtcpc','mnpcpm','paid','mplivestream_paid','mnplivestream_paid','wechatgroup_paid') and b.ss_latest_utm_medium = 'seco' then N'Ads-朋友圈'
            when b.ss_latest_utm_medium in ('cooperation','coop','coo','qr','qrcode') then N'Ads-朋友圈'
            when b.ss_latest_utm_medium in ('display','offline','paidsocial','paidcontent') then N'Ads-朋友圈'
            else a.level_2_name 
        end,
        case 
            when b.ss_latest_utm_source IN ('gdtcpc_uniclick','mnpcpc','gdtcpc','mnpcpm','paid','mplivestream_paid','mnplivestream_paid','wechatgroup_paid') and b.ss_latest_utm_medium = 'seco' then null
            when b.ss_latest_utm_medium in ('cooperation','coop','coo','qr','qrcode') then null
            when b.ss_latest_utm_medium in ('display','offline','paidsocial','paidcontent') then null
            when c.scene_name is not null then trim(c.scene_name) collate Chinese_PRC_CS_AI_WS
            else b.ss_latest_scene
        end
) t
END
GO
