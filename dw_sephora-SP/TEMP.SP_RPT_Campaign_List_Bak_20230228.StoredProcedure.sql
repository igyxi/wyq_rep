/****** Object:  StoredProcedure [TEMP].[SP_RPT_Campaign_List_Bak_20230228]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_Campaign_List_Bak_20230228] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-30       wangzhichun        Initial Version
-- 2022-09-22       wangzhichun        sku update
-- ========================================================================================
truncate table DW_Activity.RPT_Campaign_List;
insert into DW_Activity.RPT_Campaign_List
select 
    a.id,
    a.name,
    case when a.event_type = 1 then 'MGM'
        when a.event_type = 0 then 'paid sampling'
    end,
    b.limit_count,
    s.eb_brand_name,
    a.channel,
    cast(a.start_time as date),
    cast(a.end_time as date),
    null,
    case when b.sku_code = 'null' then null else b.sku_code end,
    a.create_time,
    current_timestamp
from 
(select * from [STG_Activity].[Gift_Event]) a
left join
(select * from [STG_Activity].[Gift_Event_SKU]) b
on a.id = b.gift_event_id
left join
    DWD.DIM_SKU_Info s
on b.sku_code = s.sku_code
;
END



GO
