/****** Object:  StoredProcedure [ODS_OrderCenter].[IMP_Offline_Orders]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OrderCenter].[IMP_Offline_Orders] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OrderCenter.Offline_Orders where dt = @dt;
insert into ODS_OrderCenter.Offline_Orders
select 
    a.id,
	card_no,
	store_code,
	store_name,
	ticket_number,
	purchase_time,
	total_quantity,
	total_amount,
	discount_amount,
	actual_amount,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_OrderCenter.Offline_Orders where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_OrderCenter.WRK_Offline_Orders
) b
on a.id = b.id
where b.id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OrderCenter.WRK_Offline_Orders;
delete from ODS_OrderCenter.Offline_Orders where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
