/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Platform_PV_UV_Daily]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Platform_PV_UV_Daily] @dt [varchar](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-27      wangzhichun    Initial Version
-- ========================================================================================
delete from DW_Sensor.RPT_Platform_PV_UV_Daily where date=@dt;
insert into DW_Sensor.RPT_Platform_PV_UV_Daily
select
    @dt as date,
    case 
        when platform_type in ('app','APP') then 'APP'
        when platform_type = 'mobile' then 'Mobile'
        when platform_type = 'web' then 'Web'
        when platform_type = 'wechat' then 'Mobile'
        when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
    end as platform_type,
    count(1) as pv,
    count(distinct user_id) as uv,
    current_timestamp as insert_timestamp
from
    STG_Sensor.Events 
where
    date= @dt
group by 
    case 
        when platform_type in ('app','APP') then 'APP'
        when platform_type = 'mobile' then 'Mobile'
        when platform_type = 'web' then 'Web'
        when platform_type = 'wechat' then 'Mobile'
        when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
    end;
END 
GO
