/****** Object:  StoredProcedure [DW_AEM].[SP_RPT_AEM_Page_SKU_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_AEM].[SP_RPT_AEM_Page_SKU_Detail] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-30       aan            Initial Version
-- ========================================================================================
    IF OBJECT_ID('tempdb..#pageSku') IS NOT NULL
    BEGIN
        DROP TABLE #pageSku_detail;
    END;


    SELECT  A.dt,
         B.page_path,
		 A.sku_path,
		 LEN(A.sku_path) - LEN(replace(A.sku_path,'.','')) as [level],
		 B.sephora_page_id,
		 A.sku_code,
		 C.sephora_parent_id,
		 D.pageTitle,
		 getdate() as insert_time_Stamp
   INTO #pageSku_detail
   FROM
    (
        SELECT [timeStamp],
		dt,
               CONCAT('$."children".', [key]) AS sku_path,
               CAST([value] AS NVARCHAR(200)) AS sku_code
        FROM [DW_AEM].[AEM_SKU_Detail]
        WHERE LOWER([key]) LIKE '%code%'
              AND LOWER([key]) NOT LIKE '%alter%'
    ) A
    INNER JOIN
    (
        SELECT [timeStamp],
                page_path,
                CAST([value] AS NVARCHAR(200)) AS sephora_page_id
        FROM [DW_AEM].[AEM_Content_Detail]
        WHERE [key] = '$sephora-page-id'
    ) B
        ON A.[timeStamp] = B.[timeStamp]
	INNER JOIN
	(
    SELECT 
            [timeStamp],
            page_path,
            CAST([value] AS NVARCHAR(200)) AS sephora_parent_id
    FROM [DW_AEM].[AEM_Content_Detail]
    WHERE [key] = '$sephora-parent-id'
    ) C
	ON A.[timeStamp] = C.[timeStamp]
	INNER JOIN
	(
    SELECT 
            [timeStamp],
            page_path,
            CAST([value] AS NVARCHAR(200)) AS pageTitle
    FROM [DW_AEM].[AEM_Content_Detail]
    WHERE [key] = 'pageTitle'
    ) D
	ON A.[timeStamp] = D.[timeStamp]
			;

    TRUNCATE TABLE [DW_AEM].[RPT_AEM_Page_SKU_Detail];

    INSERT INTO [DW_AEM].[RPT_AEM_Page_SKU_Detail]
    SELECT *
    FROM #pageSku_detail;
	DROP TABLE #pageSku_detail
END;
GO
