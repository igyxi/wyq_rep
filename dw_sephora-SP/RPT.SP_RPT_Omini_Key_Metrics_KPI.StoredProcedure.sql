/****** Object:  StoredProcedure [RPT].[SP_RPT_Omini_Key_Metrics_KPI]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RPT].[SP_RPT_Omini_Key_Metrics_KPI] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-28       wubin        Initial Version
-- 2022-11-09       wangzhichun    update PLATFORM_TYPE & PAGE_ID
-- 2022-12-28       litao              Replacement target table
-- ========================================================================================
delete from  [RPT].[RPT_Omini_Key_Metrics_KPI] where [date]=@dt;
with omini_key_001  as
(
 select
        format(a.place_time,'yyyy-MM-dd') as [date]
       ,format(a.place_time,'yyyy-MM') as month_dt
       ,case
          when a.channel_code in ('TMALL','JD')
            then upper(a.channel_code)
          when (a.channel_code = 'SOA' or a.is_smartba = 1)
            then 'DRAGON'
          when a.sub_channel_code = 'DOUYIN001'
            then 'TIKTOK'
          when a.sub_channel_code = 'OFF_LINE'
            then 'RETAIL'
        end as channel
       ,case
          when a.sub_channel_code in ('APP(ANDROID)','APP(IOS)','APP')
            then 'APP'
          when a.sub_channel_code in ('PC','O2O')
            then A.sub_channel_code
          when a.sub_channel_code = 'MINIPROGRAM' and a.is_smartba != 1
            then 'MNP_EXCL.SBA'
          when a.is_smartba = 1
            then 'SMARTBA'
          when a.sub_channel_code = 'MOBILE'
            then 'MOBILE'
          when a.sub_channel_code = 'TMALL001'
            then 'TMALL_SEPHORA'
          when a.sub_channel_code = 'TMALL006'
            then 'TMALL_WEI'
          when a.sub_channel_code = 'TMALL005'
            then 'TMALL_PTR'
          when a.sub_channel_code = 'TMALL004'
            then 'TMALL_CHALING'
          when a.sub_channel_code = 'JD003'
            then 'JD_FCS'
          when a.sub_channel_code = 'JD001'
            then 'JD'
          when a.sub_channel_code = 'DOUYIN001'
            then 'TikTok'
          when a.sub_channel_code = 'OFF_LINE'
            then 'RETAIL'
        end as platform
       ,sum(case when a.item_sku_code != 'TRP001' then a.item_apportion_amount end) as payment_sales
       ,count(distinct case when a.item_sku_code != 'TRP001' then a.sales_order_number end) as payment_order
       ,sum(case when a.item_sku_code != 'TRP001' then a.sap_amount end) as sap_sales
       ,count(distinct case when a.item_sku_code != 'TRP001' then a.sap_transaction_number end) as sap_order
       ,sum(case when a.item_apportion_amount!= 0 and a.item_sku_code != 'TRP001' then a.item_quantity end) as item_quantity
       ,count(distinct a.member_card) aS Daily_Buyer
       ,case when a.is_smartba = 1 then b.smartba_bundle_consumer end as smartba_bundle_consumer
       ,sum(case when c.card_no is not null then 1 end) as nmp_smartba_bundle_consumer
   from
        DWD.Fact_Sales_Order a
   left join
            (
             select
                    format(bindingtime,'yyyy-MM-dd') as date
                   ,count(distinct unionid) as smartba_bundle_consumer
               from
                    DW_SmartBA.DWS_BA_Customer_REL
              where format(bindingtime,'yyyy-MM-dd') = @dt
              group by
                    format(bindingtime,'yyyy-MM-dd')
            ) b
     on
        format(a.place_time,'yyyy-MM-dd') = B.date
    and
        a.is_smartba = 1
   left join
            (
             select distinct
                    b.card_no
               from
                    DW_SmartBA.DWS_BA_Customer_REL  a
               join
                    DW_WechatCenter.DWS_Wechat_User_Info b
                 on
                    a.unionid = b.union_id
              where a.[status] = 0
                and a.bindingtime is not null
            ) c
     on a.member_card = c.card_no
    and a.is_smartba = 1
    and a.member_card is not null
  where a.is_placed = 1
    and format(a.place_time,'yyyy-MM-dd') = @dt
    and (a.sub_channel_code in ('APP(ANDROID)','APP(IOS)','APP','PC','O2O','MINIPROGRAM','MOBILE','TMALL001','TMALL006','TMALL005','TMALL004','JD003','JD001','DOUYIN001','OFF_LINE') 
     or a.is_smartba = 1)
  group by
        format(a.place_time,'yyyy-MM-dd')
       ,format(a.place_time,'yyyy-MM')
       ,case
          when a.channel_code in ('TMALL','JD')
            then upper(a.channel_code)
          when (a.channel_code = 'SOA' or a.is_smartba = 1)
            then 'DRAGON'
          when a.sub_channel_code = 'DOUYIN001'
            then 'TIKTOK'
          when a.sub_channel_code = 'OFF_LINE'
            then 'RETAIL'
        end
       ,case
          when a.sub_channel_code in ('APP(ANDROID)','APP(IOS)','APP')
            then 'APP'
          when a.sub_channel_code in ('PC','O2O')
            then A.sub_channel_code
          when a.sub_channel_code = 'MINIPROGRAM' and a.is_smartba != 1
            then 'MNP_EXCL.SBA'
          when a.is_smartba = 1
            then 'SMARTBA'
          when a.sub_channel_code = 'MOBILE'
            then 'MOBILE'
          when a.sub_channel_code = 'TMALL001'
            then 'TMALL_SEPHORA'
          when a.sub_channel_code = 'TMALL006'
            then 'TMALL_WEI'
          when a.sub_channel_code = 'TMALL005'
            then 'TMALL_PTR'
          when a.sub_channel_code = 'TMALL004'
            then 'TMALL_CHALING'
          when a.sub_channel_code = 'JD003'
            then 'JD_FCS'
          when a.sub_channel_code = 'JD001'
            then 'JD'
          when a.sub_channel_code = 'DOUYIN001'
            then 'TikTok'
          when a.sub_channel_code = 'OFF_LINE'
            then 'RETAIL'
        end
       ,case when a.is_smartba = 1 then b.smartba_bundle_consumer end
  union all
 select
        format(t.place_time,'yyyy-MM-dd') as date
       ,format(t.place_time,'yyyy-MM') as month_dt
       ,case
          when t.channel_code in ('TMALL','JD')
            then upper(t.channel_code)
          when (t.channel_code = 'SOA' or t.is_smartba = 1)
            then 'DRAGON'
          when t.sub_channel_code = 'DOUYIN001'
            then 'TIKTOK'
          when t.sub_channel_code = 'OFF_LINE'
            then 'RETAIL'
        end as channel
       ,case
          when t.sub_channel_code in ('APP(ANDROID)','APP(IOS)','APP')
            then 'APP'
          when t.sub_channel_code in ('PC','O2O')
            then T.sub_channel_code
          when t.sub_channel_code = 'MINIPROGRAM' and t.is_smartba != 1
            then 'MNP_EXCL.SBA'
          when t.is_smartba = 1
            then 'SmartBA'
          when t.sub_channel_code = 'MOBILE'
            then 'MOBILE'
          when t.sub_channel_code = 'TMALL001'
            then 'TMALL_Sephora'
          when t.sub_channel_code = 'TMALL006'
            then 'TMALL_WEI'
          when t.sub_channel_code = 'TMALL005'
            then 'TMALL_PTR'
          when t.sub_channel_code = 'TMALL004'
            then 'TMALL_CHALING'
          when t.sub_channel_code = 'JD003'
            then 'JD_FCS'
          when t.sub_channel_code = 'JD001'
            then 'JD'
          when t.sub_channel_code = 'DOUYIN001'
            then 'TikTok'
          when t.sub_channel_code = 'OFF_LINE'
            then 'RETAIL'
        end as platform
       ,null as payment_sales
       ,null as payment_order
       ,sum(case when t.item_apportion_amount!= 0 and t.item_sku_code != 'TRP001' then t1.item_apportion_amount end)*(-1) as sap_sales
       ,null as sap_order
       ,null as item_quantity
       ,null as daily_buyer
       ,null as smartba_bundle_consumer
       ,null as nmp_smartba_bundle_consumer
   from
        DWD.Fact_Refund_Order t1
   left join
        DWD.Fact_Sales_Order t
     on t.sales_order_number = t1.sales_order_number
    and t.item_sku_code = t1.item_sku_code
  where t.is_placed = 1
    and format(t.place_time,'yyyy-MM-dd') = @dt
    and (t.sub_channel_code in ('APP(ANDROID)','APP(IOS)','APP','PC','O2O','MINIPROGRAM','MOBILE','TMALL001','TMALL006','TMALL005','TMALL004','JD003','JD001','DOUYIN001','OFF_LINE')
         or T.is_smartba = 1)
  group by
        format(t.place_time,'yyyy-MM-dd') 
       ,format(t.place_time,'yyyy-MM') 
       ,case
          when t.channel_code in ('TMALL','JD')
            then upper(t.channel_code)
          when (t.channel_code = 'SOA' or t.is_smartba = 1)
            then 'DRAGON'
          when t.sub_channel_code = 'DOUYIN001'
            then 'TIKTOK'
          when t.sub_channel_code = 'OFF_LINE'
            then 'RETAIL'
        end
       ,case
          when t.sub_channel_code in ('APP(ANDROID)','APP(IOS)','APP')
            then 'APP'
          when t.sub_channel_code in ('PC','O2O')
            then t.sub_channel_code
          when t.sub_channel_code = 'MINIPROGRAM' and t.is_smartba != 1
            then 'MNP_EXCL.SBA'
          when t.is_smartba = 1
            then 'SmartBA'
          when t.sub_channel_code = 'MOBILE'
            then 'MOBILE'
          when t.sub_channel_code = 'TMALL001'
            then 'TMALL_Sephora'
          when t.sub_channel_code = 'TMALL006'
            then 'TMALL_WEI'
          when t.sub_channel_code = 'TMALL005'
            then 'TMALL_PTR'
          when t.sub_channel_code = 'TMALL004'
            then 'TMALL_CHALING'
          when t.sub_channel_code = 'JD003'
            then 'JD_FCS'
          when t.sub_channel_code = 'JD001'
            then 'JD'
          when t.sub_channel_code = 'DOUYIN001'
            then 'TikTok'
          when t.sub_channel_code = 'OFF_LINE'
            then 'RETAIL'
        end
  union all
 select
        format(a.place_time,'yyyy-MM-dd') as date
       ,format(a.place_time,'yyyy-MM') as month_dt
       ,'DRAGON' as channel
       ,'MNP' platform
       ,sum(case when a.item_sku_code != 'TRP001' then a.item_apportion_amount end) as payment_sales
       ,count(distinct case when a.item_sku_code != 'TRP001' then a.sales_order_number end) as payment_order
       ,sum(case when a.item_sku_code != 'TRP001' then a.sap_amount end) as sap_sales
       ,count(distinct case when a.item_sku_code != 'TRP001' then a.sap_transaction_number end) as sap_order
       ,sum(case when a.item_apportion_amount!= 0 and a.item_sku_code != 'TRP001' then a.item_quantity end) as item_quantity
       ,count(distinct a.member_card) as daily_Buyer
       ,null as smartba_bundle_consumer
       ,null as nmp_smartba_bundle_consumer
   from
        DWD.Fact_Sales_Order a
  where a.is_placed = 1
    and format(a.place_time,'yyyy-MM-dd') = @dt
    and a.sub_channel_code in ('MINIPROGRAM')
  group by
        format(a.place_time,'yyyy-MM-dd')
       ,format(a.place_time,'yyyy-MM')
),

--uv pv
omini_key_002 as
(
 select
        dt as date
       ,'SMARTBA' as platform
       ,pv
       ,uv
   from
        DW_Sensor.RPT_SmartBA_PV_UV_Daily
  where dt = @dt
  union all
 select 
        date
       ,case when platform_type = 'MINIPROGRAM' then 'MNP'
             when platform_type = 'APP' then 'APP'
             when platform_type = 'MOBILE' then 'MOBILE'
             when platform_type = 'PC' then 'PC'
        end as platform
       ,pv
       ,uv
   from 
        DW_Sensor.RPT_Sensor_Site_Daily_KPI
  where date = @dt
    and platform_type is not null
  union all
 select
        date
       ,case  when platform_type in ('Mini Program','MiniProgram') then 'MNP_EXCL.SBA' end as platform
       ,count(1) as pv
       ,count(distinct user_id) as uv
   from
        STG_Sensor.Events
  where date = @dt
    and event in ('$AppViewScreen','$MPViewScreen')
    and charindex('ba=',ss_url_query) !> 0
    and platform_type in('Mini Program','MiniProgram')
  group by
        date,
        case when platform_type in ('Mini Program','MiniProgram') then 'MNP_EXCL.SBA' end
  union all
 select
        t.date
       ,t.platform
       ,null as pv
       ,sum(t1.visitors) as uv
   from
       (
        select distinct
               format(a.place_time,'yyyy-MM-dd') as date
              ,case when a.sub_channel_code = 'OFF_LINE' then 'RETAIL' end as platform
              ,a.store_code
          from
               DWD.Fact_Sales_Order A
         where a.is_placed = 1
           and format(a.place_time,'yyyy-MM-dd') = @dt
           and a.sub_channel_code = 'OFF_LINE'
        ) t
   left join
       (
        select
               store_code,date,visitors
              ,row_number() over(partition by store_code,date order by visitors desc) as rn
          from
               DWD.Fact_Store_Traffic
         where date = @dt
        ) t1
     on
        t.store_code = t1.store_code
    and t.date = t1.date
    and t1.rn = 1
  group by
        t.date,t.platform
)



--MTD

insert into [RPT].[RPT_Omini_Key_Metrics_KPI]
select
       a.[date]
      ,a.channel as channel
      ,a.platform as platform_type
      ,a.payment_sales
      ,a.payment_order
      ,a.sap_sales
      ,a.sap_order
      ,a.item_quantity
      ,b.pv
      ,b.uv
      ,a.daily_buyer
      ,sum(a.daily_buyer) over (partition by a.month_dt,a.platform order by a.[date] rows between unbounded preceding and current row) as mtd_daily_buyer
      ,a.smartba_bundle_consumer
      ,a.nmp_smartba_bundle_consumer
      ,current_timestamp as insert_timestamp
  from
       (select 
               [date]
              ,month_dt
              ,channel
              ,platform
              ,sum(payment_sales) as payment_sales
              ,sum(payment_order) as payment_order
              ,sum(sap_sales) as sap_sales
              ,sum(sap_order) as sap_order
              ,sum(item_quantity) as item_quantity
              ,sum(daily_buyer) as daily_buyer
              ,sum(smartba_bundle_consumer) as smartba_bundle_consumer
              ,sum(nmp_smartba_bundle_consumer) as nmp_smartba_bundle_consumer
          from Omini_Key_001
         group by 
               [date]
              ,month_dt
              ,channel
              ,platform
        ) a
  left join
       Omini_Key_002 b
    on  a.date = b.date
   and  a.platform = b.platform
;
END
GO
