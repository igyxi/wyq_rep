/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Sharegroup]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Sharegroup] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Sharegroup;
insert into STG_IMS.STK_Sharegroup
select 
		id,
		case when trim(code) in ('','null','None') then null else trim(code) end as code,
		case when trim(createby) in ('','null','None') then null else trim(createby) end as createby,
		createdate,
		case when trim(modifyby) in ('','null','None') then null else trim(modifyby) end as modifyby,
		modifydate,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(name) in ('','null','None') then null else trim(name) end as name,
		status,
		channelid,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Sharegroup
where dt = @dt
END
GO
