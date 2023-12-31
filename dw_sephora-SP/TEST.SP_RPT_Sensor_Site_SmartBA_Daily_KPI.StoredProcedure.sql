/****** Object:  StoredProcedure [TEST].[SP_RPT_Sensor_Site_SmartBA_Daily_KPI]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_Sensor_Site_SmartBA_Daily_KPI] @dt [VARCHAR](10) AS
--begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-06-20       litao          Initial Version
-- ========================================================================================

declare @starttime date = DATEADD(DAY,1,EOMONTH (DATEADD(month,-1,@dt))),
        @endtime   date = EOMONTH (@dt)
while @starttime <= @endtime
begin

delete from [test].[RPT_Sensor_Site_SmartBA_Daily_KPI] where date=@starttime;

--delete from [test].[RPT_Sensor_Site_SmartBA_Daily_KPI] where date=@dt;


with smartba_sales_daliy as
(
	SELECT 
		convert(NVARCHAR(10), place_time, 120) AS [date],
		'SmartBA' AS platform_type,
		sum([item_apportion_amount]) AS Sales,
		count(DISTINCT sales_order_number) AS [Order],
		count(distinct member_card) as BUYER --20230619新增
	FROM [DWD].[Fact_Sales_Order]
	WHERE 
	    --convert(NVARCHAR(7), place_time, 120) = left(@dt, 7) 
		--cast(place_time as date)=@dt
		cast(place_time as date)=@starttime
	    and source = 'OMS'
		and channel_code = 'SOA' 
		and is_placed=1
		and is_smartba =1
	GROUP BY 
		convert(NVARCHAR(10), place_time, 120)
)
,
smartba_event_daliy as
(
 select
	DATE,
	'SmartBA' as platform_type,
	sum(pv) as pv,
	count(distinct case when pv >= 1 then user_id end) as uv,
	count(distinct case when VIEW_PDP_flag = 2 then user_id end) as VIEW_PDP,
	count(distinct case when ADD_TO_CART_flag = 2 then user_id end) as ADD_TO_CART,
	count(distinct case when BUY_NOW_UV_flag = 2 then user_id end) as BUY_NOW_UV,
	count(distinct case when ONE_MORE_UV_flag = 2 then user_id end) as ONE_MORE_UV,
	count(distinct case when CHECK_OUT_UV_flag = 2 then user_id end) as CHECK_OUT_UV,
	count(distinct case when PURCHASE_UV_flag = 2 then user_id end) as PURCHASE_UV,
	count(distinct case when Order_Confirmed_UV_flag = 2 then user_id end) as Order_Confirmed_UV
from
	(
	SELECT 
		DATE, 
		user_id,
		sum(CASE WHEN event IN ('$MPViewScreen') AND CHARINDEX('ba=', ss_url_query) > 0 THEN 1 ELSE 0 END) AS PV,
		count(distinct case when CHARINDEX('ba=', ss_url_query) > 0 then 1
							when event IN ('viewCommodityDetail') then 2
							end ) AS VIEW_PDP_flag,
		count(distinct case when CHARINDEX('ba=', ss_url_query) > 0 then 1 
			    			when event = 'addToShoppingcart' Then 2
							end) AS ADD_TO_CART_flag,
		count(distinct case when CHARINDEX('ba=', ss_url_query) > 0 then 1 
			    			when event = 'buyNow' THEN 2
							end) AS BUY_NOW_UV_flag,
		count(distinct case when CHARINDEX('ba=', ss_url_query) > 0 then 1 
			    			when event = '$MPClick' and action_id in ('1000421_011', '1000423_011') then 2
							end) AS ONE_MORE_UV_flag,					
		count(distinct case when CHARINDEX('ba=', ss_url_query) > 0 then 1 
			    			when event = '$MPViewScreen' and page_id = 'MP_1000412' then 2
							end) AS CHECK_OUT_UV_flag,					
		count(distinct case when CHARINDEX('ba=', ss_url_query) > 0 then 1 
			    			when event = 'submitOrder' then 2
							end) AS PURCHASE_UV_flag,
		count(distinct case when CHARINDEX('ba=', ss_url_query) > 0 then 1 
			    			when event = 'submitOrder' and action_id = '1000412_017' then 2
							end) AS Order_Confirmed_UV_flag
	FROM
		[stg_Sensor].[Events]
	where
		platform_type in ('MiniProgram', 'Mini Program') 
		--and date =@dt
		and date=@starttime
		--and left(date,7)=left(@dt, 7)
		--and date between DATEADD(DAY,1,EOMONTH (DATEADD(month,-1,@dt))) and EOMONTH (@dt)
		and user_id is not null
	group by 
		date,
		user_id
    ) tmp
where
	PV >= 1
group by date
)


insert into [test].[RPT_Sensor_Site_SmartBA_Daily_KPI]
select
	date,
	platform_type,
	sum(pv) as pv,
	sum(uv) as uv,
	null as session,
	null as jump_session,
	null as new_uv,
	sum(sales) as sales,
	sum([order]) as [order],
	null as registration_uv,
	null as interaction_uv,
	sum(view_pdp) as view_pdp,
	sum(add_to_cart) as add_to_cart,
	sum(buy_now_uv) as buy_now_uv,
	sum(purchase_uv) as purchase_uv,
	sum(one_more_uv) as one_more_uv,
	sum(check_out_uv) as check_out_uv,
	sum(order_confirmed_uv) as order_confirmed_uv,
	sum(buyer) as buyer,
	null as hp_pv,
	null as hp_uv,
	current_timestamp as insert_timestamp
from
	(
	select
		date,
		platform_type,
		pv,
		uv,
		view_pdp,
		add_to_cart,
		buy_now_uv,
		one_more_uv,
		check_out_uv,
		purchase_uv,
		order_confirmed_uv,
		null as sales,
		null as [order],
		null as buyer
	from
		smartba_event_daliy
    union
	select
		date,
		platform_type,
		null as pv,
		null as uv,
		null as view_pdp,
		null as add_to_cart,
		null as buy_now_uv,
		null as one_more_uv,
		null as check_out_uv,
		null as purchase_uv,
		null as order_confirmed_uv,
		sales,
		[order],
		buyer
	from
		smartba_sales_daliy 
) tab
group by date,
	     platform_type
;

set @starttime = dateadd(day, 1, @starttime);

END
GO
