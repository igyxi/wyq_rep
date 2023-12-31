/****** Object:  StoredProcedure [TEMP].[SP_DIM_Gift_Event_Bak_20230411]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_DIM_Gift_Event_Bak_20230411] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-03-03       houshuangqiang           Initial Version
-- ========================================================================================
truncate table DWD.DIM_Gift_Event
insert into DWD.DIM_Gift_Event
select 	event.id as event_id
		,event.name as event_name
		,event.event_type
		,event.apply_group
		,event.partner_group
		,event.channel
		,sku.sku_id
		,sku.sku_code
		,sku.sku_name
		,sku.quantity
		,sku.limit_count
		,sku.offline_event_id
		,sku.participate_type
		,event.start_time
		,event.end_time
		,event.apply_count
		,event.per_num
		,event.share_method
		,event.white
		,event.status as event_status
		,event.shelf_status
		,event.gift_finish_status
		,event.create_time
		,event.update_time
		,current_timestamp as insert_timestamp
from 	ODS_Activity.Gift_Event event
left 	join ODS_Activity.Gift_Event_SKU sku
on      event.id = sku.gift_event_id
END

GO
