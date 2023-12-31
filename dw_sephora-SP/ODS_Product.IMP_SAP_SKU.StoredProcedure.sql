/****** Object:  StoredProcedure [ODS_Product].[IMP_SAP_SKU]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_Product].[IMP_SAP_SKU] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_Product.SAP_SKU where dt = @dt;
insert into ODS_Product.SAP_SKU
select 
    a.id,
	sku_code,
	sku_name,
	brand,
	sap_price,
	sap_desc,
	barcode,
	taxrate,
	weight,
	status,
	create_time,
	value,
	update_time,
	create_user,
	update_user,
	is_delete,
	country,
    @dt as dt
from 
(
    select * from ODS_Product.SAP_SKU where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(
    select id from ODS_Product.WRK_SAP_SKU
) b
on a.id = b.id
where b.id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_Product.WRK_SAP_SKU;
delete from ODS_Product.SAP_SKU where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
