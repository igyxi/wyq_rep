/****** Object:  StoredProcedure [DW_AEM].[SP_RPT_Page_SKU_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_AEM].[SP_RPT_Page_SKU_Detail] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-30       aan            Initial Version
-- ========================================================================================
TRUNCATE TABLE [DW_AEM].[RPT_Page_SKU_Detail];
INSERT INTO [DW_AEM].[RPT_Page_SKU_Detail]
SELECT  
    -- A.dt,
    B.page_path,
    A.sku_path,
    LEN(A.sku_path) - LEN(replace(A.sku_path,'.','')) as [level],
    A.sku_code,
    B.sephora_page_id,
    C.sephora_parent_id,
    D.pageTitle,
    CURRENT_TIMESTAMP as insert_timestamp
FROM
(
    SELECT
        page_path,
        CONCAT('$."children".', [key]) AS sku_path,
        CAST([value] AS NVARCHAR(200)) AS sku_code
    FROM 
        [DW_AEM].[DWS_Page_SKU_Detail]
    WHERE 
        LOWER([key]) LIKE '%code%'
        AND LOWER([key]) NOT LIKE '%alter%'
) A
INNER JOIN
(
    SELECT 
        page_path,
        CAST([value] AS NVARCHAR(200)) AS sephora_page_id
    FROM 
        [DW_AEM].[DWS_Page_Content_Detail]
    WHERE 
        [key] = '$sephora-page-id'
) B
ON A.[page_path] = B.[page_path]
INNER JOIN
(
    SELECT 
        page_path,
        CAST([value] AS NVARCHAR(200)) AS sephora_parent_id
    FROM 
        [DW_AEM].[DWS_Page_Content_Detail]
    WHERE 
        [key] = '$sephora-parent-id'
) C
ON A.[page_path] = C.[page_path]
INNER JOIN
(
    SELECT 
        page_path,
        CAST([value] AS NVARCHAR(200)) AS pageTitle
    FROM 
        [DW_AEM].[DWS_Page_Content_Detail]
    WHERE 
        [key] = 'pageTitle'
) D
ON A.[page_path] = D.[page_path];
END

GO
