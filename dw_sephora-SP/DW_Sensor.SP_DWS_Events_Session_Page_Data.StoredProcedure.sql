/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Events_Session_Page_Data]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Events_Session_Page_Data] @dt [VARCHAR](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-14       wangzhichun        Initial Version
-- 2023-02-20       litao              Modify PV&UV logic
-- ========================================================================================
DELETE FROM [DW_Sensor].[DWS_Events_Session_Page_Data] WHERE left(DATE, 7) = left(@dt, 7)
INSERT INTO [DW_Sensor].[DWS_Events_Session_Page_Data]
SELECT 
    full_table.DATE,
    full_table.platform_Type,
    CASE WHEN len(full_table.Page_id) >= 5 THEN full_table.Page_id ELSE '' END AS page_id,
    --,case when len(full_table.pageid_wo_prefix)>4 then full_table.pageid_wo_prefix else '' end  as pageid_wo_prefix
    --,CASE 
    --    WHEN PATINDEX('%[0-9]%', full_table.H5_page_id) > PATINDEX('%[^0-9]%', full_table.H5_page_id)
    --    THEN full_table.H5_page_id
    --ELSE ''
    --END AS H5_page_id
    CASE 
        WHEN len(full_table.pageid_wo_prefix) >= 5 THEN full_table.pageid_wo_prefix COLLATE SQL_Latin1_General_CP1_CI_AS
        WHEN PATINDEX('%[0-9]%', full_table.H5_page_id) > PATINDEX('%[^0-9]%', full_table.H5_page_id) THEN full_table.H5_page_id
        ELSE '' END AS pageid_wo_prefix,
    --sum(CASE 
    --        WHEN full_table.event IN ('$MPViewScreen','$AppViewScreen','$pageview') AND full_table.platform_type IN ('MINIPROGRAM','APP') THEN 1
    --        WHEN full_table.event IN ('$pageview')AND full_table.platform_type IN ('mobile','PC')THEN 1
    --        ELSE 0
    --        END) AS PV,--原逻辑
    sum(CASE 
            when full_table.aem_page_flag=1  and full_table.event IN ('$pageview') and full_table.platform_type IN ('MINIPROGRAM','APP') then 1
            WHEN full_table.aem_page_flag<>1 and full_table.event IN ('$MPViewScreen','$AppViewScreen','$pageview') AND full_table.platform_type IN ('MINIPROGRAM','APP') THEN 1
            WHEN full_table.event IN ('$pageview')AND full_table.platform_type IN ('mobile','PC')THEN 1
            ELSE 0
            END) AS PV, --AEM页面PV只统计event='$pageview'的记录，其他保持原逻辑
    --count(DISTINCT CASE 
    --                WHEN full_table.event IN ('$MPViewScreen','$AppViewScreen','$pageview')
    --                    AND full_table.platform_type IN ('MINIPROGRAM','APP') THEN full_table.user_id
    --                WHEN full_table.event IN ('$pageview')
    --                    AND full_table.platform_type IN ('mobile','PC')THEN full_table.user_id
    --                END) AS UV,--原逻辑
    count(DISTINCT CASE 
                        when full_table.aem_page_flag=1  and full_table.event IN ('$pageview') and full_table.platform_type IN ('MINIPROGRAM','APP') then full_table.user_id
                        WHEN full_table.aem_page_flag<>1 and full_table.event IN ('$MPViewScreen','$AppViewScreen','$pageview')
                            AND full_table.platform_type IN ('MINIPROGRAM','APP') THEN full_table.user_id
                        WHEN full_table.event IN ('$pageview')
                            AND full_table.platform_type IN ('mobile','PC')THEN full_table.user_id
                        END) AS UV,--AEM页面UV只统计event='$pageview'的记录，其他保持原逻辑
    sum(CASE 
            WHEN full_table.[row_num] = Temp_table.min_row THEN 1
            ELSE 0
            END) AS first_page_session,
    sum(CASE 
            WHEN full_table.[row_num] = Temp_table.max_row THEN 1
            ELSE 0
            END) AS last_Page_session,
    sum(CASE 
            WHEN Temp_table.min_row = Temp_table.max_row THEN 1
            ELSE 0
            END) AS jump_page_session,
    current_timestamp as insert_timestamp
FROM 
   (select 
        DATE,
        platform_Type,
        Page_id,
        pageid_wo_prefix,
        H5_page_id,
        event,
        user_id,
        row_num,
        system_type,
        sessionid,
        case when page_id like 'AEM_%' or page_id like 'MP_AEM_%' then 1 else 0 end as aem_page_flag --增加判断是否为AEM页面逻辑
    from 
      [DW_Sensor].[DWS_Events_Session_Cutby30m]
    WHERE event IN ('$MPViewScreen','$AppViewScreen','$pageview') --条件提前过滤
    AND left(DATE, 7) = left(@dt, 7)                              --条件提前过滤
    ) full_table
LEFT JOIN 
(
    SELECT 
        user_id,
        DATE,
        platform_type,
        system_type,
        sessionid,
        min([row_num]) AS min_row,
        max([row_num]) AS max_row
    FROM 
        [DW_Sensor].[DWS_Events_Session_Cutby30m]
    WHERE left(DATE, 7) = left(@dt, 7)
        --DATE = '2022-03-01'
        --    AND user_id = '3300772229557060839'
        AND event IN ('$MPViewScreen','$AppViewScreen','$pageview')
    --(
    --    (event IN (    '$MPViewScreen'    ,'$AppViewScreen')     AND platform_type IN ('Mini Program','MiniProgram','app','APP'))
    --    or 
    --    ( event IN ('$pageview') AND platform_type IN ('mobile','web'))
    --    )
    GROUP BY
        user_id,
        DATE,
        platform_type,
        system_type,
        sessionid
) Temp_table 
ON full_table.DATE = Temp_table.DATE
    AND isnull(full_table.Platform_Type, '') = isnull(Temp_table.Platform_Type, '')
    AND isnull(full_table.system_type, '') = isnull(Temp_table.system_type, '')
    AND full_table.sessionid = Temp_table.sessionid
    AND isnull(full_table.user_id, '') = isnull(Temp_table.user_id, '')
--WHERE full_table.event IN ('$MPViewScreen','$AppViewScreen','$pageview') --原逻辑
--    AND left(full_table.DATE, 7) = left(@dt, 7) --原逻辑
--full_table.DATE = '2022-03-01'
--AND full_table.user_id = '3300772229557060839'
GROUP BY 
    full_table.DATE,
    full_table.platform_Type,
    CASE 
        WHEN len(full_table.Page_id) >= 5 THEN full_table.Page_id
        ELSE ''
        END,
    CASE 
        WHEN len(full_table.pageid_wo_prefix) >= 5 THEN full_table.pageid_wo_prefix COLLATE SQL_Latin1_General_CP1_CI_AS
        WHEN PATINDEX('%[0-9]%', full_table.H5_page_id) > PATINDEX('%[^0-9]%', full_table.H5_page_id) THEN full_table.H5_page_id
        ELSE ''
        END
    
END
GO
