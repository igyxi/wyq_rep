/****** Object:  StoredProcedure [DWD].[SP_DIM_GWP_Value]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_GWP_Value] AS
BEGIN

TRUNCATE TABLE [DWD].[DIM_GWP_Value];

INSERT INTO [DWD].[DIM_GWP_Value]
SELECT DISTINCT
    GWP_MAPPING.sku_code,
    GWP_MAPPING.sku_name,
    GWP_MAPPING.sku_spec,
    GWP_MAPPING.unit_name,
    SKU.crm_brand,
    SKU.crm_category,
    SKU.crm_segment,
    SKU.brand,
    SKU.category,
    SKU.segment,
    GWP_VALUE.unit_price,
    GWP_VALUE.gwp_price,
	DATEADD(HOUR,8,GETDATE()) AS insert_time
FROM 
	(SELECT 
		* 
	FROM(
		SELECT  
			* ,ROW_NUMBER() OVER(PARTITION BY sku_code ORDER BY main_sku_score ASC) rownum
		FROM [ODS_Promotion].[ods_gwp_mapping_info_explode])r
	where r.rownum=1
	)AS GWP_MAPPING
JOIN [DWD].[DIM_SKU_Info] AS SKU ON GWP_MAPPING.main_sku_code=SKU.sku_code
JOIN [ODS_Promotion].[olap_gwp_value] AS GWP_VALUE on GWP_MAPPING.sku_code=GWP_VALUE.sku_code
;

END


GO
