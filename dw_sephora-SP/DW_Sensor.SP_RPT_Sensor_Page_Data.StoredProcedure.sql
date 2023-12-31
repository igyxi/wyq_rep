/****** Object:  StoredProcedure [DW_Sensor].[SP_RPT_Sensor_Page_Data]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_RPT_Sensor_Page_Data] @dt [VARCHAR](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-14       wangzhichun        Initial Version
-- 2022-11-09       wangzhichun    update PLATFORM_TYPE & PAGE_ID
-- 2023-02-21       litao          add page_id is not null and page_id<>''
-- ========================================================================================
DELETE FROM [DW_Sensor].[RPT_Sensor_Page_Data] WHERE left(DATE, 7) = left(@dt, 7)
INSERT INTO [DW_Sensor].[RPT_Sensor_Page_Data]
SELECT 
    a.DATE,
    case when upper(a.platform_type) = 'MINIPROGRAM' then 'MNP'
        else a.platform_Type
        end as PLATFORM_TYPE,  
    isnull(a.pageid_wo_prefix, '') AS PAGE_ID,
    isnull(c.description, '') AS description,
    CASE WHEN isnull(a.pageid_wo_prefix, '') <> '' THEN isnull(c.page_type, 'Campaign') ELSE '' END AS page_type,
    sum(a.PV) AS PV,
    sum(a.UV) AS UV,
    sum(b.session) AS session,
    sum(a.first_page_session) AS first_page_session,
    sum(a.last_Page_session) AS last_Page_session,
    sum(a.jump_page_session) AS jump_page_session,
    current_timestamp as insert_timestamp
FROM 
    [DW_Sensor].[DWS_Events_Session_Page_Data] a
LEFT JOIN
(
    SELECT 
        DATE,
        platform_type,
        isnull(pageid_wo_prefix, '') AS pageid_wo_prefix,
        sum(session) AS session
    FROM 
        [DW_Sensor].[DWS_Events_Session_By_PageID_By_User]
    WHERE left(DATE, 7) = left(@dt, 7)
    GROUP BY
        DATE,
        platform_type,
        isnull(pageid_wo_prefix, '')
) b 
ON a.DATE = b.DATE
    AND isnull(a.platform_type, '') = isnull(b.platform_type, '')
    AND isnull(a.pageid_wo_prefix, '') = isnull(b.pageid_wo_prefix, '')
LEFT JOIN 
    (select 
        page_id,
        description,
        page_type
    from [DW_Sensor].[DIM_Page_Type_Mapping] --page_id存在为null的值导致数据发散
    where 
        page_id is not null
        and page_id<>''
    ) c 
ON isnull(a.pageid_wo_prefix, '') = isnull(c.page_id, '')
WHERE left(a.DATE, 7) = left(@dt, 7)
GROUP BY a.DATE,
    case when upper(a.platform_type) = 'MINIPROGRAM' then 'MNP'
        else a.platform_Type
        end
    ,isnull(a.pageid_wo_prefix, '')
    ,isnull(c.description, '')
    ,CASE WHEN isnull(a.pageid_wo_prefix, '') <> '' THEN isnull(c.page_type, 'Campaign') ELSE '' END
END
GO
