/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Product_Detail_Page_View_20220301_20220321]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Product_Detail_Page_View_20220301_20220321] @dt [varchar](10) AS
BEGIN
delete from DW_Sensor.DWS_Product_Detail_Page_View where dt = @dt;
insert into DW_Sensor.DWS_Product_Detail_Page_View
select 
    user_id,
    vip_card,
    [date],
    [time],
    case 
        when platform_type in ('app','APP') then 'APP'
        when platform_type = 'mobile' then 'Mobile'
        when platform_type = 'web' then 'Web'
        when platform_type = 'wechat' then 'Mobile'
        when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
    end as platform_type,
    system_type,
    previous_page_type_new,
    referrer,
    try_cast(trim(op_code) as int) as op_code,
    try_cast(trim(commodity_sku) as int) as sku_id,
    CURRENT_TIMESTAMP as insert_timestamp,
    dt
from 
    STG_Sensor.Events with (nolock)
where 
    dt = @dt
    and event='viewCommodityDetail'
    and try_cast(trim(op_code) as int) <> '0'
    and platform_type in('mobile','web','wechat','MiniProgram','Mini Program','app','APP')
    and ss_app_version <> '7.20.0'
union all     
select
    user_id,
    vip_card,
    [date],
    [time],
    case 
        when platform_type in ('app','APP') then 'APP'
        when platform_type = 'mobile' then 'Mobile'
        when platform_type = 'web' then 'Web'
        when platform_type = 'wechat' then 'Mobile'
        when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
    end as platform_type,
    system_type,
    previous_page_type_new,
    referrer,
    try_cast(trim(op_code) as int) as op_code,
    try_cast(trim(commodity_sku) as int) as sku_id,
    CURRENT_TIMESTAMP as insert_timestamp,
    dt
from 
    STG_Sensor.Events with (nolock)
where 
    dt= @dt
and event = '$AppViewScreen'
and try_cast(op_code as int) <> '0'
and ss_screen_name in ('SEPProductMainViewController','SEPOldProductMainViewController')
and platform_type in('app','APP')
and ss_app_version = '7.20.0'
AND upper(system_type) = 'IOS'

END
GO
