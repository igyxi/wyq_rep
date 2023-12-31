/****** Object:  StoredProcedure [ODS_ShopCart].[IMP_Cart_Flow]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_ShopCart].[IMP_Cart_Flow] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_ShopCart.Cart_Flow where dt = @dt;
insert into ODS_ShopCart.Cart_Flow
select 
    a.id,
	user_id,
	sku_id,
	change_num,
	channel,
	type,
	store,
	cart_type,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_ShopCart.Cart_Flow where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_ShopCart.WRK_Cart_Flow
) b
on a.id = b.id
where b.id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_ShopCart.WRK_Cart_Flow;
delete from ODS_ShopCart.Cart_Flow where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
