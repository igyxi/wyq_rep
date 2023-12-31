/****** Object:  StoredProcedure [ODS_Activity].[IMP_Gift_Event_Receiver]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Activity].[IMP_Gift_Event_Receiver] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Activity.Gift_Event_Receiver where dt = @dt;
insert into ODS_Activity.Gift_Event_Receiver
select 
    a.id,
	user_id,
	gift_event_id,
	create_time,
	update_time,
	channel,
	status,
	create_user,
	update_user,
	is_delete,
	gift_event_sku_id,
	sku_code,
	offline_event_id,
	channel_type,
	promotion_id,
	order_id,
	order_create_time,
	order_update_time,
	store_code,
	gift_type,
    @dt as dt
from 
(
    select * from ODS_Activity.Gift_Event_Receiver where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_Activity.WRK_Gift_Event_Receiver
) b
on a.id = b.id
where b.id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_Activity.WRK_Gift_Event_Receiver;
delete from ODS_Activity.Gift_Event_Receiver where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
