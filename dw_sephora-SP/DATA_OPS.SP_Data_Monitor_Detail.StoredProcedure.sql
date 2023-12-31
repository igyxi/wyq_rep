/****** Object:  StoredProcedure [DATA_OPS].[SP_Data_Monitor_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DATA_OPS].[SP_Data_Monitor_Detail] @dt [VARCHAR](10) AS
BEGIN

-- DECLARE @dt varchar(10) = '20220410'


-- declare @end_date nvarchar(10) = convert(nvarchar(10),dateadd(day ,1, @dt), 112)

-- while @dt <= convert(nvarchar(10),dateadd(hh,8,getutcdate()-1),112) 
-- begin

-- delete from [DATA_OPS].[Data_Monitor_Detail]
-- where dt = @dt

insert into [DATA_OPS].[Data_Monitor_Detail]
-- SELECT
--     A.date_id
--     ,A.Store_Code as store_code
--     ,B.Country_Code as channel
--     ,'[ODS_SAP].[Sales_Ticket]' as source
--     ,'New_SAP_Sales_Ticket' as kpi
--     ,cast(SUM([Sales_VAT]) as decimal(18,2)) as kvalue
--     ,CURRENT_TIMESTAMP AS [insert_timestamp]
--     ,@dt AS dt
-- from (
-- select
--         a.ticket_date as date_id,
--         a.store_code,
--         a.Material_Code,
--         SUM(convert(float,Sales_VAT)) AS Sales_VAT
--     from [ODS_SAP].[Sales_Ticket] a
--         join ODS_SAP.Dim_Material b
--         on a.Material_Code=b.Material_Code
--     where isnull(market_code,'')+isnull(target_code,'')+isnull(category_code,'')+isnull(sales_nature_code,'')+
-- isnull(range_code,'')+isnull(nature_code,'')
--  not in  (select ZMARCHE+ZCIBLE+ZRAYON+ZCOD_NATCA+ZGAMME+ZNATURE
--         from ODS_SAP.DimSKu_filter c)
--         and A.Material_Code <>'TRP001' and B.Material_Description not like  '%Gift Card%'
--     group by 
-- a.ticket_date,
-- a.store_code,
-- a.Material_Code
-- ) A
--     LEFT JOIN STG_SAP.DIM_Store B
--     ON A.Store_Code=B.Store_Code
-- where A.date_id = @dt
-- -- CONVERT(NVARCHAR(10), DATEADD([hour], 8, GETUTCDATE()) - 1, 112)
-- --     and .Country_Code = 'CN'
-- GROUP BY A.date_id
-- ,A.Store_Code
-- ,B.Country_Code

-- union ALL

-- SELECT 
-- A.[Date_Key] as date_id
-- ,A.Store_Code as store_code
-- ,B.Country_Code as channel
-- ,'[DW_SAP].[FACT_Sales]' as source
-- ,'Mech_Sales' as kpi
-- ,cast(SUM([Sales_VAT]) as decimal(18,2)) as kvalue
-- ,CURRENT_TIMESTAMP AS [insert_timestamp]
-- ,@dt AS dt
-- FROM [DW_SAP].[FACT_Sales] A (NOLOCK)
--     LEFT JOIN STG_SAP.DIM_Store B (NOLOCK)
--     ON A.Store_Code=B.Store_Code
-- WHERE A.Date_Key = @dt
-- --CONVERT(NVARCHAR(10), DATEADD([hour], 8, GETUTCDATE()) - 1, 112)
--     -- and b.Country_Code = 'CN'
-- GROUP BY A.[Date_Key]
-- ,A.Store_Code
-- ,B.Country_Code

-- union ALL

-- -- DECLARE @dt varchar(10) = '20220405'
-- select 
--     format(payment_time, 'yyyyMMdd') as date_id
--     ,store_cd as store_code
--     ,channel_cd as channel
--     ,'[DW_OMS].[DWS_Sales_Order]' as source
--     ,'OMS_Sales' as kpi
--     ,sum(payed_amount) as kvalue
--     ,CURRENT_TIMESTAMP AS [insert_timestamp]
--     ,@dt AS dt
-- from (
--     select
--             *,
--             row_number() over(partition by sales_order_number order by update_time desc) as [seq]
--         from DW_OMS.DWS_Sales_Order
-- ) a
-- where a.seq = 1
-- and format(payment_time, 'yyyyMMdd') = @dt
-- group by format(payment_time, 'yyyyMMdd')
--     ,store_cd
--     ,channel_cd

-- union ALL

-- SELECT 
-- 	Date_Key as date_id,
--     Store_Code as store_code,
-- 	Currency_Name as channel,
-- 	'[dbo].[FACT_CRM_Sales]' as source,
-- 	'CRM_Sales' as kpi,
-- 	SUM(Sales_Vat) aS kvalue,
-- 	CURRENT_TIMESTAMP AS [insert_timestamp],
-- 	@dt as dt
-- from dbo.FACT_CRM_Sales
-- where Date_Key = @dt
-- group by Date_Key,
-- 		Store_Code,
-- 	Currency_Name

-- UNION ALL
-- DECLARE @dt varchar(10) = '2022-04-10'
select 
    convert(varchar(10), insert_timestamp, 112) as date_id
    ,'' as store_code
    ,card_type_name as channel
    ,'[DW_CRM].[DIM_CRM_Account_SCD]' as source
    ,'CRM_Account' as kpi
    ,count(account_number) AS kvalue
    ,CURRENT_TIMESTAMP AS [insert_timestamp]
    ,@dt as dt
from DW_CRM.DIM_CRM_Account_SCD 
where cast(insert_timestamp as date) = @dt
group by convert(varchar(10), insert_timestamp, 112)
        ,card_type_name

union all

SELECT
    format(register_time, 'yyyyMMdd') as date_id
    ,card_source as store_code
    ,card_level as channel
    ,'[DW_User].[DWS_User_Info]' as source
    ,'User_Cnt' as kpi
    ,count(1) as kvalue
    ,CURRENT_TIMESTAMP AS [insert_timestamp]
    ,@dt AS dt
  FROM [DW_User].[DWS_User_Info]
  where format(register_time, 'yyyy-MM-dd') = @dt
  group by format(register_time, 'yyyyMMdd')
      ,[card_source]
      ,[card_level]

-- SELECT [Time_ID] as date_id,
-- 	[Store_ID] as store_code,
-- 	[Currency_Code] as channel,
-- 	'[IRIS].[Fact_Ticket_Current]' as source,
-- 	'Iris_Sales' as kpi,
-- 	SUM([Sales_VAT]) aS kvalue,
-- 	CURRENT_TIMESTAMP AS [insert_timestamp],
-- 	@dt as dt
-- FROM [IRIS].[Fact_Ticket_Current]
-- WHERE [Time_ID] = @dt
-- GROUP BY  [Time_ID],
-- 		[Store_ID],
-- 		[Currency_Code]

-- union all

-- SELECT 
-- 	  a.Creation_Date as date_id
-- 	  ,b.Store_ID as store_code
-- 	  ,a.Ord_Currency_Code as channel
--       ,'[IRIS].[Fact_Order]' as source
--       ,'IRIS_Order' as kpi
--       ,cast(SUM(a.Ordered_Amount) as varchar) AS kvalue
-- 	  ,CURRENT_TIMESTAMP AS [insert_timestamp]
-- 	  ,@dt as dt
-- FROM [IRIS].[Fact_Order] a
-- LEFT JOIN [IRIS].[Fact_Ticket_Current] b on a.Order_Number = b.Order_Number
-- WHERE a.Creation_Date = @dt
-- GROUP BY a.Creation_Date,b.Store_ID,a.Ord_Currency_Code

-- set @dt = convert(nvarchar(10),dateadd(day, 1, @dt), 112)
-- set @end_date = convert(nvarchar(10),dateadd(day ,1, @dt), 112)

-- end

end
GO
