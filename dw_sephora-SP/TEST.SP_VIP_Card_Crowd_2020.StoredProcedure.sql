/****** Object:  StoredProcedure [TEST].[SP_VIP_Card_Crowd_2020]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_VIP_Card_Crowd_2020] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ---------------------------------------------------------------------------------------- 
-- 2023-02-17       litao              Initial Version
-- ========================================================================================


--2020
--DELETE FROM [test].[vip_card_crowd] WHERE statistics_month=format(@dt,'yyyy-MM');
--INSERT INTO [test].[vip_card_crowd] 
--select 
--    vip_card,
--    date as view_date,
--    format(@dt,'yyyy-MM') as statistics_month
--from 
--   STG_Sensor.Events
--where 
--date between cast(DATEADD(mm,DATEDIFF(mm,0,@dt),0) as date) and EOMONTH(@dt)
--and vip_card is not null 
--and vip_card<>''
--and platform_type in ('mobile','web','wechat','MiniProgram','Mini Program','app','APP','miniprogram')
--group by vip_card,
--         date;

insert into test.app_mnp_smartba_overlap_user_detail
select
    'user' as data_type,
    '202207_202212' as timeline,
    case
	   when ss_url_query like '%ba=%' 
	     then 'SmartBA'
       when platform_type like 'Mini%Program%'
         then 'MINIPROGRAM'
       when lower(platform_type) in ('app')
         then 'APP'
       else upper(platform_type) 
     end as data_content,
    user_id,
    null as super_id,
    current_timestamp as insert_timestamp
from 
    stg_sensor.events
where 
date between '2022-07-01' and '2022-12-31'
and (lower(platform_type) in ('app','miniprogram') or ss_url_query like '%ba=%' or platform_type like 'Mini%Program%')
group by  
    case
	   when ss_url_query like '%ba=%' then 'SmartBA'
       when platform_type like 'Mini%Program%'
         then 'MINIPROGRAM'
       when lower(platform_type) in ('app')
         then 'APP'
    	when platform_type is null and ss_Lib='MiniProgram'
    	  then 'MINIPROGRAM'
       else upper(platform_type) 
     end,
	ss_url_query,
	platform_type,
    user_id;

END
GO
