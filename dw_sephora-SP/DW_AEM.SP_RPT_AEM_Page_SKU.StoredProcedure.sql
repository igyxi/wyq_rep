/****** Object:  StoredProcedure [DW_AEM].[SP_RPT_AEM_Page_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_AEM].[SP_RPT_AEM_Page_SKU] @dt [VARCHAR](10) AS
BEGIN

    IF OBJECT_ID('tempdb..#pageSku') IS NOT NULL
    BEGIN
        DROP TABLE #pageSku;
    END;


    SELECT B.page_path,
           A.sku_path,
           B.sephora_page_id,
           A.sku_code
    INTO #pageSku
    FROM
    (
        SELECT [timeStamp],
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
            ON A.[timeStamp] = B.[timeStamp];

    TRUNCATE TABLE [DW_AEM].[RPT_AEM_Page_SKU];

    INSERT INTO [DW_AEM].[RPT_AEM_Page_SKU]
    SELECT *
    FROM #pageSku;

END;
GO
