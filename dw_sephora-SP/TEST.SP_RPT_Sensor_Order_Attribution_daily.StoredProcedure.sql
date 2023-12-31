/****** Object:  StoredProcedure [TEST].[SP_RPT_Sensor_Order_Attribution_daily]    Script Date: 2023/6/28 11:31:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEST].[SP_RPT_Sensor_Order_Attribution_daily] AS
BEGIN
truncate table TEST.RPT_Sensor_Order_Attribution_daily;
insert into TEST.RPT_Sensor_Order_Attribution_daily
SELECT
    a.place_date as statics_date,
    -- a.member_new_status as member_new_status,
    b.member_daily_new_status as member_new_status,
    -- b.member_monthly_new_status as member_new_status,
    a.channel_cd as platform_type,
    '1D' as attribution_type,
    case when attribution_type = '1D' then ss_utm_source else 'NO DETAIL' end as ss_utm_source,
    case when attribution_type = '1D' then ss_utm_medium else 'NO DETAIL' end as ss_utm_medium,
    sum(a.apportion_amount) as payed_amount,
    count(distinct a.sales_order_number) as payed_order,
    count(distinct a.member_card) as member_card,
    current_timestamp as insert_timestamp,
    a.dt as dt
FROM
    DW_Sensor.DWS_Sensor_Order_UTM_Attribution a 
left join [DW_OMS].[RPT_Sales_Order_Basic_Level] b on a.sales_order_number = b.sales_order_number
where 
    dt between '2021-01-01' and '2021-12-31'
group by 
    a.place_date,
    b.member_daily_new_status,
    a.channel_cd,
    case when attribution_type = '1D' then ss_utm_source else 'NO DETAIL' end,
    case when attribution_type = '1D' then ss_utm_medium else 'NO DETAIL' end,
    a.dt
end

GO
