/****** Object:  StoredProcedure [TEMP].[SP_DW_Page_Content_Detail]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DW_Page_Content_Detail] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-30       aan            Initial Version
-- 2023-05-24       tali           change to ods
-- ========================================================================================
TRUNCATE TABLE [DW_AEM].[DW_Page_Content_Detail];

with AEM_Page as
(
    SELECT 
        [timeStamp]
        ,[content]
        ,page_path
    FROM 
    (
        SELECT 
            [timeStamp]
            ,[content]
            ,REPLACE(SUBSTRING([file_name], 15, LEN([file_name]) - 13), '_', '/') AS page_path
            ,ROW_NUMBER() OVER(PARTITION BY [content], REPLACE(SUBSTRING([file_name], 15, LEN([file_name]) - 13), '_', '/') ORDER BY dt DESC) AS rownum
        FROM 
            [ODS_AEM].[AEM_Page_Detail]
        WHERE 
            status = 200
    ) t
    WHERE rownum = 1
)

INSERT INTO [DW_AEM].[DW_Page_Content_Detail]
SELECT
    a.[page_path],
    t.[Key],
    t.[Value],
    t.[Type],
    CURRENT_TIMESTAMP AS [insert_timestamp]
FROM
    (select *, row_number() over(partition by page_path order by [timeStamp] desc) rownum from AEM_Page )a
CROSS APPLY OPENJSON([content]) AS t
where
    a.rownum = 1
END

GO
