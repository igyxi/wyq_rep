/****** Object:  StoredProcedure [STG_Transcosmos].[TRANS_Public_User_Group]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Transcosmos].[TRANS_Public_User_Group] @dt [VARCHAR](10) AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-07-07       wangzhichun        Initial Version
-- ========================================================================================
truncate table [STG_TRANSCOSMOS].[Public_User_Group];
insert into [STG_TRANSCOSMOS].[Public_User_Group]
select 
	id,
	user_id,
	group_id,
	create_user_id,
	create_time,
    current_timestamp as insert_timestamp
from 
    ODS_Transcosmos.Public_User_Group
where 
    dt = @dt;
END
GO
