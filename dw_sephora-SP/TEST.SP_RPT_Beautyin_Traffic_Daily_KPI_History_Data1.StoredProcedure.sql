/****** Object:  StoredProcedure [TEST].[SP_RPT_Beautyin_Traffic_Daily_KPI_History_Data1]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_Beautyin_Traffic_Daily_KPI_History_Data1] @dt [date] AS 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-24     litao        Initial Version
-- 2023-06-14     litao        add columns beautyin_exposure_pv_on_pdp,beautyin_click_pv_on_pdp,beautyin_click_pdpexpo_ctr_pv,order_ctr_thru_beautyin_click_uv
-- 2023-06-21     tianjinzhao  add total 
-- ========================================================================================

--DECLARE @dt DATE
--set @dt='2023-06-12';
 
 
 
declare @starttime date = DATEADD(DAY,1,EOMONTH (DATEADD(month,-1,@dt))),
        @endtime   date = EOMONTH (@dt)
 
while @starttime <= @endtime

begin

delete from [test].[RPT_Beautyin_Traffic_Daily_KPI_Part1]  where dt=@starttime;

with beautyin_event as
(
select
    date,
	platform_type as platform,
	page_id,
	event,
	time,
	user_id,
	action_id
from
	[DW_Sensor].[DWS_Events_Session_Cutby30m]
where
	date>=@starttime
	and date<=dateadd(dd,1,@starttime)
	and platform_type in ('MINIPROGRAM','MOBILE','APP')
)
,
--24小时内event=submitOrder,单独处理T+2更新
--order_ctr_thru_beautyin_click_uv as 
--(
--select
--	a.platform,
--	count(distinct case when datediff(mi, a.time, b.time) between 0 and 1440 then a.user_id end) as order_ctr_thru_beautyin_click_uv
--from
--	(
--	select
--		user_id,
--		platform,
--		time
--	from
--		beautyin_event
--	where
--		date =@starttime
--		and page_id in ('APP_1000401', 'MP_1000401')
--		and action_id in ('1000401_043', '1000401_044', '1000401_048', '1000401_049')
--	group by
--		user_id,
--		platform,
--		time
--    ) a
--left join
--    (
--    	select
--    		user_id,
--    		platform,
--    		time
--    	from
--    		beautyin_event
--    	where
--    		event = 'submitOrder'
--    	group by
--    		user_id,
--    		platform,
--    		time
--    ) b 
--    on
--	a.user_id = b.user_id
--	and a.platform = b.platform
--group by
--	a.platform
--)
--,
--total 24小时内event=submitOrder,单独处理T+2更新
order_ctr_thru_beautyin_click_uv_total as 
(
select
	'Total' as platform,
	count(distinct case when datediff(mi, a.time, b.time) between 0 and 1440 then a.user_id end) as order_ctr_thru_beautyin_click_uv
from
	(
	select
		user_id,
		platform,
		time
	from
		beautyin_event
	where
		date =@starttime
		and page_id in ('APP_1000401', 'MP_1000401')
		and action_id in ('1000401_043', '1000401_044', '1000401_048', '1000401_049')
	group by
		user_id,
		platform,
		time
    ) a
left join
    (
    	select
    		user_id,
    		platform,
    		time
    	from
    		beautyin_event
    	where
    		event = 'submitOrder'
    	group by
    		user_id,
    		platform,
    		time
    ) b 
    on
	a.user_id = b.user_id
	and a.platform = b.platform
)

insert into [test].[RPT_Beautyin_Traffic_Daily_KPI_Part1] 
--select 
--    date as dt,
--    tab.platform,
--    beautyin_dau,                        --美印现有22个页面的UV去重
--    post_uv,                             --帖子浏览UV
--    pdp_uv,                              --PDP UV
--    post_click_thru_pdp_uv,              --PDP打开帖子详情页UV
--	case when pdp_uv<>0 then round(cast(post_click_thru_pdp_uv as float)/pdp_uv,4) else null end as post_pdp_ctr_uv,       --post_pdp_ctr_uv
--    pdp_pv ,                             --PDP PV
--    post_click_thru_pdp_pv,              --PDP打开帖子详情页PV
--	case when pdp_pv<>0 then round(cast(post_click_thru_pdp_pv as float)/pdp_pv,4) else null end as post_pdp_ctr_pv,    --post_pdp_ctr_pv
--    post_pv,                             --帖子浏览PV
--    product_click_thru_post_pv,          --帖子详情页内商品链接点击PV
--	case when post_pv<>0 then round(cast(product_click_thru_post_pv as float)/post_pv,4) else null end  as product_post_ctr_pv,  --product_post_ctr_pv
--    product_click_thru_post_uv,          --帖子详情页内商品链接点击UV
--	case when post_uv<>0 then round(cast(product_click_thru_post_uv as float)/post_uv,4) else null end  as product_post_ctr_uv,  --product_post_ctr_uv
--	beautyin_exposure_pv_on_pdp, --美印模块在PDP的曝光
--	beautyin_click_pv_on_pdp,  --Click PV
--	case when beautyin_exposure_pv_on_pdp<>0 then round(cast(beautyin_click_pv_on_pdp as float)/beautyin_exposure_pv_on_pdp,4) else null end  as beautyin_click_pdpexpo_ctr_pv,  --beautyin_click_pdpexpo_ctr_pv
--	tab1.order_ctr_thru_beautyin_click_uv,
--	current_timestamp as insert_timestamp
--from 
--(
--    select
--	    date,
--    	platform,
--    	count(distinct case 
--    	                  when platform = 'APP' and page_id in ('APP_1000501', 'APP_1000502','APP_1000503','APP_1000504','APP_1000505','APP_1000506', 'APP_1000507','APP_1000508','APP_1000509','APP_1000510','APP_1000511','APP_1000512','APP_1000513','APP_1000514','APP_1000515','APP_1000516','APP_1000517','APP_1000518','APP_1000519','APP_1000520','APP_1000521','APP_1000827') then user_id  
--                          when platform = 'MINIPROGRAM' and page_id in ('MP_1000522', 'MP_1000503') then user_id 
--    					  when platform = 'MOBILE' and page_id in ('MB_1000503', 'MB_1000504') then user_id 
--        end) as beautyin_dau,
--    	count(distinct case when page_id in ('APP_1000503','MP_1000503','MB_1000503') and event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as post_uv,       
--        count(distinct case when page_id in ('APP_1000401','MP_1000401','MB_1000401') and event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as pdp_uv,
--        count(distinct case 
--		                  when platform='APP' and ((page_id in ('APP_1000401') and action_id='1000401_043') or (page_id in ('APP_1000407') and action_id='1000407_971')) then user_id 
--		                  when platform in ('MINIPROGRAM','MOBILE') and ((page_id in ('MP_1000401','MB_1000401') and action_id='1000401_048') or (page_id in ('MB_1000407','MP_1000407') and action_id='1000407_971')) then user_id 
--		     end) as post_click_thru_pdp_uv, 
--		count(case when page_id in ('APP_1000401','MP_1000401','MB_1000401') and event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as pdp_pv ,
--    	count(case 
--		           when platform='APP' and ((page_id in ('APP_1000401') and action_id='1000401_043') or (page_id in ('APP_1000407') and action_id='1000407_971')) then user_id 
--		           when platform in ('MINIPROGRAM','MOBILE') and ((page_id in ('MP_1000401','MB_1000401') and action_id='1000401_048') or (page_id in ('MB_1000407','MP_1000407') and action_id='1000407_971')) then user_id 
--		     end) as post_click_thru_pdp_pv,
--    	count(case when page_id in ('APP_1000503','MP_1000503','MB_1000503') and event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as post_pv,
--    	count(case when (page_id in ('APP_1000503','MP_1000503','MB_1000503') and action_id='1000503_965') then user_id end) as product_click_thru_post_pv,
--        count(distinct case when (page_id in ('APP_1000503','MP_1000503','MB_1000503') and action_id='1000503_965') then user_id end) as product_click_thru_post_uv,
--		count(case when platform='APP' and page_id='APP_1000401' and action_id='1000401_030' then user_id 
--             when platform='MINIPROGRAM' and page_id='MP_1000401' and action_id='1000401_032' then user_id 
--   		  end 
--        	  ) as beautyin_exposure_pv_on_pdp,
--        count(case when platform='APP' and page_id='APP_1000401' and action_id in ('1000401_043','1000401_044') then user_id 
--                   when platform='MINIPROGRAM' and page_id='MP_1000401' and action_id in ('1000401_048','1000401_049') then user_id 
--        		   end 
--        	  ) as beautyin_click_pv_on_pdp
--    from
--    	beautyin_event
--	where date=@starttime
--    group by platform,date
--) tab 
--left join 
--   order_ctr_thru_beautyin_click_uv tab1
--on tab.platform=tab1.platform
--
--union all 
select 
    date as dt,
    'Total' as platform,
    beautyin_dau,                        --美印现有22个页面的UV去重
    post_uv,                             --帖子浏览UV
    pdp_uv,                              --PDP UV
    post_click_thru_pdp_uv,              --PDP打开帖子详情页UV
	case when pdp_uv<>0 then round(cast(post_click_thru_pdp_uv as float)/pdp_uv,4) else null end as post_pdp_ctr_uv,       --post_pdp_ctr_uv
    pdp_pv ,                             --PDP PV
    post_click_thru_pdp_pv,              --PDP打开帖子详情页PV
	case when pdp_pv<>0 then round(cast(post_click_thru_pdp_pv as float)/pdp_pv,4) else null end as post_pdp_ctr_pv,    --post_pdp_ctr_pv
    post_pv,                             --帖子浏览PV
    product_click_thru_post_pv,          --帖子详情页内商品链接点击PV
	case when post_pv<>0 then round(cast(product_click_thru_post_pv as float)/post_pv,4) else null end  as product_post_ctr_pv,  --product_post_ctr_pv
    product_click_thru_post_uv,          --帖子详情页内商品链接点击UV
	case when post_uv<>0 then round(cast(product_click_thru_post_uv as float)/post_uv,4) else null end  as product_post_ctr_uv,  --product_post_ctr_uv
	beautyin_exposure_pv_on_pdp, --美印模块在PDP的曝光
	beautyin_click_pv_on_pdp,  --Click PV
	case when beautyin_exposure_pv_on_pdp<>0 then round(cast(beautyin_click_pv_on_pdp as float)/beautyin_exposure_pv_on_pdp,4) else null end  as beautyin_click_pdpexpo_ctr_pv,  --beautyin_click_pdpexpo_ctr_pv
	tab1.order_ctr_thru_beautyin_click_uv,
	current_timestamp as insert_timestamp
from 
(
    select
	    date,
		'Total' as platform,
    	count(distinct case 
    	                  when platform = 'APP' and page_id in ('APP_1000501', 'APP_1000502','APP_1000503','APP_1000504','APP_1000505','APP_1000506', 'APP_1000507','APP_1000508','APP_1000509','APP_1000510','APP_1000511','APP_1000512','APP_1000513','APP_1000514','APP_1000515','APP_1000516','APP_1000517','APP_1000518','APP_1000519','APP_1000520','APP_1000521','APP_1000827') then user_id  
                          when platform = 'MINIPROGRAM' and page_id in ('MP_1000522', 'MP_1000503') then user_id 
    					  when platform = 'MOBILE' and page_id in ('MB_1000503', 'MB_1000504') then user_id 
        end) as beautyin_dau,
    	count(distinct case when page_id in ('APP_1000503','MP_1000503','MB_1000503') and event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as post_uv,       
        count(distinct case when page_id in ('APP_1000401','MP_1000401','MB_1000401') and event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as pdp_uv,
        count(distinct case 
		                  when platform='APP' and ((page_id in ('APP_1000401') and action_id='1000401_043') or (page_id in ('APP_1000407') and action_id='1000407_971')) then user_id 
		                  when platform in ('MINIPROGRAM','MOBILE') and ((page_id in ('MP_1000401','MB_1000401') and action_id='1000401_048') or (page_id in ('MB_1000407','MP_1000407') and action_id='1000407_971')) then user_id 
		     end) as post_click_thru_pdp_uv, 
		count(case when page_id in ('APP_1000401','MP_1000401','MB_1000401') and event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as pdp_pv ,
    	count(case 
		           when platform='APP' and ((page_id in ('APP_1000401') and action_id='1000401_043') or (page_id in ('APP_1000407') and action_id='1000407_971')) then user_id 
		           when platform in ('MINIPROGRAM','MOBILE') and ((page_id in ('MP_1000401','MB_1000401') and action_id='1000401_048') or (page_id in ('MB_1000407','MP_1000407') and action_id='1000407_971')) then user_id 
		     end) as post_click_thru_pdp_pv,
    	count(case when page_id in ('APP_1000503','MP_1000503','MB_1000503') and event in ('$AppViewScreen','$MPViewScreen','$pageview') then user_id end) as post_pv,
    	count(case when (page_id in ('APP_1000503','MP_1000503','MB_1000503') and action_id='1000503_965') then user_id end) as product_click_thru_post_pv,
        count(distinct case when (page_id in ('APP_1000503','MP_1000503','MB_1000503') and action_id='1000503_965') then user_id end) as product_click_thru_post_uv,
		count(case when platform='APP' and page_id='APP_1000401' and action_id='1000401_030' then user_id 
             when platform='MINIPROGRAM' and page_id='MP_1000401' and action_id='1000401_032' then user_id 
   		  end 
        	  ) as beautyin_exposure_pv_on_pdp,
        count(case when platform='APP' and page_id='APP_1000401' and action_id in ('1000401_043','1000401_044') then user_id 
                   when platform='MINIPROGRAM' and page_id='MP_1000401' and action_id in ('1000401_048','1000401_049') then user_id 
        		   end 
        	  ) as beautyin_click_pv_on_pdp
    from
    	beautyin_event
	where date=@starttime
    group by date
) tab 
left join 
   order_ctr_thru_beautyin_click_uv_total tab1
on tab.platform=tab1.platform

;

set @starttime = dateadd(day, 1, @starttime);

END
GO
