/****** Object:  StoredProcedure [TEST].[smartba_v6]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[smartba_v6] @end_date [datetime],@PS_startdate [datetime],@PS_enddate [datetime] AS
BEGIN
    --@end_date：R12统计截止时间，一般用任务触达日期
    --@start_date：R12统计起始时间，@end_date-365天
    --@PS_startdate：大促开始时间
    --@PS_enddate：大促结束时间后一天
    ----跑存储过程之前需要操作一下几步：
    ----第一步需要更新Step 的日历表
    ----第二步需要跑存储过程test.sp_Fact_OnlineVisit_v2
    ----第三步需要跑存储过程[TEST].[sp_smartba_Nonsmartba_uv] 
    ----第四步需要更新Step12,R12的月份列表
    DECLARE @start_date date
    set @start_date = (SELECT DATEADD(DAY, -365, @end_date))
    -----Step 1 : 维护本次大促以及过去12个月的大促日历表
    IF OBJECT_ID('tempdb..#ps_period') IS NOT NULL 
    DROP TABLE  #ps_period

    SELECT 'FY22M09' as [PS_Period], cast('2022-09-01 20:00:00.000' as datetime) as [start_time], cast('2022-09-09 23:59:59.000' as datetime) as [end_time]
        INTO #ps_period
	UNION ALL
        SELECT 'FY21M10' as [PS_Period], cast('2021-10-16 20:00:00.000' as datetime) as [start_time], cast('2021-10-25 23:59:59.000' as datetime) as [end_time]
    UNION ALL
        SELECT 'FY22M01' as [PS_Period], cast('2022-01-13 20:00:00.000' as datetime) as [start_time], cast('2022-01-17 23:59:59.000' as datetime) as [end_time]
    UNION ALL
        SELECT 'FY22M03' as [PS_Period], cast('2022-03-03 20:00:00.000' as datetime) as [start_time], cast('2022-03-08 23:59:59.000' as datetime) as [end_time]
    UNION ALL
        SELECT 'FY22M04' as [PS_Period], cast('2022-04-28 20:00:00.000' as datetime) as [start_time], cast('2022-05-02 23:59:59.000' as datetime) as [end_time]
    UNION ALL
        SELECT 'FY22M06' as [PS_Period], cast('2022-06-08 20:00:00.000' as datetime) as [start_time], cast('2022-06-13 23:59:59.000' as datetime) as [end_time]
    UNION ALL
        SELECT 'FY22M10' as [PS_Period], cast('2022-10-19 20:00:00.000' as datetime) as [start_time], cast('2022-10-25 23:59:59.000' as datetime) as [end_time]
    UNION ALL
        SELECT 'FY22M11' as [PS_Period], cast('2022-11-09 20:00:00.000' as datetime) as [start_time], cast('2022-11-13 23:59:59.000' as datetime) as [end_time]
	UNION ALL
        SELECT 'FY22M12' as [PS_Period], cast('2022-12-09 20:00:00.000' as datetime) as [start_time], cast('2022-12-13 23:59:59.000' as datetime) as [end_time]
	UNION ALL
        SELECT 'FY23M01' as [PS_Period], cast('2023-01-05 20:00:00.000' as datetime) as [start_time], cast('2023-01-10 23:59:59.000' as datetime) as [end_time]
	UNION ALL
        SELECT 'FY23M03' as [PS_Period], cast('2023-03-01 20:00:00.000' as datetime) as [start_time], cast('2023-03-06 23:59:59.000' as datetime) as [end_time]
	UNION ALL
        SELECT 'FY23M05' as [PS_Period], cast('2023-05-10 20:00:00.000' as datetime) as [start_time], cast('2023-05-15 23:59:59.000' as datetime) as [end_time]
	UNION ALL
        SELECT 'FY23M06' as [PS_Period], cast('2023-06-14 20:00:00.000' as datetime) as [start_time], cast('2023-06-18 23:59:59.000' as datetime) as [end_time]

	--UNION ALL  情人节
       -- SELECT 'FY23M02' as [PS_Period], cast('2023-02-03 00:00:00.000' as datetime) as [start_time], cast('2023-02-14 23:59:59.000' as datetime) as [end_time]

    --Step2
    --获取有BA绑定关系的会员卡号，以及最早最晚绑定时间，截止到@end_date之前
    --包含会员和非会员,8月31号之前数量为：4948656
    IF OBJECT_ID('tempdb..#smartba_user_base') IS NOT NULL 
    DROP TABLE #smartba_user_base

    SELECT
        a.smartba_member_unionid,
        a.first_bind_time,
        a.last_bind_time,
        isnull(b.member_card,a.smartba_member_unionid) member_card,
        isnull(c.card_type,d.card_type) as card_type
    INTO #smartba_user_base
    FROM (
        SELECT unionid as [smartba_member_unionid],
            min(bind_time) as [first_bind_time],
            max(bind_time) as [last_bind_time]
        FROM (
            SELECT *,
                row_number() over (partition by unionid, ba_staff_no order by bind_time desc) as ro
            FROM [DWD].[Fact_Member_BA_Bind]
            WHERE bind_time<=@end_date
        ) temp1
        WHERE ro=1 AND status=0
        GROUP BY unionid
    ) a
    LEFT JOIN (
        SELECT DISTINCT [unionid], member_card
        FROM [DWD].[Fact_Member_MNP_Register]
        WHERE [status] = 1
            AND unionid is not null
    ) b ON a.smartba_member_unionid = b.unionid
    left join (
        select member_card, card_type
        from (
            select member_card, card_type, row_number() over (partition by member_card order by start_time desc) as ro
            from [DWD].[DIM_Member_Card_Grade_SCD]
            where start_time<@end_date
                and end_time>=@end_date
        ) temp_member
        where ro=1
    ) c on isnull(b.member_card,'')=c.member_card
	----SCD 表缺失卡别变化的用当前卡别填充
	left join 
	(
	select  member_card,card_type from dwd.dim_member_info
	)d on  isnull(b.member_card,'')=d.member_card

    --Step3
    --有绑定关系会员的过去12个月购买历史，以及本次大促smartba，非smartBa,线下购买情况
    --包含会员和非会员,非会员没有购买记录
    IF OBJECT_ID('tempdb..#smartba_user_purchase') IS NOT NULL 
    DROP TABLE  #smartba_user_purchase

    SELECT
        a.smartba_member_unionid,
        a.member_card,
        a.card_type,
        a.first_bind_time,
        a.last_bind_time,
        case when b.r12_purchase_amount > 10.00 then 1 else 0 END as r12_purchased,
        isnull(b.history_purchase_amount,0.00) as history_purchase_amount,
        isnull(b.r12_order_count, 0) as r12_order_count,
        isnull(b.r12_purchase_amount, 0.00) as r12_purchase_amount,
        isnull(b.r12_ps_order_count, 0 ) as r12_ps_order_count,
        isnull(b.r12_ps_purchase_amount, 0.00) as r12_ps_purchase_amount,
        isnull(b.r12_ps_purchase_times, 0) as r12_ps_purchase_times,
        isnull(b.last_purchase_date, null) as last_purchase_date,
        isnull(b.last_ps_purchase_date, null) as last_ps_purchase_date,
        isnull(b.current_PS_samrtba_purchase_order_count,0) as current_PS_samrtba_purchase_order_count,
        isnull(b.current_PS_samrtba_purchase_amount,0) as current_PS_samrtba_purchase_amount,
        isnull(b.current_PS_not_samrtba_purchase_order_count,0) as current_PS_not_samrtba_purchase_order_count,
        isnull(b.current_PS_not_samrtba_purchase_amount,0) as current_PS_not_samrtba_purchase_amount,
        isnull(b.current_PS_not_online_purchase_order_count,0) as current_PS_not_online_purchase_order_count,
        isnull(b.current_PS_not_online_purchase_amount,0) as current_PS_not_online_purchase_amount
    INTO #smartba_user_purchase
    FROM #smartba_user_base a
    LEFT JOIN (
        SELECT member_card,
            SUM(a.item_apportion_amount) as [history_purchase_amount],
            SUM(case when a.place_time >= @start_date AND a.place_time <@end_date  then a.item_apportion_amount else 0.0 end) as [r12_purchase_amount],
            COUNT(DISTINCT case when a.place_time >= @start_date AND a.place_time <@end_date  THEN a.sales_order_number else null end) as [r12_order_count],
            COUNT(DISTINCT case when a.place_time >= @start_date AND a.place_time <@end_date AND b.PS_Period IS NOT NULL THEN a.sales_order_number else null end) as [r12_ps_order_count],
            SUM(case when a.place_time >= @start_date AND a.place_time <@end_date AND b.PS_Period IS NOT NULL then a.item_apportion_amount else 0.0 end) as [r12_ps_purchase_amount],
            COUNT(DISTINCT b.PS_Period) as [r12_ps_purchase_times],
            MAX(place_time) as [last_purchase_date],
            MAX(case when b.PS_Period IS NOT NULL then a.place_time else null end) as [last_ps_purchase_date],
            --MAX(case when a.place_time >= @PS_startdate AND a.place_time <@PS_enddate AND a.is_smartba=1 then 1 else 0 end ) as [current_PS_samrtba_purchase_flag],
            COUNT(DISTINCT case when a.place_time >= @PS_startdate AND a.place_time <@PS_enddate AND a.is_smartba=1 then a.sales_order_number else null end) as [current_PS_samrtba_purchase_order_count],
            SUM(case when a.place_time >= @PS_startdate AND a.place_time <@PS_enddate AND a.is_smartba=1 then a.item_apportion_amount else 0.0 end) as [current_PS_samrtba_purchase_amount],
            --MAX(case when source='OMS' AND a.place_time >= @PS_startdate AND a.place_time <@PS_enddate AND a.is_smartba<>1 then 1 else 0 end ) as [current_PS_not_samrtba_purchase_flag],
            COUNT(DISTINCT case when  source='OMS' AND a.place_time >= @PS_startdate AND a.place_time <@PS_enddate AND a.is_smartba<>1 then a.sales_order_number else null end) as [current_PS_not_samrtba_purchase_order_count],
            SUM(case when  source='OMS' AND a.place_time >= @PS_startdate AND a.place_time <@PS_enddate AND a.is_smartba<>1 then a.item_apportion_amount else 0.0 end) as [current_PS_not_samrtba_purchase_amount],
            --MAX(case when source<>'OMS' AND a.place_time >= @PS_startdate AND a.place_time <@PS_enddate then 1 else 0 end ) as [current_PS_not_online_purchase_flag],
            COUNT(DISTINCT case when  source<>'OMS' AND a.place_time >= @PS_startdate AND a.place_time <@PS_enddate then a.sales_order_number else null end) as [current_PS_not_online_purchase_order_count],
            SUM(case when  source<>'OMS' AND a.place_time >= @PS_startdate AND a.place_time <@PS_enddate then a.item_apportion_amount else 0.0 end) as [current_PS_not_online_purchase_amount]
        FROM DWD.Fact_Sales_Order a
        LEFT JOIN #ps_period b
            ON a.place_time BETWEEN b.start_time AND b.end_time
        WHERE place_time < @PS_enddate
        GROUP BY member_card
    ) b
        on a.member_card = b.member_card

    --Step4
    --所有会员过去一年购买品类统计
    --包含没有绑定smartba的会员，没有非会员
    IF OBJECT_ID('tempdb..#category_sales_summary') IS NOT NULL 
    DROP TABLE  #category_sales_summary
    
    SELECT
        member_card,
        isnull(c.sap_category_description, 'Unknown') as [category],
        SUM(item_apportion_amount) as [category_purchase_amount],
        SUM(item_quantity) as [category_quantity],
        SUM(case when b.PS_Period IS NOT NULL then item_apportion_amount else 0.00 end) as [category_ps_purchase_amount],
        SUM(case when b.PS_Period IS NOT NULL then item_quantity else 0 end) as [category_ps_quantity]
    into #category_sales_summary
    FROM DWD.Fact_Sales_Order a
    LEFT JOIN #ps_period b ON a.place_time BETWEEN b.start_time AND b.end_time
    LEFT join [DWD].[DIM_SKU_Info] c on c.sku_code = a.item_sku_code
    WHERE place_time < @end_date
        AND place_time >= @start_date
    GROUP BY member_card, isnull(c.sap_category_description, 'Unknown')

    --Step5
    --smartba 绑定的会员购买品类，R12最多购买品类
    --包含有绑定关系的会员和非会员,非会员没有购买记录
    IF OBJECT_ID('tempdb..#smartba_user_purchase_category') IS NOT NULL 
    DROP TABLE  #smartba_user_purchase_category
    SELECT a.*, b.r12_category_amount, c.r12_category_quantity, d.r12_ps_category_amount , e.r12_ps_category_quantity
    INTO #smartba_user_purchase_category
    FROM #smartba_user_purchase a
    LEFT JOIN
        --最大购买金额品类
        (
        SELECT member_card, category as [r12_category_amount]
        FROM (
            SELECT member_card, category, ROW_NUMBER() over(PARTITION BY member_card ORDER BY category_purchase_amount desc) as [rank]
            FROM #category_sales_summary a
         ) a
        WHERE [rank] = 1
    ) b
        on a.member_card = b.member_card
    LEFT JOIN
        --最多购买数量品类
    (
        SELECT member_card, category as [r12_category_quantity]
        FROM
            (
            SELECT member_card, category, ROW_NUMBER() over(PARTITION BY member_card ORDER BY category_quantity desc) as [rank]
            FROM #category_sales_summary a
        ) a
        WHERE [rank] = 1
    ) c
        on a.member_card = c.member_card
    LEFT JOIN
        --大促最大购买金额品类
        (
        SELECT member_card, category as [r12_ps_category_amount]
        FROM (
            SELECT member_card, category, ROW_NUMBER() over(PARTITION BY member_card ORDER BY category_ps_purchase_amount desc) as [rank]
            FROM #category_sales_summary a
        ) a
        WHERE [rank] = 1
    ) d
        on a.member_card = d.member_card
    LEFT JOIN
        --大促最大购买数量品类
        (
        SELECT member_card, category as [r12_ps_category_quantity]
        FROM (
            SELECT member_card, category, ROW_NUMBER() over(PARTITION BY member_card ORDER BY category_ps_quantity desc) as [rank]
            FROM #category_sales_summary a
         ) a
        WHERE [rank] = 1
    ) e on a.member_card = e.member_card


    --Step6
    --所有会员过去一年购买渠道统计
    --所有会员，不管有没有绑定smartba，但是没有非会员
    IF OBJECT_ID('tempdb..#r12_channel_sales_summary') IS NOT NULL 
    DROP TABLE  #r12_channel_sales_summary
    SELECT
        member_card,
        channel_code,
        SUM(item_apportion_amount) as [channel_purchase_amount],
        COUNT(DISTINCT sales_order_number) as [channel_order],
        SUM(case when b.PS_Period IS NOT NULL then item_apportion_amount else 0.00 end) as [channel_ps_purchase_amount]
    into #r12_channel_sales_summary
    FROM DWD.Fact_Sales_Order a
    LEFT JOIN #ps_period b ON a.place_time BETWEEN b.start_time AND b.end_time
    WHERE place_time < @end_date
        AND place_time >= @start_date
    GROUP BY member_card, channel_code

    --Step7
    --所有会员过去一年购买品牌统计
    --所有会员，不管有没有绑定smartba，但是没有非会员
    IF OBJECT_ID('tempdb..#brand_sales_summary') IS NOT NULL 
    DROP TABLE  #brand_sales_summary
    SELECT
        member_card,
        isnull(c.sap_brand_name, 'Unknown') as [brand],
        SUM(item_apportion_amount) as [brand_purchase_amount],
        SUM(item_quantity) as [brand_quantity]
    into #brand_sales_summary
    FROM DWD.Fact_Sales_Order a
    LEFT join [DWD].[DIM_SKU_Info] c on c.sku_code = a.item_sku_code
    WHERE place_time < @end_date
        AND place_time >= @start_date
    GROUP BY member_card, isnull(c.sap_brand_name, 'Unknown')

    --Step8
    --包含有绑定关系的会员和非会员,非会员没有购买记录
    IF OBJECT_ID('tempdb..#smartba_user_purchase_category_channel_brand') IS NOT NULL 
    DROP TABLE  #smartba_user_purchase_category_channel_brand

    SELECT a.*, b.r12_channel_amount, c.r12_channel_order, d.r12_ps_channel_amount, e.r12_brand_amount, f.r12_brand_quantity
    INTO #smartba_user_purchase_category_channel_brand
    FROM #smartba_user_purchase_category a
    LEFT JOIN
        --最大金额购买金额渠道
        (
        SELECT member_card, channel_code as [r12_channel_amount]
        FROM (
            SELECT member_card, channel_code, ROW_NUMBER() over(PARTITION BY member_card ORDER BY channel_purchase_amount desc) as [rank]
            FROM #r12_channel_sales_summary a
        ) a
        WHERE [rank] = 1
    ) b on a.member_card = b.member_card
        --大促最大购买金额渠道
    LEFT JOIN (
        SELECT member_card, channel_code as [r12_channel_order]
        FROM (
            SELECT member_card, channel_code, ROW_NUMBER() over(PARTITION BY member_card ORDER BY channel_ps_purchase_amount desc) as [rank]
            FROM #r12_channel_sales_summary a
        ) a
        WHERE [rank] = 1
    ) c on a.member_card = c.member_card
        --最多订单数购买渠道
    LEFT JOIN (
        SELECT member_card, channel_code as [r12_ps_channel_amount]
        FROM (
            SELECT member_card, channel_code, ROW_NUMBER() over(PARTITION BY member_card ORDER BY channel_order desc) as [rank]
            FROM #r12_channel_sales_summary a
        ) a
        WHERE [rank] = 1
    ) d on a.member_card = d.member_card
    LEFT JOIN
        --最大金额购买品牌
        (
        SELECT member_card, brand as [r12_brand_amount]
        FROM (
            SELECT member_card, brand, ROW_NUMBER() over(PARTITION BY member_card ORDER BY brand_purchase_amount desc) as [rank]
            FROM #brand_sales_summary a
        ) a
        WHERE [rank] = 1
    ) e on a.member_card = e.member_card
    LEFT JOIN
        --最多数量购买品牌
        (
        SELECT member_card, brand as [r12_brand_quantity]
        FROM (
            SELECT member_card, brand, ROW_NUMBER() over(PARTITION BY member_card ORDER BY brand_quantity desc) as [rank]
            FROM #brand_sales_summary a
        ) a
        WHERE [rank] = 1
    ) f on a.member_card = f.member_card
    
    --Step9
    --R12线下线上订单统计
    --所有会员，不管有没有绑定smartba，但是没有非会员
    IF OBJECT_ID('tempdb..#r12_omni_purchase') IS NOT NULL 
    DROP TABLE  #r12_omni_purchase

    SELECT
        member_card,
        COUNT(DISTINCT case when channel_code = 'OFF_LINE' then sales_order_number else null end) as [offline_trans],
        COUNT(DISTINCT case when channel_code <> 'OFF_LINE' then sales_order_number else null end) as [online_trans]
    into #r12_omni_purchase
    FROM DWD.Fact_Sales_Order
    WHERE place_time < @end_date
        AND place_time >= @start_date
    GROUP BY member_card
    
    --Step10
    --R12降级统计
    --所有会员，不管有没有绑定smartba，但是没有非会员
    IF OBJECT_ID('tempdb..#downgrade_member_card') IS NOT NULL 
    DROP TABLE  #downgrade_member_card
    SELECT DISTINCT account_number as [member_card]
    into #downgrade_member_card
    FROM [ODS_CRM].[account_upgrade_downgrade_log]
    WHERE from_card_type > card_type
        AND setting_time >= @start_date
        AND setting_time < @end_date
    
    --Step11
    --R12升级统计
    --所有会员，不管有没有绑定smartba，但是没有非会员
    IF OBJECT_ID('tempdb..#upgrade_member_card') IS NOT NULL 
    DROP TABLE  #upgrade_member_card
    SELECT DISTINCT account_number as [member_card]
    into #upgrade_member_card
    FROM [ODS_CRM].[account_upgrade_downgrade_log]
    WHERE FROM_card_type < card_type
        AND setting_time >= @start_date
        AND setting_time < @end_date

    -----Step12
    -- Online visit统计
    --所有会员以及非会员，非会员用unionid 关联，不管有没有绑定smartba
    IF OBJECT_ID('tempdb..#online_visit') IS NOT NULL 
    DROP TABLE  #online_visit

    SELECT
        isnull(vip_card COLLATE SQL_Latin1_General_CP1_CI_AS,distinct_id)  as member_card,
        SUM(frequency) as [r12_online_visit],
        SUM(case when [Month] in ( '2023-05') then frequency else 0 END) as [last30_online_visit],
        SUM(case when [Month] in ( '2023-05') then frequency else 0 END) as [ps_last30_online_visit],
        SUM(case when [Month] in ( '2023-05') AND [event] = 'viewCommodityDetail' then frequency else 0 END) as [ps_last30_pdp_online_visit],
        SUM(case when [Month] in ('2023-05','2023-04','2023-03','2023-02','2023-01','2022-12', '2022-11','2022-10', '2022-09', '2022-08','2022-07', '2022-06') AND [event] = 'viewCommodityDetail' then frequency else 0 END) as [r12_pdp_online_visit],
        SUM(case when [Month] in ('2023-05','2023-04','2023-03','2023-02','2023-01','2022-12') AND [event] = 'viewCommodityDetail' then frequency else 0 END) as [last180_pdp_online_visit],
        SUM(case when [Month] in ('2023-05','2023-04','2023-03') AND [event] = 'viewCommodityDetail' then frequency else 0 END) as [last90_pdp_online_visit],
        SUM(case when [Month] in ('2023-05') AND [event] = 'viewCommodityDetail' then frequency else 0 END) as [last30_pdp_online_visit]
    into #online_visit
    --FROM [DWD].[Fact_OnlineVisit]
    FROM TEST.Fact_OnlineVisit_v2
    WHERE-- vip_card is NOT NULL AND 
	    [Month] >= substring(cast(@start_date as varchar),1,7)
    GROUP BY isnull(vip_card COLLATE SQL_Latin1_General_CP1_CI_AS,distinct_id)

    --Step13
    -- UV 统计
    --所有会员以及非会员，非会员用unionid 关联，不管有没有绑定smartba
    IF OBJECT_ID('tempdb..#smartba_uv') IS NOT NULL 
    DROP TABLE  #smartba_uv
    select
        isnull(vip_card COLLATE SQL_Latin1_General_CP1_CI_AS,unionid) as member_card,
        MAX(samrtba_uv) as smartba_uv,
        MAX(mnp_nonsmartba_uv+app_uv) as uv
    into #smartba_uv
    FROM [TEST].[smartba_Nonsmartba_uv]
    WHERE --vip_card is NOT NULL AND 
	    dt >=@PS_startdate
        AND dt <@PS_enddate
    GROUP BY isnull(vip_card COLLATE SQL_Latin1_General_CP1_CI_AS,unionid)

    IF OBJECT_ID('tempdb..#smartba_overall') IS NOT NULL 
    DROP TABLE  #smartba_overall
    SELECT
        a.*,
        CASE WHEN b.member_card is NULL then 0 ELSE 1 end as [R12_if_downgraded],
        CASE WHEN c.member_card is NULL then 0 ELSE 1 end as [R12_if_upgraded],
        d.card_type as [current_card_type],
        case when isnull(e.[offline_trans], 0) > 0 then 1 else 0 end as [R12_if_purchase_offline],
        case when isnull(e.[online_trans], 0) > 0 then 1 else 0 end as [R12_if_purchase_online],
        case when isnull(f.r12_online_visit,0) > 0 then 1 else 0 END as [R12_if_online_visit],
        case when isnull(f.last30_online_visit,0) > 0 then 1 else 0 END as [Last30Day_if_online_visit],
        case when isnull(f.ps_last30_online_visit,0) > 0 then 1 else 0 END as [30DayBeforePS_if_online_visit],
        case when isnull(f.r12_pdp_online_visit,0) > 0 then 1 else 0 END as [r12_pdp_online_visit],
        case when isnull(f.last180_pdp_online_visit,0) > 0 then 1 else 0 END as [last180_pdp_online_visit],
        case when isnull(f.last90_pdp_online_visit,0) > 0 then 1 else 0 END as [last90_pdp_online_visit],
        case when isnull(f.last30_pdp_online_visit,0) > 0 then 1 else 0 END as [last30_pdp_online_visit],
        smartba_uv,
        uv
    into #smartba_overall
    FROM #smartba_user_purchase_category_channel_brand a --包含有绑定关系的会员和非会员,非会员没有购买记录
    LEFT JOIN #downgrade_member_card b --所有会员，不管有没有绑定smartba，但是没有非会员
        on a.member_card = b.member_card
    LEFT JOIN #upgrade_member_card c --所有会员，不管有没有绑定smartba，但是没有非会员
        on a.member_card = c.member_card
    LEFT join [DWD].[DIM_Member_Info] d --所有会员，不管有没有绑定smartba，但是没有非会员
        on a.member_card = d.member_card
    LEFT join #r12_omni_purchase e --所有会员，不管有没有绑定smartba，但是没有非会员
        on a.member_card = e.member_card
    LEFT join #online_visit f --所有会员以及非会员，非会员用unionid 关联，不管有没有绑定smartba
        on a.member_card = f.member_card
    LEFT JOIN #smartba_uv g --所有会员以及非会员，非会员用unionid 关联，不管有没有绑定smartba
        on a.member_card = g.member_card

    --Step14
    IF OBJECT_ID('DW_Sephora.TEST.SmartBA_Analysis_V6') IS NOT NULL 
    DROP TABLE TEST.SmartBA_Analysis_V6

    SELECT *
    into TEST.SmartBA_Analysis_V6
    FROM #smartba_overall

-- SELECT * FROM TEST.SmartBA_Analysis_V3

--SELECT * FROM TEST.SmartBA_Analysis_V6
END
GO
