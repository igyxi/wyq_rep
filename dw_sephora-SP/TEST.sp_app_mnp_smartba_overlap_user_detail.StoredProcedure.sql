/****** Object:  StoredProcedure [TEST].[sp_app_mnp_smartba_overlap_user_detail]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[sp_app_mnp_smartba_overlap_user_detail] @dt [date] AS
begin
insert into test.app_mnp_smartba_overlap_user_detail
select
    'user' as data_type,
    '2022 Q1' as timeline,
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
date between '2022-01-01' and '2022-03-31'
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
    user_id
;


end
GO
