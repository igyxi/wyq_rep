/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_PCMOB_Channel_Media_Data_Monthly]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_PCMOB_Channel_Media_Data_Monthly] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2023-03-01       houshuangqiang     change  dw_oms.RPT_Sales_Order_Basic_Level to RPT.RPT_Sales_Order_Basic_Level
-- 2023-06-19       Leozhai        change order source to ODS
-- ========================================================================================
delete from DW_Sensor.RPT_PCMOB_Channel_Media_Data_Monthly where statistic_month = cast(@dt as varchar(7));
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
    dt between cast(cast(@dt as varchar(7))+'-01' as date) and @dt
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

insert into DW_Sensor.RPT_PCMOB_Channel_Media_Data_Monthly
select
    cast(a.dt as varchar(7)) as statistic_month,
    a.platform,
    case
        when a.latest_utm_medium in ('brandzone','brandzone?','BZ','MBZ','PCBZ') then 'Brandzone'
        when a.latest_utm_medium = 'cps' then 'CPS'
        when a.latest_utm_medium in ('cpc','dsp','traffic') then 'DSP'
        when a.latest_utm_medium in ('feeds','app') then 'Feeds'
        when a.latest_utm_medium in ('sem','mcpc','pccpc','msem','pcsem') then 'SEM'
        when a.latest_utm_medium = 'referral' then 'Referral'
        when a.latest_utm_medium = 'cooperation' then 'Cooperation'
        when a.latest_utm_medium in ('ecrm','email','ebmktemail','crm','crmmktsms','crmmktemail') then 'ECRM'
        when a.latest_utm_medium = 'ad' then 'AD'
        when a.latest_utm_medium = 'content' then 'Content'
        when a.latest_utm_medium = 'social' then 'Social'
        when a.latest_utm_medium = 'seco' then 'WeChat'
        when a.latest_utm_medium = 'social' and a.latest_utm_source = 'wechat' then 'WeChat'
        else 'Others'
        end as marketing_channel,
    a.latest_utm_medium as utm_medium,
    a.latest_utm_source as utm_source,
    sum(uv_cnt) as uv,
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
            dt between cast(cast(@dt as varchar(7))+'-01' as date) and @dt
        and
            platform_type in ('web', 'mobile', 'wechat', 'MiniProgram','Mini Program')
        and
            event='submitOrder'
    ) v
    left join
    (
        select distinct
            sales_order_number,
            is_placed as is_placed_flag,
            order_amount
        from
            RPT.RPT_Sales_Order_Basic_Level
        where
            channel_code = 'SOA'
        and
            is_placed = 1
    ) b
    on
        v.orderid collate SQL_Latin1_General_CP1_CI_AS = b.sales_order_number
    left join
    (
        select
            order_id,
            sum(total_amount - total_adjustment) as order_amount
        from
            [ODS_Order].[Orders]
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
group by
    cast(a.dt as varchar(7)),
    a.platform,
    case
        when a.latest_utm_medium in ('brandzone','brandzone?','BZ','MBZ','PCBZ') then 'Brandzone'
        when a.latest_utm_medium = 'cps' then 'CPS'
        when a.latest_utm_medium in ('cpc','dsp','traffic') then 'DSP'
        when a.latest_utm_medium in ('feeds','app') then 'Feeds'
        when a.latest_utm_medium in ('sem','mcpc','pccpc','msem','pcsem') then 'SEM'
        when a.latest_utm_medium = 'referral' then 'Referral'
        when a.latest_utm_medium = 'cooperation' then 'Cooperation'
        when a.latest_utm_medium in ('ecrm','email','ebmktemail','crm','crmmktsms','crmmktemail') then 'ECRM'
        when a.latest_utm_medium = 'ad' then 'AD'
        when a.latest_utm_medium = 'content' then 'Content'
        when a.latest_utm_medium = 'social' then 'Social'
        when a.latest_utm_medium = 'seco' then 'WeChat'
        when a.latest_utm_medium = 'social' and a.latest_utm_source = 'wechat' then 'WeChat'
        else 'Others'
        end,
    a.latest_utm_medium,
    a.latest_utm_source
;
end

GO
