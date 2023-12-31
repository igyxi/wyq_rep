/****** Object:  StoredProcedure [DWD].[Omini_Key_Metrics_001]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[Omini_Key_Metrics_001] AS
BEGIN
truncate table DWD.Omini_Key_Metrics_001 ;
insert into DWD.Omini_Key_Metrics_001
SELECT format(A.PLACE_TIME,'yyyy-MM-dd') AS Date
      ,CASE 
         WHEN A.channel_code IN ('TMALL','JD') THEN A.channel_code
         WHEN (A.channel_code = 'SOA' OR A.is_smartba = 1) THEN 'Dragon'
         WHEN A.sub_channel_code = 'DOUYIN001' THEN 'Tik Tok'
         WHEN A.sub_channel_code = 'OFF_LINE' THEN 'Retail'
       END AS Channel
      ,CASE 
         WHEN A.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP') THEN 'APP'
         WHEN A.sub_channel_code IN ('PC','O2O') THEN A.sub_channel_code
         WHEN A.sub_channel_code = 'MINIPROGRAM' AND A.is_smartba != 1 THEN 'MNP_Excl_SmartBA'
         WHEN A.is_smartba = 1 THEN 'SmartBA'
         WHEN A.sub_channel_code = 'MINIPROGRAM' THEN 'MNP'
         WHEN A.sub_channel_code = 'MOBILE' THEN 'MOB'
         WHEN A.sub_channel_code = 'TMALL001' THEN 'TMALL_Sephora'
         WHEN A.sub_channel_code = 'TMALL006' THEN 'TMALL_WEI'
         WHEN A.sub_channel_code = 'TMALL005' THEN 'TMALL_PTR'
         WHEN A.sub_channel_code = 'TMALL004' THEN 'TMALL_Chaling'
         WHEN A.sub_channel_code = 'JD003' THEN 'JD_FCS'
         WHEN A.sub_channel_code = 'JD001' THEN 'JD'
         WHEN A.sub_channel_code = 'DOUYIN001' THEN 'Tik Tok'
         WHEN A.sub_channel_code = 'OFF_LINE' THEN 'Retail'
       END AS Platform
      ,SUM(A.item_apportion_amount) AS Payment_Sales
      ,COUNT(DISTINCT A.sales_order_number) AS Payment_Order
      ,SUM(A.sap_amount) AS SAP_Sales
      ,COUNT(DISTINCT A.sap_transaction_number) AS SAP_Order
      ,SUM(A.item_quantity) AS Item_Quantity
      ,COUNT(DISTINCT A.member_card) AS Daily_Buyer
FROM DWD.Fact_Sales_Order A
WHERE A.is_placed = 1
AND format(A.PLACE_TIME,'yyyy-MM-dd') >= '2022-06-01'
AND format(A.PLACE_TIME,'yyyy-MM-dd') < '2022-07-01'
AND (A.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP','PC','O2O','MINIPROGRAM','MOBILE','TMALL001','TMALL006','TMALL005','TMALL004','JD003','JD001','DOUYIN001','OFF_LINE') 
OR A.is_smartba = 1)
GROUP BY format(A.PLACE_TIME,'yyyy-MM-dd')
        ,CASE 
           WHEN A.channel_code IN ('TMALL','JD') THEN A.channel_code
           WHEN (A.channel_code = 'SOA' OR A.is_smartba = 1) THEN 'Dragon'
           WHEN A.sub_channel_code = 'DOUYIN001' THEN 'Tik Tok'
           WHEN A.sub_channel_code = 'OFF_LINE' THEN 'Retail'
         END
        ,CASE 
           WHEN A.sub_channel_code IN ('APP(ANDROID)','APP(IOS)','APP') THEN 'APP'
           WHEN A.sub_channel_code IN ('PC','O2O') THEN A.sub_channel_code
           WHEN A.sub_channel_code = 'MINIPROGRAM' AND A.is_smartba != 1 THEN 'MNP_Excl_SmartBA'
           WHEN A.is_smartba = 1 THEN 'SmartBA'
           WHEN A.sub_channel_code = 'MINIPROGRAM' THEN 'MNP'
           WHEN A.sub_channel_code = 'MOBILE' THEN 'MOB'
           WHEN A.sub_channel_code = 'TMALL001' THEN 'TMALL_Sephora'
           WHEN A.sub_channel_code = 'TMALL006' THEN 'TMALL_WEI'
           WHEN A.sub_channel_code = 'TMALL005' THEN 'TMALL_PTR'
           WHEN A.sub_channel_code = 'TMALL004' THEN 'TMALL_Chaling'
           WHEN A.sub_channel_code = 'JD003' THEN 'JD_FCS'
           WHEN A.sub_channel_code = 'JD001' THEN 'JD'
           WHEN A.sub_channel_code = 'DOUYIN001' THEN 'Tik Tok'
           WHEN A.sub_channel_code = 'OFF_LINE' THEN 'Retail'
         END
union all
SELECT format(A.PLACE_TIME,'yyyy-MM-dd') AS Date
      ,CASE 
         WHEN (A.channel_code = 'SOA' OR A.is_smartba = 1) THEN 'Dragon'
       END AS Channel
      ,CASE 
         WHEN A.sub_channel_code = 'MINIPROGRAM' THEN 'MNP'
       END AS Platform
      ,SUM(A.item_apportion_amount) AS Payment_Sales
      ,COUNT(DISTINCT A.sales_order_number) AS Payment_Order
      ,SUM(A.sap_amount) AS SAP_Sales
      ,COUNT(DISTINCT A.sap_transaction_number) AS SAP_Order
      ,SUM(A.item_quantity) AS Item_Quantity
      ,COUNT(DISTINCT A.member_card) AS Daily_Buyer
FROM DWD.Fact_Sales_Order A
WHERE A.is_placed = 1
AND format(A.PLACE_TIME,'yyyy-MM-dd') >= '2022-06-01'
AND format(A.PLACE_TIME,'yyyy-MM-dd') < '2022-07-01'
AND A.sub_channel_code IN ('MINIPROGRAM') 
GROUP BY format(A.PLACE_TIME,'yyyy-MM-dd')
        ,CASE 
           WHEN (A.channel_code = 'SOA' OR A.is_smartba = 1) THEN 'Dragon'
         END
        ,CASE 
           WHEN A.sub_channel_code = 'MINIPROGRAM' THEN 'MNP'
         END
;
END

GO
