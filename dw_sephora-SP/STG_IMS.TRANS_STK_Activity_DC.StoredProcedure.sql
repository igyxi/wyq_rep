/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Activity_DC]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Activity_DC] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Activity_DC;
insert into STG_IMS.STK_Activity_DC
select 
		id,
		activity_id,
		warehouse_id,
		wharetype_id,
		goods_id,
		sku_id,
		case when trim(sku_code) in ('','null','None') then null else trim(sku_code) end as sku_code,
		qty_source,
		qty,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Activity_DC
where dt = @dt
END
GO
