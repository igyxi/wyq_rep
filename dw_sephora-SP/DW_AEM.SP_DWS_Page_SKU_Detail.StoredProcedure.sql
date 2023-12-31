/****** Object:  StoredProcedure [DW_AEM].[SP_DWS_Page_SKU_Detail]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_AEM].[SP_DWS_Page_SKU_Detail] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-30       aan            Initial Version
-- ========================================================================================

TRUNCATE TABLE [DW_AEM].[DWS_Page_SKU_Detail];
INSERT INTO [DW_AEM].[DWS_Page_SKU_Detail]
SELECT 
    -- a.[timeStamp],
    a.page_path,
    CASE
        WHEN level1.[type] < 3 THEN CONCAT('"', level1.[key], '"')
        WHEN level2.[type] < 3 THEN CONCAT('"', level1.[key], '"', '[', level2.[key], ']')
        WHEN level3.[type] < 3 THEN CONCAT('"', level1.[key], '"', '[', level2.[key], ']', '."', level3.[key], '"')
        WHEN level4.[type] < 3 THEN CONCAT('"', level1.[key],'"','[',level2.[key],']','."',level3.[key],'"','[',level4.[key],']')
        WHEN level5.[type] < 3 THEN CONCAT('"',level1.[key],'"','[',level2.[key],']','."',level3.[key],'"','[',level4.[key],']','."',level5.[key],'"')
        WHEN level6.[type] < 3 THEN CONCAT('"',level1.[key],'"','[',level2.[key],']','."',level3.[key],'"','[',level4.[key],']','."',level5.[key],'"','[',level6.[key],']')
        WHEN level7.[type] < 3 THEN CONCAT('"',level1.[key],'"','[',level2.[key],']','."',level3.[key],'"','[',level4.[key],']','."',level5.[key],'"','[',level6.[key],']','."',level7.[key],'"')
        WHEN level8.[type] < 3 THEN CONCAT('"',level1.[key],'"','[',level2.[key],']','."',level3.[key],'"','[',level4.[key],']','."',level5.[key],'"','[',level6.[key],']','."',level7.[key],'"','[',level8.[key],']')
        WHEN level9.[type] < 3 THEN CONCAT('"',level1.[key],'"','[',level2.[key],']','."',level3.[key],'"','[',level4.[key],']','."',level5.[key],'"','[',level6.[key],']','."',level7.[key],'"','[',level8.[key],']','."',level9.[key],'"')
        ELSE CONCAT('"',level1.[key],'"','[',level2.[key],']','."',level3.[key],'"','[',level4.[key],']','."',level5.[key],'"','[',level6.[key],']','."',level7.[key],'"','[',level8.[key],']','."',level9.[key],'"')
    END AS [key],
    CASE
        WHEN level1.[type] < 3 THEN level1.[value]
        WHEN level2.[type] < 3 THEN level2.[value]
        WHEN level3.[type] < 3 THEN level3.[value]
        WHEN level4.[type] < 3 THEN level4.[value]
        WHEN level5.[type] < 3 THEN level5.[value]
        WHEN level6.[type] < 3 THEN level6.[value]
        WHEN level7.[type] < 3 THEN level7.[value]
        WHEN level8.[type] < 3 THEN level8.[value]
        WHEN level9.[type] < 3 THEN level9.[value]
    END AS [value],
    CURRENT_TIMESTAMP AS [insert_timestamp]
FROM 
(
    select * from [DW_AEM].[DWS_Page_Content_Detail] where [type] = 5 AND [value] <> '{}'
)A
OUTER APPLY 
    openjson([value]) level1
OUTER APPLY
    (SELECT * FROM openjson(level1.[value]) WHERE level1.[type] > 3) level2
OUTER APPLY
    (SELECT * FROM openjson(level2.[value]) WHERE level2.[type] > 3) level3
OUTER APPLY
    (SELECT * FROM openjson(level3.[value]) WHERE level3.[type] > 3) level4
OUTER APPLY
    (SELECT * FROM openjson(level4.[value]) WHERE level4.[type] > 3) level5
OUTER APPLY
    (SELECT * FROM openjson(level5.[value]) WHERE level5.[type] > 3) level6
OUTER APPLY
    (SELECT * FROM openjson(level6.[value]) WHERE level6.[type] > 3) level7
OUTER APPLY
    (SELECT * FROM openjson(level7.[value]) WHERE level7.[type] > 3) level8
OUTER APPLY
    (SELECT * FROM openjson(level8.[value]) WHERE level8.[type] > 3) level9
;
END

GO
