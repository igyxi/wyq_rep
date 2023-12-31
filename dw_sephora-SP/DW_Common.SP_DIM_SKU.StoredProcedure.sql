/****** Object:  StoredProcedure [DW_Common].[SP_DIM_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Common].[SP_DIM_SKU] AS
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
DECLARE @ID bigint
DELETE FROM   [DW_Common].[DIM_Product]
INSERT INTO [DW_Common].[DIM_Product]
SELECT 
      a.ID
	  ,a.[Material_Code]
      ,a.[Material_Description]
	  ,a.[Material_Store_Description]
	  --,b.country_key as Country_code
	  --,b.Vendor
   --   ,b.Platform
   --   ,b.Purchase_Status
   --   ,b.Sales_Status
   --   ,b.Currency_Rec_Sel_Price
   --   ,b.Geographical_Area
   --   ,b.Numeric_Distribution
   --   ,b.Local_Market
   --   ,b.Local_Market_Description
	  ,a.[Material_Group]
      ,a.[Material_Hierarchy_Code]
      ,a.[EAN_Code]
      ,a.[Material_Create_Date]
	  ,a.[Brand_Code]
      ,a.[Brand_Description]
	  ,a.[Sub_Brand_Code]
      ,a.[Sub_brand_Description]
      ,a.[Market_Code]
      ,a.[Market_Description]
      ,a.[Market_Sort]
      ,a.[Target_Code]
      ,a.[Target_Description]
	  ,a.[Target_Sort]
      ,a.[Category_Code]
      ,a.[Category_Description]
      ,a.[Category_Sort]
      ,a.[TO_Ex]
      ,a.[Sales_Nature_Code]
      ,a.[Sales_Nature_Description]
      ,a.[Turnsales_Type_Display_Order]
      ,a.[Range_Code]
      ,a.[Range_Description]
      ,a.[Range_Sort]
      ,a.[Nature_Code]
      ,a.[Nature_Description]
      ,a.[Nature_Sort]
      ,a.[Department_Code]
      ,a.[Department_Sort]
      ,a.[Department_Description]
      ,a.[Loading_Group]
      ,a.[Loading_Description]
      ,a.[PCB]
      ,a.[Lock]
      ,a.[Purchase_Classification_Part1]
      ,a.[Purchase_Classification_Part2]
      ,a.[Purchase_Classification_Part3]
      ,a.[Material_Type]
      ,a.[Material_Type_Description]
      ,a.[Material_Function]
      ,a.[Material_Function_Description]
	  ,a.[Sub_Franchise_Code]
      ,a.[Sub_Franchise_Description]
      ,a.[Finish]
      ,a.[Finish_Description]
      ,a.[Container]
      ,a.[Container_Description]
      ,a.[SPF]
      ,a.[SPF_Description]
      ,a.[Skin_type]
      ,a.[Skin_type_Description]
      ,a.[Asso_Category_Code]
      ,a.[Asso_Category_Desc]
      ,a.[Market_Area]
      ,c.[product_id] as CRM_product_id
      ,c.[brand_id] as CRM_brand_id
      ,c.[brand_type_id] as CRM_brand_type_id
      ,c.[brand_type_eb] as CRM_brand_type_eb
	  ,c.[category_id] as CRM_category_id
	  ,c.[product_name] as CRM_product_name
	  ,c.[category_men] as CRM_category_men
	  ,c.[skincare_function] as CRM_skincare_function
	  ,c.[Segment] as CRM_Segment
	  ,c.[Product_Line] as CRM_Product_Line	
	  ,c.[price] as CRM_price
	  ,c.[isoffer] as CRM_isoffer
	  ,d.[sku_Id] as EB_SKU_ID
	  ,d.[sku_type] as EB_sku_type
      ,d.[product_id] as EB_product_id
	  ,d.[brand_id] as EB_brand_id
	  ,d.[product_name] as EB_product_name
	  ,d.[product_name_cn] as  EB_product_name_cn
	  ,d.[sku_name] as EB_sku_name
	  ,d.[sku_name_cn] as EB_sku_name_cn
	  ,d.[brand_name_cn] as EB_brand_name_cn
      ,d.[first_function] as EB_first_function
      ,d.[level1_id] as EB_level1_id
      ,d.[level2_id] as EB_level2_id
      ,d.[level3_id] as EB_level3_id
      ,d.[level1_name] as EB_level1_name
      ,d.[level2_name] as EB_level2_name
      ,d.[level3_name] as EB_level3_name
      ,d.[att_31] as EB_att_31
      ,d.[att_32] as EB_att_32
      ,d.[att_33] as EB_att_33
      ,d.[att_34] as EB_att_34
      ,d.[att_35] as EB_att_35
      ,d.[att_36] as EB_att_36
      ,d.[att_37] as EB_att_37
      ,d.[att_38] as EB_att_38
      ,d.[att_39] as EB_att_39
      ,d.[att_41] as EB_att_41
      ,d.[att_42] as EB_att_42
      ,d.[att_44] as EB_att_44
      ,d.[att_47] as EB_att_47
      ,d.[att_48] as EB_att_48
      ,d.[att_49] as EB_att_49
      ,d.[att_50] as EB_att_50
      ,d.[att_51] as EB_att_51
      ,d.[att_53] as EB_att_53
      ,d.[att_54] as EB_att_54
      ,d.[att_60] as EB_att_60
      ,d.[att_61] as EB_att_61
      ,d.[att_63] as EB_att_63
      ,d.[att_66] as EB_att_66
      ,d.[att_69] as EB_att_69
      ,d.[att_72] as EB_att_72
      ,d.[att_75] as EB_att_75
      ,d.[att_78] as EB_att_78
      ,d.[image] as EB_image
      ,d.[first_publish_time] as EB_first_publish_time
      ,d.[last_publish_time] as EB_last_publish_time
      ,d.[insert_timestamp] as EB_insert_timestamp
	  ,d.[franchise] as EB_franchise
	  ,d.[sale_store] as EB_sale_store
      ,d.[sale_value] as EB_sale_value
      ,d.[segment] as EB_segment
	  ,d.[islimit] as  EB_islimit
      ,d.[issephora] as EB_issephora
      ,d.[isnew] as EB_isnew
      ,d.[isonline] as EB_isonline
      ,d.[ismember] as EB_ismember
      ,d.[isprelaunch] as EB_isprelaunch
      ,d.[isdiscount] as EB_isdiscount
      ,d.[is_default] as EB_is_default
      ,d.[status] as EB_status
	  ,d.[sap_price] as EB_sap_price
	  ,GETDATE() AS INSERT_TIMESTAMP
	  -- INTO [DW_Common].[DIM_Product]
  FROM [ODS_SAP].[Dim_Material] a
--join [ODS_SAP].[Material_Status] b on a.material_code collate Chinese_PRC_CI_AS =b.material
left join  (SELECT *, ROW_NUMBER() over(partition by sku_code order by product_id desc) AS rownum FROM [ODS_CRM].[DimProduct])  c  on a.material_code collate Chinese_PRC_CI_AS =c.sku_code and rownum=1
left join [DW_Product].[DWS_SKU_Profile] d on  a.material_code collate Chinese_PRC_CI_AS =d.sku_cd
--select @ID =max(ID) from [DW_Common].[DIM_Product]
INSERT INTO [DW_Common].[DIM_Product]
SELECT a.ID
      ,a.[Material_Code]
      ,a.[Material_Description]
	  ,a.[Material_Store_Description]
	  --,b.country_key as Country_code
	  --,b.Vendor
   --   ,b.Platform
   --   ,b.Purchase_Status
   --   ,b.Sales_Status
   --   ,b.Currency_Rec_Sel_Price
   --   ,b.Geographical_Area
   --   ,b.Numeric_Distribution
   --   ,b.Local_Market
   --   ,b.Local_Market_Description
	  ,a.[Material_Group]
      ,a.[Material_Hierarchy_Code]
      ,a.[EAN_Code]
      ,a.[Material_Create_Date]
	  ,a.[Brand_Code]
      ,a.[Brand_Description]
	  ,a.[Sub_Brand_Code]
      ,a.[Sub_brand_Description]
      ,a.[Market_Code]
      ,a.[Market_Description]
      ,a.[Market_Sort]
      ,a.[Target_Code]
      ,a.[Target_Description]
	  ,a.[Target_Sort]
      ,a.[Category_Code]
      ,a.[Category_Description]
      ,a.[Category_Sort]
      ,a.[TO_Ex]
      ,a.[Sales_Nature_Code]
      ,a.[Sales_Nature_Description]
      ,a.[Turnsales_Type_Display_Order]
      ,a.[Range_Code]
      ,a.[Range_Description]
      ,a.[Range_Sort]
      ,a.[Nature_Code]
      ,a.[Nature_Description]
      ,a.[Nature_Sort]
      ,a.[Department_Code]
      ,a.[Department_Sort]
      ,a.[Department_Description]
      ,a.[Loading_Group]
      ,a.[Loading_Description]
      ,a.[PCB]
      ,a.[Lock]
      ,a.[Purchase_Classification_Part1]
      ,a.[Purchase_Classification_Part2]
      ,a.[Purchase_Classification_Part3]
      ,a.[Material_Type]
      ,a.[Material_Type_Description]
      ,a.[Material_Function]
      ,a.[Material_Function_Description]
	  ,a.[Sub_Franchise_Code]
      ,a.[Sub_Franchise_Description]
      ,a.[Finish]
      ,a.[Finish_Description]
      ,a.[Container]
      ,a.[Container_Description]
      ,a.[SPF]
      ,a.[SPF_Description]
      ,a.[Skin_type]
      ,a.[Skin_type_Description]
      ,a.[Asso_Category_Code]
      ,a.[Asso_Category_Desc]
      ,a.[Market_Area]
      ,c.[product_id] as CRM_product_id
      ,c.[brand_id] as CRM_brand_id
      ,c.[brand_type_id] as CRM_brand_type_id
      ,c.[brand_type_eb] as CRM_brand_type_eb
	  ,c.[category_id] as CRM_category_id
	  ,c.[product_name] as CRM_product_name
	  ,c.[category_men] as CRM_category_men
	  ,c.[skincare_function] as CRM_skincare_function
	  ,c.[Segment] as CRM_Segment
	  ,c.[Product_Line] as CRM_Product_Line	
	  ,c.[price] as CRM_price
	  ,c.[isoffer] as CRM_isoffer
	  ,d.[sku_Id] as EB_SKU_ID
	  ,d.[sku_type] as EB_sku_type
      ,d.[product_id] as EB_product_id
	  ,d.[brand_id] as EB_brand_id
	  ,d.[product_name] as EB_product_name
	  ,d.[product_name_cn] as  EB_product_name_cn
	  ,d.[sku_name] as EB_sku_name
	  ,d.[sku_name_cn] as EB_sku_name_cn
	  ,d.[brand_name_cn] as EB_brand_name_cn
      ,d.[first_function] as EB_first_function
      ,d.[level1_id] as EB_level1_id
      ,d.[level2_id] as EB_level2_id
      ,d.[level3_id] as EB_level3_id
      ,d.[level1_name] as EB_level1_name
      ,d.[level2_name] as EB_level2_name
      ,d.[level3_name] as EB_level3_name
      ,d.[att_31] as EB_att_31
      ,d.[att_32] as EB_att_32
      ,d.[att_33] as EB_att_33
      ,d.[att_34] as EB_att_34
      ,d.[att_35] as EB_att_35
      ,d.[att_36] as EB_att_36
      ,d.[att_37] as EB_att_37
      ,d.[att_38] as EB_att_38
      ,d.[att_39] as EB_att_39
      ,d.[att_41] as EB_att_41
      ,d.[att_42] as EB_att_42
      ,d.[att_44] as EB_att_44
      ,d.[att_47] as EB_att_47
      ,d.[att_48] as EB_att_48
      ,d.[att_49] as EB_att_49
      ,d.[att_50] as EB_att_50
      ,d.[att_51] as EB_att_51
      ,d.[att_53] as EB_att_53
      ,d.[att_54] as EB_att_54
      ,d.[att_60] as EB_att_60
      ,d.[att_61] as EB_att_61
      ,d.[att_63] as EB_att_63
      ,d.[att_66] as EB_att_66
      ,d.[att_69] as EB_att_69
      ,d.[att_72] as EB_att_72
      ,d.[att_75] as EB_att_75
      ,d.[att_78] as EB_att_78
      ,d.[image] as EB_image
      ,d.[first_publish_time] as EB_first_publish_time
      ,d.[last_publish_time] as EB_last_publish_time
      ,d.[insert_timestamp] as EB_insert_timestamp
	  ,d.[franchise] as EB_franchise
	  ,d.[sale_store] as EB_sale_store
      ,d.[sale_value] as EB_sale_value
      ,d.[segment] as EB_segment
	  ,d.[islimit] as  EB_islimit
      ,d.[issephora] as EB_issephora
      ,d.[isnew] as EB_isnew
      ,d.[isonline] as EB_isonline
      ,d.[ismember] as EB_ismember
      ,d.[isprelaunch] as EB_isprelaunch
      ,d.[isdiscount] as EB_isdiscount
      ,d.[is_default] as EB_is_default
      ,d.[status] as EB_status
	  ,d.[sap_price] as EB_sap_price
	  ,GETDATE() AS INSERT_TIMESTAMP
  FROM  [DW_Product].[DWS_SKU_Profile] d
  LEFT JOIN  [ODS_SAP].[Dim_Material] a on  a.material_code collate Chinese_PRC_CI_AS =d.sku_cd
  --join [ODS_SAP].[Material_Status] b on a.material_code collate Chinese_PRC_CI_AS =b.material
LEFT JOIN (SELECT *, ROW_NUMBER() over(partition by sku_code order by product_id desc) AS rownum FROM [ODS_CRM].[DimProduct])  c  
on a.material_code collate Chinese_PRC_CI_AS =c.sku_code and rownum=1
WHERE 
d.sku_cd collate Chinese_PRC_CI_AS in 
(
    SELECT DISTINCT trim(replace(sku_code,'#','')) 
	FROM [DW_Common].[FACT_ORDER]
	WHERE trim(replace(sku_code,'#','')) not in (
	                                        SELECT DISTINCT material_code   FROM [ODS_SAP].[Dim_Material]
											     )
)


 END
GO
