/****** Object:  StoredProcedure [ODS_User].[IMP_Card]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_User].[IMP_Card] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_User.Card where dt = @dt;
insert into ODS_User.Card
select 
    a.card_no,
	level,
	status,
	source,
	store_id,
	available_points,
	pink_upgrade_time,
	white_upgrade_time,
	black_upgrade_time,
	gold_upgrade_time,
	total_sales_points,
	join_time,
	bind_time,
	update_time,
	create_time,
	last_online_update_time,
	last_offline_update_time,
	purchaseTimes,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_User.Card where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select card_no from ODS_User.WRK_Card
) b
on a.card_no = b.card_no
where b.card_no is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_User.WRK_Card;
delete from ODS_User.Card where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
