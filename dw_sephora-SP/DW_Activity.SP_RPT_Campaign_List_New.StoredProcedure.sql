/****** Object:  StoredProcedure [DW_Activity].[SP_RPT_Campaign_List_New]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [DW_Activity].[SP_RPT_Campaign_List_New] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-09-22       wangzhichun        sku update
-- 2023-02-28       houshuangqiang     Change source_table
-- 2023-03-03       houshuangqiang     Change logic
-- ========================================================================================
truncate table DW_Activity.RPT_Campaign_List_New;
insert into DW_Activity.RPT_Campaign_List_New
select  gift.event_id as campaign_id
		,gift.event_name as campaign_name
		,case when gift.event_type = 1 then 'MGM'
			 when gift.event_type = 0 then 'paid sampling'
		end as campaign_type
		,gift.limit_count as sampling_qty
		,sku.eb_brand_name as brand
		,gift.channel as channel
		,format(gift.start_time, 'yyyy-MM-dd') as start_date
		,format(gift.end_time, 'yyyy-MM-dd') as end_date
		,null as gwp_focus_type
		,case when gift.sku_code = 'null' then null else sku.sku_code end as material_code
		,gift.create_time
		,current_timestamp as insert_timestamp
from	DWD.DIM_Gift_Event gift
left 	join DWD.DIM_SKU_Info sku
on 		gift.sku_code = sku.sku_code
END
GO
