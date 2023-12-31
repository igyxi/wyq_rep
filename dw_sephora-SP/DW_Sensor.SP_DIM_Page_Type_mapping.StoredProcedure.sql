/****** Object:  StoredProcedure [DW_Sensor].[SP_DIM_Page_Type_mapping]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DIM_Page_Type_mapping] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-06-30       aan            Initial Version
-- ========================================================================================
truncate table [DW_Sensor].DIM_Page_Type_mapping;
insert into [DW_Sensor].DIM_Page_Type_mapping
select 
    [page_id],
    [description],
    [page_type],
    'Manual Upload' as source,
    current_timestamp as [insert_timestamp]
FROM 
    [STG_Sensor].[Sensor_PageType_Categorization]
union all
select distinct 
    b.sephora_page_id,
    b.pageTitle,
    'Campaign',
    'AEM',
    current_timestamp as insert_timestamp 
from 
(
    SELECT 
        page_path,
        max(case when [key] = '$sephora-page-id' then CAST([value] AS NVARCHAR(200)) end) AS sephora_page_id,
        max(case when [key] = 'pageTitle' then CAST([value] AS NVARCHAR(200)) end) AS pageTitle
    FROM 
        [DW_AEM].[DWS_Page_Content_Detail]
    WHERE 
        [key] in ('$sephora-page-id' , 'pageTitle')
    group by 
        page_path
) b;
END


GO
