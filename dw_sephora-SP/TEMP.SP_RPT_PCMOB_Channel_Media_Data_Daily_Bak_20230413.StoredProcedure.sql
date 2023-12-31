/****** Object:  StoredProcedure [TEMP].[SP_RPT_PCMOB_Channel_Media_Data_Daily_Bak_20230413]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_PCMOB_Channel_Media_Data_Daily_Bak_20230413] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       eddie.zhang    Initial Version
-- 2022-01-26       tali           add collate
-- ========================================================================================
delete from DW_Sensor.RPT_PCMOB_Channel_Media_Data_Daily where statistic_date = @dt;
with a as(
select 
    dt,
    count(distinct user_id) as uv_cnt,
    case when platform_type in ('mobile', 'wechat') then 'Mobile'
         when platform_type = 'web' then 'PC'
         when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
    end as platform,
    ss_latest_utm_medium as latest_utm_medium,
    ss_latest_utm_source as latest_utm_source,
    ss_latest_utm_campaign as latest_utm_campaign,
    ss_latest_utm_term as latest_utm_term,
    ss_latest_utm_content as latest_utm_content
from 
    [STG_Sensor].[Events]
where 
    dt = @dt
and 
    platform_type in ('web', 'mobile', 'wechat', 'MiniProgram','Mini Program')
group by 
    dt,
    case when platform_type in ('mobile', 'wechat') then 'Mobile'
         when platform_type = 'web' then 'PC'
         when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
    end,
    ss_latest_utm_medium,
    ss_latest_utm_source,
    ss_latest_utm_campaign,
    ss_latest_utm_term,
    ss_latest_utm_content
)

insert into DW_Sensor.RPT_PCMOB_Channel_Media_Data_Daily
select 
    a.dt as statistic_date,
    t.platform,
    t.latest_utm_medium as utm_medium,
    t.latest_utm_source as utm_source,
    t.latest_utm_campaign as utm_campaign,
    t.latest_utm_term as utm_term,
    t.latest_utm_content as utm_content,
    sum(uv_cnt) as uv,
    sum(convert_new) as convert_new,--新加字段
    sum(brand_new) as brand_new,--新加字段
    sum(orders) as orders,
    sum(sales) as sales,
    sum(payment_order) as payment_order,
    sum(payment_sales) as payment_sales,
    current_timestamp as insert_timestamp
from a
left join 
(
    select
        dt,
        case when platform_type in ('mobile', 'wechat') then 'Mobile'
             when platform_type = 'web' then 'PC'
             when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
        end as platform,
        ss_latest_utm_medium as latest_utm_medium,
        ss_latest_utm_source as latest_utm_source,
        ss_latest_utm_campaign as latest_utm_campaign,
        ss_latest_utm_term as latest_utm_term,
        ss_latest_utm_content as latest_utm_content,
        count(distinct case when b.all_order_placed_seq = 1 and b.member_card_grade in ('WHITE','BLACK','GOLD') then orderid else null end) as convert_new,
        count(distinct case when b.all_order_placed_seq = 1 and b.member_card_grade not in ('WHITE','BLACK','GOLD') then orderid else null end) as brand_new,
        count(distinct orderid) as orders,
        sum(coalesce(b.order_amount, c.order_amount)) as sales,
        count(distinct case when b.is_placed_flag = 1 then orderid end) as payment_order,
        sum(case when b.is_placed_flag = 1 then b.order_amount else 0 end) as payment_sales
    from 
    (
        select 
            * 
        from 
            [STG_Sensor].[Events] 
        where
            dt = @dt
        and 
            platform_type in ('web', 'mobile', 'wechat', 'MiniProgram','Mini Program')
        and 
            event='submitOrder'
    ) v 
    left join 
    (
        select distinct 
            sales_order_number,
            is_placed_flag,
            order_amount,
            all_order_placed_seq,
            super_id,--4.16新加字段
            member_card_grade
            --if(member_card_grade in ('WHITE','BLACK','GOLD','PINK'),super_id,null) as grade_super_id--4.16新加字段
        from
            dw_oms.RPT_Sales_Order_Basic_Level
        where
            store_cd = 'S001'
        and 
            is_placed_flag = 1
    ) b 
    on 
        v.orderid collate SQL_Latin1_General_CP1_CI_AS = b.sales_order_number
    left join 
    (
        select
            order_id,
            sum(total_amount - total_adjustment) as order_amount
        from
            [STG_Order].[Orders]
        where
            store = 'EB'
        group by
            order_id
    ) c 
    on 
        v.orderid collate SQL_Latin1_General_CP1_CI_AS = c.order_id
    group by 
        dt,
        case when platform_type in ('mobile', 'wechat') then 'Mobile'
             when platform_type = 'web' then 'PC'
             when platform_type in ('MiniProgram','Mini Program') then 'MiniProgram'
        end,
        ss_latest_utm_medium,
        ss_latest_utm_source,
        ss_latest_utm_campaign,
        ss_latest_utm_term,
        ss_latest_utm_content
) t
on 
    a.dt = t.dt
and 
    a.platform = t.platform 
and 
    a.latest_utm_medium = t.latest_utm_medium 
and 
    a.latest_utm_source = t.latest_utm_source 
and 
    a.latest_utm_campaign = t.latest_utm_campaign 
and 
    a.latest_utm_term = t.latest_utm_term 
and 
    a.latest_utm_content = t.latest_utm_content
where 
    t.platform is not null
group by
    a.dt,
    t.platform,
    t.latest_utm_medium,
    t.latest_utm_source,
    t.latest_utm_campaign,
    t.latest_utm_term,
    t.latest_utm_content;  
end

GO
