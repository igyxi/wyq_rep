/****** Object:  StoredProcedure [ODS_Promotion].[IMP_PX_Coupon]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Promotion].[IMP_PX_Coupon] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Promotion.PX_Coupon where dt = @dt;
insert into ODS_Promotion.PX_Coupon
select 
    a.px_coupon_id,
	user_id,
	type,
	code,
	promotion_id,
	promotion_version,
	name,
	effective,
	expire,
	show_time,
	order_id,
	status,
	valid,
	origin,
	priority,
	use_time,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
	coupon_event_id,
	source,
    @dt as dt
from 
(
    select * from ODS_Promotion.PX_Coupon where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select px_coupon_id from ODS_Promotion.WRK_PX_Coupon
) b
on a.px_coupon_id = b.px_coupon_id
where b.px_coupon_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_Promotion.WRK_PX_Coupon;
delete from ODS_Promotion.PX_Coupon where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
