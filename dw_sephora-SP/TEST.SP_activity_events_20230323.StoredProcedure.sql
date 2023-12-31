/****** Object:  StoredProcedure [TEST].[SP_activity_events_20230323]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_activity_events_20230323] AS
BEGIN
insert into [test].[activity_events_20230323]
select 
   date,
   'ALL' as channel,
   activityid,
   case when page_id in ('MP_1000001','APP_1000001') then N'官网主页'
        when page_id in ('APP_1000122','MP_1000122') and action_id='1000122_003' then N'活动主页'
        when page_id in ('APP_1000124','MP_1000124') then N'单个活动页'
        when page_id in ('APP_1000124','MP_1000124') and action_id='1000124_020' then N'分享'
        when page_id in ('APP_1000124','MP_1000124') and action_id='1000124_003' then N'加购'
        else 'other'
    end as page_name,
   count(distinct user_id) as uv
from 
   stg_sensor.events a    
where date>='2023-02-16'
and (page_id in ('MP_1000001','APP_1000001','APP_1000124', 'MP_1000124','APP_1000122','MP_1000122') 
  or action_id in ('1000124_003','1000122_003','1000124_020'))
group by date, 
   activityid,
   case when page_id in ('MP_1000001','APP_1000001') then N'官网主页'
        when page_id in ('APP_1000122','MP_1000122') and action_id='1000122_003' then N'活动主页'
        when page_id in ('APP_1000124','MP_1000124') then N'单个活动页'
        when page_id in ('APP_1000124','MP_1000124') and action_id='1000124_020' then N'分享'
        when page_id in ('APP_1000124','MP_1000124') and action_id='1000124_003' then N'加购'
        else 'other'
    end
;


END
GO
