/****** Object:  StoredProcedure [ODS_Activity].[IMP_Gift_Event_SKU]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Activity].[IMP_Gift_Event_SKU] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Activity.Gift_Event_SKU where dt = @dt;
insert into ODS_Activity.Gift_Event_SKU
select 
    a.id,
	gift_event_id,
	sku_code,
	sku_id,
	quantity,
	inventory,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
	limit_count,
	offline_event_id,
	channel,
	store_inventory_id,
    step_no,
    @dt as dt
from 
(
    select * from ODS_Activity.Gift_Event_SKU where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_Activity.WRK_Gift_Event_SKU
) b
on a.id = b.id
where b.id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_Activity.WRK_Gift_Event_SKU;
delete from ODS_Activity.Gift_Event_SKU where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
