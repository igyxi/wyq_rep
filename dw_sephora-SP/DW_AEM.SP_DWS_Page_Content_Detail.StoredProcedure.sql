/****** Object:  StoredProcedure [DW_AEM].[SP_DWS_Page_Content_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_AEM].[SP_DWS_Page_Content_Detail] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-30       aan            Initial Version
-- 2023-06-02		weichen        update source table
-- ========================================================================================
TRUNCATE TABLE DW_AEM.DWS_Page_Content_Detail
INSERT INTO DW_AEM.DWS_Page_Content_Detail
SELECT 
    a.[page_path],
    t.[Key],
    t.[Value],
    t.[Type],
    CURRENT_TIMESTAMP AS [insert_timestamp]
FROM(
    SELECT 
        e.*, 
        row_number() over(partition by e.page_path order by e.insert_timestamp desc,e.[timeStamp] desc) rownum_page
    FROM(
        SELECT 
            [timeStamp]
            ,[content]
            ,REPLACE(SUBSTRING([file_name], 15, LEN([file_name]) - 13), '_', '/') AS page_path
            ,ROW_NUMBER() OVER(PARTITION BY content, REPLACE(SUBSTRING([file_name], 15, LEN([file_name]) - 13), '_', '/') ORDER BY [insert_timestamp] DESC) AS rownum
            ,current_timestamp AS [insert_timestamp]
            ,@dt as dt
        FROM ODS_AEM.AEM_Page_Detail
        WHERE status = 200
        )e
    WHERE e.rownum = 1
)a
CROSS APPLY OPENJSON([content]) AS t
WHERE 
    a.dt = @dt
and a.rownum_page = 1
END

GO
