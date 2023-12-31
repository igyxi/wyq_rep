/****** Object:  StoredProcedure [TEMP].[SP_DWS_Sensor_User_First_Login_BK_20220712]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Sensor_User_First_Login_BK_20220712] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       eddie.zhang    Initial Version
-- 2022-05-11       wangzhichun    updates
-- ========================================================================================
delete from DW_Sensor.DWS_Sensor_User_First_Login where dt = @dt;
insert into DW_Sensor.DWS_Sensor_User_First_Login
SELECT
    a.user_id as user_id,
    a.card_no,
    a.platform_type,
    a.first_date,
    a.first_time,
    current_timestamp as insert_timestamp,
    @dt as dt
FROM
(
    select
        user_id,
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
        user_id,
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
        [DW_Sensor].[DWS_Sensor_User_First_Login] b
on a.user_id = b.ss_user_id
and a.platform_type = b.platform_type
where b.ss_user_id is null
;
end
GO
