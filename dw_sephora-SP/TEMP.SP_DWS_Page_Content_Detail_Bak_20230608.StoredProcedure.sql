/****** Object:  StoredProcedure [TEMP].[SP_DWS_Page_Content_Detail_Bak_20230608]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DWS_Page_Content_Detail_Bak_20230608] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-30       aan            Initial Version
-- ========================================================================================
TRUNCATE TABLE [DW_AEM].[DWS_Page_Content_Detail];
INSERT INTO [DW_AEM].[DWS_Page_Content_Detail]
SELECT 
    -- a.[timeStamp],
    a.[page_path],
    t.[Key],
    t.[Value],
    t.[Type],
    CURRENT_TIMESTAMP AS [insert_timestamp]
    -- @dt AS dt
FROM
    (select *, row_number() over(partition by page_path order by insert_timestamp desc,[timeStamp] desc) rownum from [STG_AEM].[AEM_Page]) a
    CROSS APPLY OPENJSON([content]) AS t
where 
    a.dt = @dt
and a.rownum = 1
END

GO
