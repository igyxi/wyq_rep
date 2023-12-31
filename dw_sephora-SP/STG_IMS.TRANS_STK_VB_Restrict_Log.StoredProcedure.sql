/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_VB_Restrict_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_VB_Restrict_Log] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_VB_Restrict_Log;
insert into STG_IMS.STK_VB_Restrict_Log
select 
		id,
		case when trim(platform_code) in ('','null','None') then null else trim(platform_code) end as platform_code,
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		case when trim(store_code) in ('','null','None') then null else trim(store_code) end as store_code,
		case when trim(vb_code) in ('','null','None') then null else trim(vb_code) end as vb_code,
		case when trim(operate_type) in ('','null','None') then null else trim(operate_type) end as operate_type,
		qty,
		case when trim(operate_by) in ('','null','None') then null else trim(operate_by) end as operate_by,
		operate_time,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_VB_Restrict_Log
where dt = @dt
END

GO
