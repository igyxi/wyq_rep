/****** Object:  StoredProcedure [DW_AEM].[SP_AEM_Content_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_AEM].[SP_AEM_Content_Detail] @dt [VARCHAR](10) AS
BEGIN

    IF OBJECT_ID('tempdb..#tbl') IS NOT NULL
    BEGIN
        DROP TABLE #tbl;
    END;

    CREATE TABLE #tbl
    WITH (DISTRIBUTION=ROUND_ROBIN, HEAP) AS SELECT ROW_NUMBER() OVER (ORDER BY a.[timeStamp] DESC) AS idx,
                                                    a.[timeStamp],
                                                    a.[content],
                                                    a.[page_path]
                                             --CASE WHEN a.timeStamp = b.timeStamp THEN 0 ELSE 1 END AS Upflag
                                             FROM [STG_AEM].[AEM_Page] a
                                                 LEFT JOIN
                                                 (
                                                     SELECT DISTINCT --[timeStamp], 
                                                            [page_path]
                                                     FROM [DW_AEM].[AEM_Content_Detail]
                                                 ) b
                                                     ON a.[page_path] = b.[page_path]
                                             --AND a.[timeStamp] = b.[timeStamp]
                                             WHERE a.dt = @dt
                                                   AND b.[page_path] IS NULL;

    DECLARE @nbr_statements INT =
            (
                SELECT COUNT(*) FROM #tbl
            ),
            @i INT = 1;

    DELETE FROM [DW_AEM].[AEM_Content_Detail]
    WHERE dt = @dt;
    --AND page_path = (SELECT DISTINCT [page_path] FROM #tbl);

    WHILE @i <= @nbr_statements
    BEGIN
        DECLARE @sql_code NVARCHAR(MAX) =
                (
                    SELECT [content] FROM #tbl WHERE idx = @i
                );
        INSERT INTO [DW_AEM].[AEM_Content_Detail]
        SELECT a.[timeStamp],
               a.[page_path],
               t.[Key],
               t.[Value],
               t.[Type],
               CURRENT_TIMESTAMP AS [insert_timestamp],
               @dt AS dt
        FROM #tbl a
            CROSS APPLY OPENJSON(@sql_code) AS t
        WHERE idx = @i;
        SET @i += 1;
    END;

END;
GO
