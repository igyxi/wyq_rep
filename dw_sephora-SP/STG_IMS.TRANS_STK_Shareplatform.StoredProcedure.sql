/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Shareplatform]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Shareplatform] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Shareplatform;
insert into STG_IMS.STK_Shareplatform
select 
		id,
		platform_id,
		sharegroupid,
		case when trim(createby) in ('','null','None') then null else trim(createby) end as createby,
		createdate,
		case when trim(modifyby) in ('','null','None') then null else trim(modifyby) end as modifyby,
		modifydate,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Shareplatform
where dt = @dt
END
GO
