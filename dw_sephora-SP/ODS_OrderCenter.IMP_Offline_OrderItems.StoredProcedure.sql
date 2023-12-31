/****** Object:  StoredProcedure [ODS_OrderCenter].[IMP_Offline_OrderItems]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OrderCenter].[IMP_Offline_OrderItems] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OrderCenter.Offline_OrderItems where dt = @dt;
insert into ODS_OrderCenter.Offline_OrderItems
select 
    a.id,
	ticket_number,
	product_brand_name_en,
	product_sku_code,
	product_sku_id,
	product_id,
	product_image_url,
	product_name,
	product_size,
	quantity,
	price,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_OrderCenter.Offline_OrderItems where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_OrderCenter.WRK_Offline_OrderItems
) b
on a.id = b.id
where b.id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OrderCenter.WRK_Offline_OrderItems;
delete from ODS_OrderCenter.Offline_OrderItems where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
