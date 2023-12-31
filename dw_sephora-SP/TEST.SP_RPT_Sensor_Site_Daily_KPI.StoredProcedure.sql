/****** Object:  StoredProcedure [TEST].[SP_RPT_Sensor_Site_Daily_KPI]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_Sensor_Site_Daily_KPI] @dt [VARCHAR](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-14       wangzhichun        Initial Version
-- 2023-02-24       houshuangqiang     replace DWS_Sales_Order_With_SKU to [DWD].[Fact_Sales_Order]
-- ========================================================================================
delete from [test].[RPT_Sensor_Site_Daily_KPI] where convert(nvarchar(7),date,120)=left(@dt, 7);
with Exp_Session as
(
	SELECT 
		DATE,
		platform_type,
		sum([Session]) AS [Session],
		sum(jump_session) AS jump_session
	FROM 
	(
		SELECT 
			DATE,
			platform_type,
			user_id,
			system_type,
			max([Session]) AS [Session],
			sum(CASE WHEN max_row = min_row THEN 1 ELSE 0 END) AS jump_session
		FROM 
		(
			SELECT 
				DATE,
				--case when platform_type like 'Mini%Program%' then 'MINIPROGRAM'
				--	when platform_type in ('app','APP') then 'APP'
				--	when platform_type in ('web') then 'PC'
				--	else upper(platform_type) end  as platform_type,
                CASE WHEN platform_type='MINIPROGRAM' THEN 'MNP'
                    ELSE platform_type end as platform_type,
				user_id,
				system_type,
				sessionid AS [Session],
				max(row_num) AS max_row,
				min(row_num) AS min_row
		 	FROM [DW_Sensor].[DWS_Events_Session_Cutby30m]
			where left(date,7)=left(@dt, 7) 							--and user_id='-9219434120674523497'
			GROUP BY 
				DATE,
				--case when platform_type like 'Mini%Program%' then 'MINIPROGRAM'
				--	when platform_type in ('app','APP') then 'APP'
				--	when platform_type in ('web') then 'PC'
				--	else upper(platform_type) end,
                CASE WHEN platform_type='MINIPROGRAM' THEN 'MNP'
                    ELSE platform_type end,
				user_id,
				sessionid,
				system_type
		) a
		GROUP BY 
			DATE,
			platform_type,
			user_id,
			system_type
	) b
	GROUP BY DATE,platform_type
),
Exp_sales as 
(
	SELECT 
		convert(NVARCHAR(10), place_time, 120) AS [date],
		CASE WHEN [sub_channel_code] IN ('APP(ANDROID)','APP(IOS)') THEN 'APP'
			when [sub_channel_code] IN ('BENEFITMINIPROGRAM','WECHAT','MINIPROGRAM','ANNYMINIPROGRAM') THEN 'MNP'	
			ELSE upper([sub_channel_code]) END AS platform_type,
		sum([item_apportion_amount]) AS Sales,
		count(DISTINCT sales_order_number) AS [Order],
		count(distinct member_card) as BUYER --20230619新增
	FROM [DWD].[Fact_Sales_Order]
	WHERE convert(NVARCHAR(7), place_time, 120) = left(@dt, 7) 
	    and source = 'OMS'
		AND channel_code = 'SOA' and is_placed=1
		AND [sub_channel_code] IN ('APP(ANDROID)','APP(IOS)','MINIPROGRAM','BENEFITMINIPROGRAM','ANNYMINIPROGRAM','WECHAT','MOBILE','O2O','PC')
	GROUP BY 
		convert(NVARCHAR(10), place_time, 120),
		CASE WHEN [sub_channel_code] IN ('APP(ANDROID)','APP(IOS)') THEN 'APP'
			when [sub_channel_code] IN ('BENEFITMINIPROGRAM','WECHAT','MINIPROGRAM','ANNYMINIPROGRAM') THEN 'MNP'	
			ELSE upper([sub_channel_code]) END
),
Exp_events_others as
(
		--select 1, getdate()
	SELECT 
		DATE,
        CASE WHEN platform_type='MINIPROGRAM' THEN 'MNP'
            ELSE platform_type end as platform_type,
		--case when platform_type like 'Mini%Program%' then 'MINIPROGRAM'
		--	when platform_type in ('app','APP') then 'APP'
		--	when platform_type in ('web') then 'PC'
		--	else upper(platform_type) end  as platform_type,
		--user_id,  
		/*sum(CASE 
				WHEN event IN (
						'$MPViewScreen'
						,'$AppViewScreen'
						,'$pageview'
						)
					THEN 1
				ELSE 0
				END) AS PV
		,count(DISTINCT CASE 
				WHEN event IN (
						'$MPViewScreen'
						,'$AppViewScreen'
						,'$pageview'
						)
					THEN user_id
				END) AS UV
		,count(DISTINCT CASE 
				WHEN ss_is_first_day = 1
					THEN user_id
				END) AS [New UV]
				*/
		sum(CASE WHEN event IN ('$MPViewScreen','$AppViewScreen') AND platform_type IN ('Mini Program','MiniProgram','app','APP') THEN 1
				WHEN event IN ('$pageview') AND platform_type IN ('mobile','web','PC') THEN 1
				ELSE 0 END) AS PV,
		count(DISTINCT CASE WHEN event IN ('$MPViewScreen','$AppViewScreen') 
								AND platform_type IN ('Mini Program','MiniProgram','app','APP') THEN user_id
							WHEN event IN ('$pageview') AND platform_type IN ('mobile','web','PC') THEN user_id
							END ) AS UV,
		count(DISTINCT CASE WHEN event IN ('$MPViewScreen','$AppViewScreen') 
								AND platform_type IN ('Mini Program','MiniProgram','app','APP') AND ss_is_first_day = 1 THEN user_id
							WHEN event IN ('$pageview') AND platform_type IN ('mobile','web','PC') AND ss_is_first_day = 1 THEN user_id
							END) AS [New UV],
		count(DISTINCT CASE WHEN event = 'signUpResult' AND if_success = 1 THEN user_id END) AS [Registration UV],
		count(DISTINCT CASE WHEN event IN ('clickBanner_App_Mob','clickBanner_web','clickBanner_MP') THEN user_id
							END) AS [Interaction UV],
		count(DISTINCT CASE WHEN ss_app_version='7.20.0' and event='$AppViewScreen' 
								and ss_SCREEN_NAME in ('SEPProductMainViewController','SEPOldProductMainViewController') 
								and system_type='iOS' THEN user_id
			    			WHEN event = 'viewCommodityDetail' THEN user_id
							END) AS [View PDP UV],
		count(DISTINCT CASE WHEN event = 'addToShoppingcart' THEN user_id END) AS [Add to Cart UV],
		count(DISTINCT CASE WHEN event = 'buyNow' THEN user_id END) AS [Buy Now UV],
		count(DISTINCT CASE WHEN event = 'submitOrder' THEN user_id END) AS [Purchase UV],
		--以下20230619新增字段
	    count(distinct case when platform_type in ('APP') and action_id in ('1000421_011','1000423_011') and event='$AppClick' then user_id 
	                        when platform_type in ('MINIPROGRAM') and action_id in ('1000421_011','1000423_011') and event='$MPClick' then user_id 
               end) as ONE_MORE_UV,
	    count(distinct case when platform_type in ('APP') and page_id in ('APP_1000412') and event='$AppViewScreen' then user_id 
	                        when platform_type in ('MINIPROGRAM') and page_id in ('MP_1000412') and event='$MPViewScreen' then user_id
	          end) as CHECK_OUT_UV,
	    count(distinct case when platform_type in ('APP','MINIPROGRAM') and action_id in ('1000412_017') and event='submitOrder' then user_id end) as Order_Confirmed_UV,
	    count(case when platform_type in ('APP') and page_id in ('APP_1000001') and event='$AppViewScreen' then user_id 
	               when platform_type in ('MINIPROGRAM') and page_id in ('MP_1000001') and event='$MPViewScreen' then user_id
	          end) as HP_PV,
	    count(distinct case when platform_type in ('APP') and page_id in ('APP_1000001') and event='$AppViewScreen' then user_id 
	                        when platform_type in ('MINIPROGRAM') and page_id in ('MP_1000001') and event='$MPViewScreen' then user_id
	          end) as HP_UV
	FROM [DW_Sensor].[DWS_Events_Session_Cutby30m] 
	WHERE left(date,7)=left(@dt, 7)-- and user_id='-9219434120674523497'
	GROUP BY 
		DATE,
        CASE WHEN platform_type='MINIPROGRAM' THEN 'MNP'
            ELSE platform_type end
		--case when platform_type like 'Mini%Program%' then 'MINIPROGRAM'
		--	when platform_type in ('app','APP') then 'APP'
		--	when platform_type in ('web') then 'PC'
		--	else upper(platform_type) end  --,user_id
		-- order by user_id
	--select 2, getdate()
)

insert into [test].[RPT_Sensor_Site_Daily_KPI]
SELECT 
	isnull(Exp_Session.[date],Exp_sales.[date]) as [DATE],
	isnull(Exp_Session.platform_type,Exp_sales.platform_type)  as PLATFORM_TYPE,
	sum(Exp_events_others.[PV]) AS PV,
	sum(Exp_events_others.[UV]) AS UV,
	sum(Exp_Session.[Session]) AS [session],
	sum(Exp_Session.[jump_session]) AS [jump_session],
	sum(Exp_events_others.[New UV]) AS [new_UV],
	sum(Exp_sales.Sales) as sales,
	sum(Exp_sales.[Order]) as [order],
	sum(Exp_events_others.[Registration UV]) AS [registration_UV],
	sum(Exp_events_others.[Interaction UV]) AS [interaction_UV],
	sum(Exp_events_others.[View PDP UV]) AS [view_PDP_UV],
	sum(Exp_events_others.[Add to Cart UV]) AS [add_to_cart_UV],
	sum(Exp_events_others.[Buy Now UV]) AS [buy_now_UV],
	sum(Exp_events_others.[Purchase UV]) AS [purchase_UV],
	sum(Exp_events_others.[ONE_MORE_UV]) AS [ONE_MORE_UV],
	sum(Exp_events_others.[CHECK_OUT_UV]) AS [CHECK_OUT_UV],
	sum(Exp_events_others.[Order_Confirmed_UV]) AS [Order_Confirmed_UV],
	sum(Exp_sales.BUYER) as BUYER,
	sum(Exp_events_others.[HP_PV]) AS [HP_PV],
	sum(Exp_events_others.[HP_UV]) AS [HP_UV],
	current_timestamp as insert_timestamp
FROM 
	Exp_Session
LEFT JOIN 
	Exp_events_others
ON Exp_Session.DATE = Exp_events_others.DATE
AND isnull(Exp_Session.platform_type, '') = isnull(Exp_events_others.platform_type, '')
Right JOIN 
	Exp_sales
ON Exp_Session.DATE = Exp_sales.DATE
AND isnull(Exp_Session.platform_type, '') COLLATE SQL_Latin1_General_CP1_CI_AS= isnull(Exp_sales.platform_type, '')
GROUP BY 
	isnull(Exp_Session.[date],Exp_sales.[date]),
	isnull(Exp_Session.platform_type,Exp_sales.platform_type) 
	--select 3, getdate()
END
GO
