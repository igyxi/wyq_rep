/****** Object:  StoredProcedure [STG_Live].[TRANS_Live_Goods_Stats]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Live].[TRANS_Live_Goods_Stats] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-18       wangzhichun           Initial Version
-- ========================================================================================
truncate table STG_Live.Live_Goods_Stats;
insert into STG_Live.Live_Goods_Stats
select 
		id,
		bg_id,
		il_id,
		pv_num,
		uv_num,
		push_screen_num,
		duration,
		updated_at,
		created_at,
		deleted_at,
		current_timestamp as insert_timestamp
from    
(
    select *, row_number() over(partition by id order by dt) rownum from ODS_Live.Live_Goods_Stats
) t
where t.rownum = 1
END
GO
