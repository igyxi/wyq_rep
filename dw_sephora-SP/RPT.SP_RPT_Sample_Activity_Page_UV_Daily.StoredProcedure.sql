/****** Object:  StoredProcedure [RPT].[SP_RPT_Sample_Activity_Page_UV_Daily]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Sample_Activity_Page_UV_Daily] @dt [date] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-28       litao        Initial Version
-- 2023-04-23       litao        代码中判断channel的条件原为$utm_source，现修改为$latest_utm_source
-- ========================================================================================

delete from [RPT].[RPT_Sample_Activity_Page_UV_Daily] where  statistics_date=@dt;
--ALL
insert into [RPT].[RPT_Sample_Activity_Page_UV_Daily]
select 
   date as statistics_date,
   'ALL' as channel,
   case when page_id in ('MP_1000001','APP_1000001') then '99999' else activityid end as activityid,
   count(distinct case when page_id in ('MP_1000001','APP_1000001') then user_id end) as dragon_uv, --官网主页
   count(distinct case when page_id in ('APP_1000122','MP_1000122') and action_id='1000122_003' then user_id end) as activity_uv, --活动主页
   count(distinct case when page_id in ('APP_1000124','MP_1000124')  then user_id end) as single_activity_uv, --单个活动页
   count(distinct case when page_id in ('APP_1000124','MP_1000124') and action_id='1000124_020' then user_id end) as share_uv, --分享
   count(distinct case when page_id in ('APP_1000124','MP_1000124') and action_id='1000124_003' then user_id end) as cart_uv, --加购
   null as sampling_uv,
   CURRENT_TIMESTAMP as insert_timestamp 
from 
   stg_sensor.events a    
where 
--date>=cast('2023-02-16' as date)
date=@dt
and (page_id in ('MP_1000001','APP_1000001','APP_1000124', 'MP_1000124','APP_1000122','MP_1000122') 
    or action_id in ('1000124_003','1000122_003','1000124_020'))
group by date, 
         case when page_id in ('MP_1000001','APP_1000001') then '99999' else activityid end
;


--by channel
insert into [RPT].[RPT_Sample_Activity_Page_UV_Daily]
select 
   date as statistics_date,
   case when lower(ss_latest_utm_source)='smartba' then 'Smart BA'
        when lower(ss_latest_utm_source)='social community' then 'Social community'
        when lower(ss_latest_utm_source)='tencentsampling' then N'企鹅试用'
   end as channel,
   null as activityid,
   null as dragon_uv, --官网主页
   count(distinct case when page_id in ('APP_1000122','MP_1000122') then user_id end) as activity_uv, --活动主页
   null as single_activity_uv,
   null as share_uv, --分享
   count(distinct case when lower(ss_latest_utm_source) in ('smartba','social community','tencentsampling') and page_id in ('APP_1000124','MP_1000124') and action_id='1000124_003' then user_id
         end) as cart_uv, --加购
   count(distinct case when page_id in ('APP_1000412','MP_1000412') and action_id='1000412_017' then user_id end) as sampling_uv, --sampling
   CURRENT_TIMESTAMP as insert_timestamp
from 
   stg_sensor.events a    
where 
--date>=cast('2023-02-16' as date)
date=@dt
and lower(ss_latest_utm_source) in ('smartba','social community','tencentsampling')
and (page_id in ('APP_1000124', 'MP_1000124','APP_1000122','MP_1000122','MP_1000412','APP_1000412','MP_1000413','APP_1000413') 
  or action_id in ('1000124_003','1000412_017','1000413_002'))
group by date, 
   case when lower(ss_latest_utm_source)='smartba' then 'Smart BA'
        when lower(ss_latest_utm_source)='social community' then 'Social community'
        when lower(ss_latest_utm_source)='tencentsampling' then N'企鹅试用'
   end
;

END
 
GO
