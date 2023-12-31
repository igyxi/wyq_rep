/****** Object:  StoredProcedure [ODS_SmartBA].[IMP_T_Order_Package]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_SmartBA].[IMP_T_Order_Package] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_SmartBA.T_Order_Package where dt = @dt;
insert into ODS_SmartBA.T_Order_Package
select 
    a.id,
    order_code,
    po_code,
    po_amount,
    type,
    express_code,
    express_name,
    shipping_time,
    finish_time,
    tenant_id,
    create_time,
    update_time,
    @dt as dt
from 
(    
select * from ODS_SmartBA.T_Order_Package where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(select id from ODS_SmartBA.WRK_T_Order_Package) b
on a.id = b.id
where b.id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_SmartBA.WRK_T_Order_Package;
delete from ODS_SmartBA.T_Order_Package where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
