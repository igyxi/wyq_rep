/****** Object:  StoredProcedure [TEMP].[SP_RPT_Omini_Key_Metrics_KPI_Bak_20221109]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Omini_Key_Metrics_KPI_Bak_20221109] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-28       wubin        Initial Version
-- ========================================================================================
delete from  [DW_Sensor].[RPT_Omini_Key_Metrics_KPI] where [DATE]=@dt;
with Omini_Key_001  as
(
 SELECT
        format(A.PLACE_TIME,'yyyy-MM-dd') AS [Date]
       ,format(A.PLACE_TIME,'yyyy-MM') AS month_dt
       ,CASE
          WHEN A.channel_code IN ('TMALL','JD')
            THEN A.channel_code
          WHEN (A.channel_code = 'SOA' OR A.is_smartba = 1)
            THEN 'Dragon'
          WHEN A.sub_channel_code = 'DOUYIN001'
            THEN 'Tik Tok'
          WHEN A.sub_channel_code = 'OFF_LINE'
            THEN 'Retail'
        END AS Channel
       ,CASE
          WHEN A.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP')
            THEN 'APP'
          WHEN A.sub_channel_code IN ('PC','O2O')
            THEN A.sub_channel_code
          WHEN A.sub_channel_code = 'MINIPROGRAM' AND A.is_smartba != 1
            THEN 'MNP_Excl_SmartBA'
          WHEN A.is_smartba = 1
            THEN 'SmartBA'
          WHEN A.sub_channel_code = 'MOBILE'
            THEN 'MOB'
          WHEN A.sub_channel_code = 'TMALL001'
            THEN 'TMALL_Sephora'
          WHEN A.sub_channel_code = 'TMALL006'
            THEN 'TMALL_WEI'
          WHEN A.sub_channel_code = 'TMALL005'
            THEN 'TMALL_PTR'
          WHEN A.sub_channel_code = 'TMALL004'
            THEN 'TMALL_Chaling'
          WHEN A.sub_channel_code = 'JD003'
            THEN 'JD_FCS'
          WHEN A.sub_channel_code = 'JD001'
            THEN 'JD'
          WHEN A.sub_channel_code = 'DOUYIN001'
            THEN 'Tik Tok'
          WHEN A.sub_channel_code = 'OFF_LINE'
            THEN 'Retail'
        END AS Platform
       ,SUM(CASE WHEN A.item_sku_code != 'TRP001' THEN A.item_apportion_amount END) AS Payment_Sales
       ,COUNT(DISTINCT CASE WHEN A.item_sku_code != 'TRP001' THEN A.sales_order_number END) AS Payment_Order
       ,SUM(CASE WHEN A.item_sku_code != 'TRP001' THEN A.sap_amount END) AS SAP_Sales
       ,COUNT(DISTINCT CASE WHEN A.item_sku_code != 'TRP001' THEN A.sap_transaction_number END) AS SAP_Order
       ,SUM(CASE WHEN A.item_apportion_amount!= 0 AND A.item_sku_code != 'TRP001' THEN A.item_quantity END) AS Item_Quantity
       ,COUNT(DISTINCT A.member_card) AS Daily_Buyer
       ,CASE WHEN A.is_smartba = 1 THEN B.SMARTBA_Bundle_Consumer END AS SMARTBA_Bundle_Consumer
       ,SUM(CASE WHEN C.card_no IS NOT NULL THEN 1 END) AS NMP_SMARTBA_Bundle_Consumer
   FROM
        DWD.Fact_Sales_Order A
   LEFT JOIN
            (
             SELECT
                    format(bindingtime,'yyyy-MM-dd') as date
                   ,count(distinct unionid) as SMARTBA_Bundle_Consumer
               FROM
                    DW_SmartBA.DWS_BA_Customer_REL
              where
                    format(bindingtime,'yyyy-MM-dd') = @dt
              group by
                    format(bindingtime,'yyyy-MM-dd')
            ) B
     ON
        format(A.PLACE_TIME,'yyyy-MM-dd') = B.date
    AND
        A.is_smartba = 1
   LEFT JOIN
            (
             select distinct
                    b.card_no
               from
                    DW_SmartBA.DWS_BA_Customer_REL  a
               JOIN
                    DW_WechatCenter.DWS_Wechat_User_Info b
                 on
                    a.unionid = b.union_id
              where
                    a.[status] = 0
                AND
                    A.bindingtime IS NOT NULL
            ) C
     ON
        A.member_card = C.card_no
    AND
        A.is_smartba = 1
    AND
        A.member_card IS NOT NULL
  WHERE
        A.is_placed = 1
    AND
        format(A.PLACE_TIME,'yyyy-MM-dd') = @dt
    AND
        (A.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP','PC','O2O','MINIPROGRAM','MOBILE','TMALL001','TMALL006','TMALL005','TMALL004','JD003','JD001','DOUYIN001','OFF_LINE')
         OR A.is_smartba = 1)
  GROUP BY
        format(A.PLACE_TIME,'yyyy-MM-dd')
       ,format(A.PLACE_TIME,'yyyy-MM')
       ,CASE
          WHEN A.channel_code IN ('TMALL','JD')
            THEN A.channel_code
          WHEN (A.channel_code = 'SOA' OR A.is_smartba = 1)
            THEN 'Dragon'
          WHEN A.sub_channel_code = 'DOUYIN001'
            THEN 'Tik Tok'
          WHEN A.sub_channel_code = 'OFF_LINE'
            THEN 'Retail'
        END
       ,CASE
          WHEN A.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP')
            THEN 'APP'
          WHEN A.sub_channel_code IN ('PC','O2O')
            THEN A.sub_channel_code
          WHEN A.sub_channel_code = 'MINIPROGRAM' AND A.is_smartba != 1
            THEN 'MNP_Excl_SmartBA'
          WHEN A.is_smartba = 1
            THEN 'SmartBA'
          WHEN A.sub_channel_code = 'MOBILE'
            THEN 'MOB'
          WHEN A.sub_channel_code = 'TMALL001'
            THEN 'TMALL_Sephora'
          WHEN A.sub_channel_code = 'TMALL006'
            THEN 'TMALL_WEI'
          WHEN A.sub_channel_code = 'TMALL005'
            THEN 'TMALL_PTR'
          WHEN A.sub_channel_code = 'TMALL004'
            THEN 'TMALL_Chaling'
          WHEN A.sub_channel_code = 'JD003'
            THEN 'JD_FCS'
          WHEN A.sub_channel_code = 'JD001'
            THEN 'JD'
          WHEN A.sub_channel_code = 'DOUYIN001'
            THEN 'Tik Tok'
          WHEN A.sub_channel_code = 'OFF_LINE'
            THEN 'Retail'
        END
       ,CASE WHEN A.is_smartba = 1 THEN B.SMARTBA_Bundle_Consumer END
  union all
 SELECT
        format(T.PLACE_TIME,'yyyy-MM-dd') AS Date
       ,format(T.PLACE_TIME,'yyyy-MM') AS month_dt
       ,CASE
          WHEN T.channel_code IN ('TMALL','JD')
            THEN T.channel_code
          WHEN (T.channel_code = 'SOA' OR T.is_smartba = 1)
            THEN 'Dragon'
          WHEN T.sub_channel_code = 'DOUYIN001'
            THEN 'Tik Tok'
          WHEN T.sub_channel_code = 'OFF_LINE'
            THEN 'Retail'
        END AS Channel
       ,CASE
          WHEN T.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP')
            THEN 'APP'
          WHEN T.sub_channel_code IN ('PC','O2O')
            THEN T.sub_channel_code
          WHEN T.sub_channel_code = 'MINIPROGRAM' AND T.is_smartba != 1
            THEN 'MNP_Excl_SmartBA'
          WHEN T.is_smartba = 1
            THEN 'SmartBA'
          WHEN T.sub_channel_code = 'MOBILE'
            THEN 'MOB'
          WHEN T.sub_channel_code = 'TMALL001'
            THEN 'TMALL_Sephora'
          WHEN T.sub_channel_code = 'TMALL006'
            THEN 'TMALL_WEI'
          WHEN T.sub_channel_code = 'TMALL005'
            THEN 'TMALL_PTR'
          WHEN T.sub_channel_code = 'TMALL004'
            THEN 'TMALL_Chaling'
          WHEN T.sub_channel_code = 'JD003'
            THEN 'JD_FCS'
          WHEN T.sub_channel_code = 'JD001'
            THEN 'JD'
          WHEN T.sub_channel_code = 'DOUYIN001'
            THEN 'Tik Tok'
          WHEN T.sub_channel_code = 'OFF_LINE'
            THEN 'Retail'
        END AS Platform
       ,NULL AS Payment_Sales
       ,NULL AS Payment_Order
       ,sum(CASE WHEN T.item_apportion_amount!= 0 AND T.item_sku_code != 'TRP001' THEN T1.item_apportion_amount END)*(-1) AS SAP_Sales
       ,NULL AS SAP_Order
       ,NULL AS item_quantity
       ,NULL AS Daily_Buyer
       ,NULL AS SMARTBA_Bundle_Consumer
       ,NULL AS NMP_SMARTBA_Bundle_Consumer
   FROM
        DWD.Fact_Refund_Order T1
   left join
        DWD.Fact_Sales_Order T
     ON
        T.sales_order_number = T1.sales_order_number
    AND
        T.item_sku_code = T1.item_sku_code
  WHERE
        T.is_placed = 1
    AND
        format(T.PLACE_TIME,'yyyy-MM-dd') = @dt
    AND
        (T.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP','PC','O2O','MINIPROGRAM','MOBILE','TMALL001','TMALL006','TMALL005','TMALL004','JD003','JD001','DOUYIN001','OFF_LINE')
         OR T.is_smartba = 1)
  GROUP BY
        format(T.PLACE_TIME,'yyyy-MM-dd') 
       ,format(T.PLACE_TIME,'yyyy-MM') 
       ,CASE
          WHEN T.channel_code IN ('TMALL','JD')
            THEN T.channel_code
          WHEN (T.channel_code = 'SOA' OR T.is_smartba = 1)
            THEN 'Dragon'
          WHEN T.sub_channel_code = 'DOUYIN001'
            THEN 'Tik Tok'
          WHEN T.sub_channel_code = 'OFF_LINE'
            THEN 'Retail'
        END
       ,CASE
          WHEN T.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP')
            THEN 'APP'
          WHEN T.sub_channel_code IN ('PC','O2O')
            THEN T.sub_channel_code
          WHEN T.sub_channel_code = 'MINIPROGRAM' AND T.is_smartba != 1
            THEN 'MNP_Excl_SmartBA'
          WHEN T.is_smartba = 1
            THEN 'SmartBA'
          WHEN T.sub_channel_code = 'MOBILE'
            THEN 'MOB'
          WHEN T.sub_channel_code = 'TMALL001'
            THEN 'TMALL_Sephora'
          WHEN T.sub_channel_code = 'TMALL006'
            THEN 'TMALL_WEI'
          WHEN T.sub_channel_code = 'TMALL005'
            THEN 'TMALL_PTR'
          WHEN T.sub_channel_code = 'TMALL004'
            THEN 'TMALL_Chaling'
          WHEN T.sub_channel_code = 'JD003'
            THEN 'JD_FCS'
          WHEN T.sub_channel_code = 'JD001'
            THEN 'JD'
          WHEN T.sub_channel_code = 'DOUYIN001'
            THEN 'Tik Tok'
          WHEN T.sub_channel_code = 'OFF_LINE'
            THEN 'Retail'
        END
  union all
 SELECT
        format(A.PLACE_TIME,'yyyy-MM-dd') AS Date
       ,format(A.PLACE_TIME,'yyyy-MM') AS month_dt
       ,'Dragon' AS Channel
       ,'MNP' Platform
       ,SUM(CASE WHEN A.item_sku_code != 'TRP001' THEN A.item_apportion_amount END) AS Payment_Sales
       ,COUNT(DISTINCT CASE WHEN A.item_sku_code != 'TRP001' THEN A.sales_order_number END) AS Payment_Order
       ,SUM(CASE WHEN A.item_sku_code != 'TRP001' THEN A.sap_amount END) AS SAP_Sales
       ,COUNT(DISTINCT CASE WHEN A.item_sku_code != 'TRP001' THEN A.sap_transaction_number END) AS SAP_Order
       ,SUM(CASE WHEN A.item_apportion_amount!= 0 AND A.item_sku_code != 'TRP001' THEN A.item_quantity END) AS Item_Quantity
       ,COUNT(DISTINCT A.member_card) AS Daily_Buyer
       ,NULL AS SMARTBA_Bundle_Consumer
       ,NULL AS NMP_SMARTBA_Bundle_Consumer
   FROM
        DWD.Fact_Sales_Order A
  WHERE
        A.is_placed = 1
    AND
        format(A.PLACE_TIME,'yyyy-MM-dd') = @dt
    AND
        A.sub_channel_code IN ('MINIPROGRAM')
  GROUP BY
        format(A.PLACE_TIME,'yyyy-MM-dd')
       ,format(A.PLACE_TIME,'yyyy-MM')
),

--uv pv
Omini_Key_002 as
(
 SELECT
        DT AS DATE
       ,'SmartBA' AS platform
       ,PV
       ,UV
   FROM
        DW_Sensor.RPT_SmartBA_PV_UV_Daily
  WHERE
        DT = @dt
  union all
 SELECT 
        DATE
       ,case when platform_type = 'MINIPROGRAM' then 'MNP'
             when platform_type = 'APP' then 'APP'
             when platform_type = 'MOBILE' then 'MOB'
             when platform_type = 'PC' then 'PC'
        end as platform
       ,PV
       ,UV
   FROM 
        DW_Sensor.RPT_Sensor_Site_Daily_KPI
  WHERE
        DATE = @dt
    AND
        PLATFORM_TYPE IS NOT NULL
  union all
 select
        date
       ,case
          when platform_type in ('Mini Program','MiniProgram')
            then 'MNP_Excl_SmartBA'
        end as platform
       ,count(1) as pv
       ,count(distinct user_id) as uv
   from
        STG_Sensor.Events
  where
        DATE = @dt
    AND
        event in ('$AppViewScreen','$MPViewScreen')
    and
        CHARINDEX('ba=',ss_url_query) !> 0
    and
        platform_type in('Mini Program','MiniProgram')
  group by
        date,
        case
          when platform_type in ('Mini Program','MiniProgram')
            then 'MNP_Excl_SmartBA'
        end
  union all
 SELECT
        T.Date
       ,T.Platform
       ,NULL AS pv
       ,SUM(T1.visitors) AS uv
   FROM
       (
        SELECT distinct
               format(A.PLACE_TIME,'yyyy-MM-dd') AS Date
              ,CASE
                 WHEN A.sub_channel_code = 'OFF_LINE'
                   THEN 'Retail'
               END AS Platform
              ,a.store_code
          FROM
               DWD.Fact_Sales_Order A
         WHERE
               A.is_placed = 1
           AND
               format(A.PLACE_TIME,'yyyy-MM-dd') = @dt
           AND
               A.sub_channel_code = 'OFF_LINE'
        ) T
   LEFT JOIN
       (
        SELECT
               store_code,date,visitors
              ,row_number() over(partition by store_code,date order by visitors desc) as rn
          FROM
               DWD.Fact_Store_Traffic
         WHERE
               DATE = @dt
        ) T1
     ON
        T.store_code = T1.store_code
    AND
        T.date = T1.date
    AND
        T1.RN = 1
  GROUP BY
        T.Date,T.Platform
)



--MTD

insert into [DW_Sensor].[RPT_Omini_Key_Metrics_KPI]
select
       a.[Date]
      ,A.Channel
      ,a.Platform
      ,A.Payment_Sales
      ,A.Payment_Order
      ,A.SAP_Sales
      ,A.SAP_Order
      ,A.Item_Quantity
      ,B.PV
      ,B.UV
      ,a.Daily_Buyer
      ,SUM(a.Daily_Buyer) OVER (
                          PARTITION BY a.month_dt,a.Platform
                          order by a.[Date]
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MTD_Daily_Buyer
      ,A.SMARTBA_Bundle_Consumer
      ,A.NMP_SMARTBA_Bundle_Consumer
      ,current_timestamp as insert_timestamp
  from
       (SELECT 
               [Date]
              ,month_dt
              ,Channel
              ,Platform
              ,SUM(Payment_Sales) AS Payment_Sales
              ,SUM(Payment_Order) AS Payment_Order
              ,SUM(SAP_Sales) AS SAP_Sales
              ,SUM(SAP_Order) AS SAP_Order
              ,SUM(Item_Quantity) AS Item_Quantity
              ,SUM(Daily_Buyer) AS Daily_Buyer
              ,SUM(SMARTBA_Bundle_Consumer) AS SMARTBA_Bundle_Consumer
              ,SUM(NMP_SMARTBA_Bundle_Consumer) AS NMP_SMARTBA_Bundle_Consumer
          FROM Omini_Key_001
         GROUP BY 
               [Date]
              ,month_dt
              ,Channel
              ,Platform
        ) a
  LEFT JOIN
       Omini_Key_002 B
    ON
       A.Date = B.Date
   AND
       A.Platform = B.Platform
;
END
GO
