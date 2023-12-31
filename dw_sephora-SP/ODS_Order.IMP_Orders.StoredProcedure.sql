/****** Object:  StoredProcedure [ODS_Order].[IMP_Orders]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Order].[IMP_Orders] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Order.Orders where dt = @dt;
insert into ODS_Order.Orders
select 
    a.order_id,
	wcs_id,
	total_amount,
	total_adjustment,
	shipping,
	shipping_adjustment,
	total_coupon_adjustment,
	total_promotion_adjustment,
	status,
	oms_member_id,
	user_id,
	pay_method,
	order_type,
	channel,
	warp_part,
	wrap_price,
	comments,
	wcs_type,
	gift_comments,
	address_id,
	invoice_type,
	delivery_info,
	create_time,
	update_time,
	create_user,
	update_user,
	trigger_msg_status,
	expire_time,
	group_name,
	card_no,
	cancel_reason,
	nick_name,
	sub_channel,
	store,
	is_delete,
	invoice_title_id,
	wish_share_id,
    @dt as dt
from 
(
    select * from ODS_Order.Orders where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select order_id from ODS_Order.WRK_Orders
) b
on a.order_id = b.order_id
where b.order_id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_Order.WRK_Orders;
delete from ODS_Order.Orders where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
