/****** Object:  StoredProcedure [ODS_Activity].[IMP_Gift_Event_Partner]    Script Date: 2023/6/28 11:31:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Activity].[IMP_Gift_Event_Partner] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Activity.Gift_Event_Partner where dt = @dt;
insert into ODS_Activity.Gift_Event_Partner
select 
    a.id,
	gift_event_id,
	sharer_user_id,
	partner_user_id,
	partner_nick_name,
	partner_avatar_url,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_Activity.Gift_Event_Partner where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_Activity.WRK_Gift_Event_Partner
) b
on a.id = b.id
where b.id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_Activity.WRK_Gift_Event_Partner;
delete from ODS_Activity.Gift_Event_Partner where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
