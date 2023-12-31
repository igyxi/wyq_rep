/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_SAP_Actual_Inventory]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_SAP_Actual_Inventory] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_SAP_Actual_Inventory  where dt = @dt;
insert into ODS_OMS.OMS_SAP_Actual_Inventory 
select 
    a.oms_sap_actual_inventory_sys_id,
    sku_cod,
    actual_inventory,
    reserve_inventory,
    retention_flag_on_off,
    warehouse_id,
    is_execute,
    create_time,
    update_time,
    inv_filename,
    create_user,
    update_user,
    is_delete,
    @dt as dt
from 
(    
select * from ODS_OMS.OMS_SAP_Actual_Inventory where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(select oms_sap_actual_inventory_sys_id from ODS_OMS.WRK_OMS_SAP_Actual_Inventory ) b
on a.oms_sap_actual_inventory_sys_id = b.oms_sap_actual_inventory_sys_id
where b.oms_sap_actual_inventory_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_SAP_Actual_Inventory;
delete from ODS_OMS.OMS_SAP_Actual_Inventory where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
