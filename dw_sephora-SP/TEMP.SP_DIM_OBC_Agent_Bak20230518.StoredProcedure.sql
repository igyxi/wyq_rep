/****** Object:  StoredProcedure [TEMP].[SP_DIM_OBC_Agent_Bak20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_OBC_Agent_Bak20230518] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-11       weichen           Initial Version
-- ========================================================================================
TRUNCATE TABLE DWD.DIM_OBC_Agent;
INSERT INTO DWD.DIM_OBC_Agent
SELECT 
	a.id AS agent_id,
	a.name AS agent_name,
	NULL AS	group_id,
	NULL AS skill_group_id,
	NULL AS skill_group_name,
	t.work_group_id AS work_group_id,
	t.work_group_name as work_group_name,
	a.web_id as tenant_id,
	a.type AS type,
	a.enabled AS is_enabled,
	a.del AS is_deleted,
	current_timestamp AS insert_timestamp
FROM ODS_Transcosmos.Public_USER a
LEFT JOIN(
	SELECT
		a.user_id,
		a.work_group_id,
		a.web_id,
		b.name as work_group_name 
	FROM ODS_Transcosmos.Public_Work_Group_USER  a
	LEFT JOIN ODS_Transcosmos.Public_Work_Group b on a.work_group_id=b.id
	where a.web_id='143'
)t on a.id=t.user_id 
where a.web_id='143'

-------ODS_Transcosmos.Public_Skill_Group会存在多个相同的group_id，暂不确定---------------------

--LEFT JOIN(
--	SELECT 
--		a.user_id,
--		a.group_id,
--		b.id as skill_group_id,
--		b.name as skill_group_name,
--		b.web_id
--	FROM ODS_Transcosmos.Public_User_Group a
--	LEFT JOIN ODS_Transcosmos.Public_Skill_Group  b on a.group_id=b.group_id
--)f on a.id=f.user_id and  and a.web_id=f.web_id
;
END
GO
