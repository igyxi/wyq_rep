/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Stock_Workflow_Backups]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Stock_Workflow_Backups] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Stock_Workflow_Backups;
insert into STG_IMS.STK_Stock_Workflow_Backups
select 
		id,
		warehouse_id,
		wharetype_id,
		goods_id,
		singleproduct_id,
		case when trim(qty_type) in ('','null','None') then null else trim(qty_type) end as qty_type,
		change_qty,
		remain_qty,
		case when trim(workflow_no) in ('','null','None') then null else trim(workflow_no) end as workflow_no,
		case when trim(bill_no) in ('','null','None') then null else trim(bill_no) end as bill_no,
		case when trim(bill_type) in ('','null','None') then null else trim(bill_type) end as bill_type,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Stock_Workflow_Backups
where dt = @dt
END
GO
