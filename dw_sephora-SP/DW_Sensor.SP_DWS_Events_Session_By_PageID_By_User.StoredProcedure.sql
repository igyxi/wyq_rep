/****** Object:  StoredProcedure [DW_Sensor].[SP_DWS_Events_Session_By_PageID_By_User]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Sensor].[SP_DWS_Events_Session_By_PageID_By_User] @dt [VARCHAR](10) AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-04-14       wangzhichun        Initial Version
-- ========================================================================================
DELETE FROM [DW_Sensor].[DWS_Events_Session_By_PageID_By_User] WHERE left(DATE, 7) = left(@dt, 7)
INSERT INTO [DW_Sensor].[DWS_Events_Session_By_PageID_By_User]
SELECT
	full_table.DATE,
	full_table.platform_type,
	full_table.system_type,
	full_table.user_id,
	CASE 
		WHEN len(full_table.Page_id) >= 5 THEN full_table.Page_id
		ELSE '' 
		END AS Page_id,
	CASE 
		WHEN len(full_table.pageid_wo_prefix) >= 5 THEN full_table.pageid_wo_prefix COLLATE SQL_Latin1_General_CP1_CI_AS
		WHEN PATINDEX('%[0-9]%', full_table.H5_page_id) > PATINDEX('%[^0-9]%', full_table.H5_page_id) THEN full_table.H5_page_id
		ELSE '' 
		END AS pageid_wo_prefix,
	count(DISTINCT full_table.sessionid) AS [session],
	current_timestamp as insert_timestamp
FROM 
	[DW_Sensor].[DWS_Events_Session_Cutby30m] full_table
WHERE left(DATE, 7) = left(@dt, 7)											--date='2022-03-01' and user_id='3300772229557060839'
AND event IN ('$MPViewScreen','$AppViewScreen','$pageview')
GROUP BY 
	full_table.DATE,
	full_table.platform_Type,
	full_table.system_type,
	full_table.user_id,
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
