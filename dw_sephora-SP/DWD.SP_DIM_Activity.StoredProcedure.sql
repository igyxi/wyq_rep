/****** Object:  StoredProcedure [DWD].[SP_DIM_Activity]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DWD].[SP_DIM_Activity] AS
begin
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-04-17       houshuangqiang           Initial Version
-- ========================================================================================
truncate table DWD.DIM_Activity
insert  into DWD.DIM_Activity
select	activity.id
		,activity.activity_code
		,activity.activity_name
		,activity.activity_type
		,activity.platform as channel_code
		,activity.shop_code as sub_channel_code
		,activity.bill_no
		,ware.code as warehouse_code
		,ware.name as warehouse_name
		,storehouse.code as storehouse_code
		,storehouse.name as storehouse_name
		--,detail.sku_code
		,detail.qty_source as warehouse_qty_source
		,detail.qty as warehouse_qty
		,goods.sku_code
		,goods.qty
		,activity.status as activity_status
		,activity.activity_start
		,activity.activity_end
		,activity.pretest_time
		,activity.remark
		,activity.create_time
		,activity.modify_time
		,current_timestamp as insert_timestamp
from 	ODS_IMS.STK_Activity activity
left 	join ODS_IMS.STK_Activity_DC detail
on 		activity.id = detail.activity_id
left 	join ODS_IMS.STK_Activity_DC goods
on 		activity.id = goods.activity_id
left 	join ODS_OIMS_Support.Bas_Warehouse ware
on 		detail.warehouse_id = ware.id
left 	join ODS_IMS.BAS_Storehouse storehouse
on 		detail.wharetype_id = storehouse.id
--left 	join DWD.DIM_SKU_Info sku
--on 		goods.sku_code = sku.sku_code
;
END

GO
