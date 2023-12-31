/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Sync_Oplog]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Sync_Oplog] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Sync_Oplog;
insert into STG_IMS.STK_Sync_Oplog
select 
		id,
		case when trim(op_type) in ('','null','None') then null else trim(op_type) end as op_type,
		case when trim(operator) in ('','null','None') then null else trim(operator) end as operator,
		op_time,
		case when trim(op_content) in ('','null','None') then null else trim(op_content) end as op_content,
		case when trim(op_module) in ('','null','None') then null else trim(op_module) end as op_module,
		virtualwarehouse_id,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Sync_Oplog
where dt = @dt
END
GO
