/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_Inventory_Allocate_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_Inventory_Allocate_Log] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_Inventory_Allocate_Log  where dt = @dt;
insert into ODS_OMS.OMS_Inventory_Allocate_Log 
select 
    a.oms_inventory_allocate_log_sys_id,
    operator,
    inventory_type,
    quantity,
    sku,
    original_quantity,
    operation_type,
    warehouse_id,
    sap_inv_snapshot,
    create_time,
    create_user,
    update_time,
    update_user,
    is_delete,
    @dt as dt
from 
(    
select * from ODS_OMS.OMS_Inventory_Allocate_Log where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(select oms_inventory_allocate_log_sys_id from ODS_OMS.WRK_OMS_Inventory_Allocate_Log) b
on a.oms_inventory_allocate_log_sys_id = b.oms_inventory_allocate_log_sys_id
where b.oms_inventory_allocate_log_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_Inventory_Allocate_Log;
delete from ODS_OMS.OMS_Inventory_Allocate_Log where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
