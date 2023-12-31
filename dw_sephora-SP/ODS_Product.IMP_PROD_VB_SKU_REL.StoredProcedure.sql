/****** Object:  StoredProcedure [ODS_Product].[IMP_PROD_VB_SKU_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Product].[IMP_PROD_VB_SKU_REL] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Product.PROD_VB_SKU_REL where dt = @dt;
insert into ODS_Product.PROD_VB_SKU_REL
select 
    a.id,
	vb_sku_id,
	vb_sku_code,
	bind_sku_id,
	bind_sku_code,
	quantity,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_Product.PROD_VB_SKU_REL where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_Product.WRK_PROD_VB_SKU_REL
) b
on a.id = b.id
where b.id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_Product.WRK_PROD_VB_SKU_REL;
delete from ODS_Product.PROD_VB_SKU_REL where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
