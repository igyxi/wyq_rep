/****** Object:  StoredProcedure [STG_IMS].[TRANS_STK_Stock_Account]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_IMS].[TRANS_STK_Stock_Account] @dt [VARCHAR](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_IMS.STK_Stock_Account;
insert into STG_IMS.STK_Stock_Account
select 
		case when trim(id) in ('','null','None') then null else trim(id) end as id,
		warehouse_id,
		wharetype_id,
		goods_id,
		singleproduct_id,
		qty,
		qty_lock,
		qty_tran,
		create_time,
		case when trim(create_by) in ('','null','None') then null else trim(create_by) end as create_by,
		modify_time,
		case when trim(modify_by) in ('','null','None') then null else trim(modify_by) end as modify_by,
		before_qty,
		before_qty_lock,
		before_qty_tran,
		case when trim(remark) in ('','null','None') then null else trim(remark) end as remark,
		case when trim(barcode) in ('','null','None') then null else trim(barcode) end as barcode,
		qty_hold,
		case when trim(qty_hold_flag) in ('','null','None') then null else trim(qty_hold_flag) end as qty_hold_flag,
		qty_loss,
		current_timestamp as insert_timestamp
from  ODS_IMS.STK_Stock_Account
where dt = @dt
END
GO
