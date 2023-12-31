/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Sensor_User_First_Login]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Sensor_User_First_Login] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       eddie.zhang    Initial Version
-- 2022-05-11       wangzhichun    updates
-- 2022-07-12       wangzhichun    updates
-- ========================================================================================
delete from DW_Sensor.DWS_Sensor_User_First_Login where dt = @dt;
insert into DW_Sensor.DWS_Sensor_User_First_Login
-- 初始化 
-- TRUNCATE table DW_Sensor.DWS_Sensor_User_First_Login;
-- insert into DW_Sensor.DWS_Sensor_User_First_Login
-- select
--     ss_user_id,
--     card_no,
--     platform_type,
--     first_date,
--     first_time,
--     insert_timestamp,
--     dt
-- from 
-- (
--    select 
--        *,
--        ROW_NUMBER()OVER(PARTITION BY card_no,platform_type ORDER BY first_date,ss_user_id desc) rownum
--    from
--       [DW_Sensor].[DWS_Sensor_User_First_Login_New_BK_20220711]
-- ) a 
-- where rownum=1

SELECT
    a.user_id as ss_user_id,
    a.card_no,
    a.platform_type,
    a.first_date,
    a.first_time,
    current_timestamp as insert_timestamp,
    @dt as dt
FROM
(
    select
        max(user_id) as user_id,
        vip_card as card_no,
        case 
            when platform_type in ('app','APP') then 'APP'
            when platform_type = 'mobile' then 'Mobile'
            when platform_type = 'web' then 'Web'
            when platform_type = 'wechat' then 'Mobile'
            when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
        end as platform_type,
        min(date) as first_date,
        min(time) as first_time
    from
        STG_Sensor.Events with (nolock)
    where
    --  lower(platform_type) in('miniprogram','app') and 
        vip_card is not null
    and
        dt=@dt
    group by 
        vip_card,
        case 
            when platform_type in ('app','APP') then 'APP'
            when platform_type = 'mobile' then 'Mobile'
            when platform_type = 'web' then 'Web'
            when platform_type = 'wechat' then 'Mobile'
            when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
        end 
)a
left join
(
    select 
        card_no,
        platform_type
    from
        [DW_Sensor].[DWS_Sensor_User_First_Login] 
    where dt <= dateadd(day,-1,@dt)
) b
on a.card_no collate Chinese_PRC_CS_AI_WS = b.card_no
and (a.platform_type = b.platform_type or (a.platform_type is null and b.platform_type is null)) 
where b.card_no is null
;
end
GO
