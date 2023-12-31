/****** Object:  StoredProcedure [DW_Common].[SP_DIM_STORE]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Common].[SP_DIM_STORE] AS
 BEGIN
--    DECLARE @Date DATE
--	DECLARE @Month NVARCHAR(6)
--	DECLARE @Start_Date NVARCHAR(10)
--	DECLARE @End_Date NVARCHAR(10)
--	DECLARE @POS_Start_Date NVARCHAR(10)
--	DECLARE @POS_End_Date NVARCHAR(10)
--	DECLARE @load_Time DATETIME
--	SET @load_Time=GETDATE()
--	SET @Date= CASE WHEN  @Day ='' THEN GETDATE()-1 ELSE CAST(@Day as date) END
--	------月份
--	SET @Month= CONVERT(NVARCHAR(6),DATEADD(MONTH, DATEDIFF(MONTH, 0, cast(@Date as datetime)), 0),112)
--	------当月第一天
--	SET @Start_date= CONVERT(NVARCHAR(8),DATEADD(MONTH, DATEDIFF(MONTH, 0, cast(@Date as datetime)), 0),112)
--	------当月最后一天
--	SET @End_date= CONVERT(NVARCHAR(8),DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, 1,@Date)), 0),112)
--	------上月第一天
--	SET @POS_Start_Date=  CONVERT(NVARCHAR(10),DATEADD(MONTH, DATEDIFF(MONTH, 0, cast(@Date as datetime)-30), 0),112)
--	------一年后日期，因为OMS 到 SAP有跨月，把这个时间范围放宽，可以刷新历史数据
--	SET @POS_End_Date=   CONVERT(NVARCHAR(10),DATEADD(MONTH, DATEDIFF(MONTH, 0, DATEADD(MONTH, 1, cast(@Date as datetime)+365)), -1),112)
--	--SELECT @Start_date,@End_date,@POS_Start_Date,@POS_End_Date
--select top 1* from [DW_Common].[FACT_ORDER]
DELETE FROM [DW_Common].[DIM_Store] 
INSERT INTO [DW_Common].[DIM_Store]
SELECT sap_Store.[ID]
      ,sap_Store.[Store_Code]
      ,sap_Store.[Store]
      ,sap_Store.[Network_Code]
      ,sap_Store.[Network]
      ,sap_Store.[Sales_Area_Code]
      ,sap_Store.[Sales_Area]
      ,sap_Store.[Company_Code]
      ,sap_Store.[Company]
      ,sap_Store.[Country_Code]
      ,sap_Store.[Country]
      ,sap_Store.[Long_Store_Code]
      ,sap_Store.[Opening_Date]
      ,sap_Store.[Closing_Date]
      ,sap_Store.[Store_Type]
      ,sap_Store.[Sales_Surface]
      ,sap_Store.[Area_Unit]
      ,sap_Store.[Block_Reason]
      ,sap_Store.[Block_Start_Date]
      ,sap_Store.[Block_End_Date]
      ,sap_Store.[City]
      ,sap_Store.[Postal_Code]
      ,sap_Store.[Street]
      ,sap_Store.[Geographical_Area]
	  ,[store_id] AS CRM_store_id
      ,[store_name] AS CRM_store_name
      ,[region] AS CRM_region
      ,[subregion] AS CRM_subregion
      ,[area] AS CRM_area
      ,[district] AS CRM_district
      ,[province] AS CRM_province
      ,[open_date] AS CRM_open_date
      ,[close_date] AS CRM_close_date
      ,[city_id] AS CRM_city_id
      ,[country_id] AS CRM_country_id
      ,[store_channel_id] AS CRM_store_channel_id
      ,[is_comparable_store] AS CRM_is_comparable_store
      ,[store_name_en] AS CRM_store_name_en
      ,[city_tiers] AS CRM_city_tiers
      ,[geography_city_tier] AS CRM_geography_city_tier
      ,[store_ABC_1] AS CRM_store_ABC_1
      ,[distribution_channel_2] AS CRM_distribution_channel_2
      ,[qualify_the_offer] AS CRM_qualify_the_offer
      ,[geography] AS CRM_geography
      ,[atypical] AS CRM_atypical
      ,[street_access] AS CRM_street_access
      ,[social_status] AS CRM_social_status
      ,[customers] AS CRM_customers
      ,[competition] AS CRM_competition
      ,[neighboring_anchor] AS CRM_neighboring_anchor
	  ,crm_store.[sales_surface] AS CRM_sales_surface
      ,[VAT] AS CRM_VAT
      ,[reserved1] AS CRM_reserved1
      ,[reserved2] AS CRM_reserved2
	  ,[store_code_crm] AS CRM_store_code_crm
	  ,[is_eb_store] AS CRM_is_eb_store
  FROM [ODS_SAP].[Dim_Store] sap_Store
  LEFT JOIN [STG_CRM].[DimStore] crm_store  on sap_Store.Store_Code=crm_store.Store_Code
  WHERE sap_Store.Country_Code='CN'
   

 END
GO
