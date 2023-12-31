/****** Object:  StoredProcedure [ODS_Order].[IMP_Order_Promotion]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Order].[IMP_Order_Promotion] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Order.Order_Promotion where dt = @dt;
insert into ODS_Order.Order_Promotion
select 
    a.id,
	order_id,
	promotion_id,
	coupon_code,
	coupon_type,
	create_time,
	version,
	sku_id,
	offer_id,
	promotion_adjustment,
	promotion_content,
	promotion_name,
	origin,
	crm_coupon_code,
	px_coupon_id,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_Order.Order_Promotion where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_Order.WRK_Order_Promotion
) b
on a.id = b.id
where b.id is null
union all
select 
    *,
    @dt as dt
from 
    ODS_Order.WRK_Order_Promotion;
delete from ODS_Order.Order_Promotion where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
