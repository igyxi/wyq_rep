/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Inventory_Allocate_Data]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Inventory_Allocate_Data] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Inventory_Allocate_Data  where dt = @dt;
insert into ODS_OMS.OMS_Inventory_Allocate_Data 
select 
    a.oms_inventory_allocate_data_sys_id,
    inventory_type,
    quantity,
    create_time,
    update_time,
    sku,
    field1,
    field2,
    field3,
    field4,
    field5,
    original_quantity,
    create_user,
    update_user,
    is_delete,
    ware_house,
    @dt as dt
from 
(    
select * from ODS_OMS.OMS_Inventory_Allocate_Data where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(select oms_inventory_allocate_data_sys_id from ODS_OMS.WRK_OMS_Inventory_Allocate_Data ) b
on a.oms_inventory_allocate_data_sys_id = b.oms_inventory_allocate_data_sys_id
where b.oms_inventory_allocate_data_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Inventory_Allocate_Data;
delete from ODS_OMS.OMS_Inventory_Allocate_Data where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
