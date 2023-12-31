/****** Object:  StoredProcedure [ODS_Product].[IMP_PROD_SKU_Attrval_REL]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Product].[IMP_PROD_SKU_Attrval_REL] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Product.PROD_SKU_Attrval_REL where dt = @dt;
insert into ODS_Product.PROD_SKU_Attrval_REL
select 
    a.sku_id,
	attr_id,
	attrval_id,
	sequence,
	type,
	create_time,
	update_time,
	create_user,
	update_user,
	is_delete,
    @dt as dt
from 
(
    select * from ODS_Product.PROD_SKU_Attrval_REL where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select sku_id from ODS_Product.WRK_PROD_SKU_Attrval_REL
) b
on a.sku_id = b.sku_id
where b.sku_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_Product.WRK_PROD_SKU_Attrval_REL;
delete from ODS_Product.PROD_SKU_Attrval_REL where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END

GO
