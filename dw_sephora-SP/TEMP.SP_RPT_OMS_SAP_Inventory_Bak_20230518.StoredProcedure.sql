/****** Object:  StoredProcedure [TEMP].[SP_RPT_OMS_SAP_Inventory_Bak_20230518]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [TEMP].[SP_RPT_OMS_SAP_Inventory_Bak_20230518] AS
BEGIN
truncate table DW_OMS.RPT_OMS_SAP_Inventory;
insert into DW_OMS.RPT_OMS_SAP_Inventory
SELECT
    sku_cod as sku_code,
    a.actual_inventory,
    a.reserve_inventory,
    a.warehouse_id,
    0 as sys_quantity,
    0 as dragon_quantity,
    isnull(c.[quantity],0) as tm_quantity,
    isnull(c.[original_quantity],0) as tm_original_quantity,
    isnull(d.[quantity],0) as jd_quantity,
    isnull(d.[original_quantity],0) as jd_original_quantity,
    0 as rb_quantity,
    0 as rb_original_quantity,
    isnull(e.[quantity],0) as dy_quantity,
    isnull(e.[original_quantity],0) as dy_original_quantity,
    a.[actual_inventory] - isnull(c.[quantity],0) - isnull(d.[quantity],0) - isnull(e.[quantity],0) as available_quantity,
    current_timestamp as insert_timestamp
FROM 
    STG_OMS.OMS_SAP_Actual_Inventory a
inner join 
    DWD.DIM_SKU_Info b
on 
    a.sku_cod = b.sku_code
left join 
    STG_OMS.OMS_Inventory_Allocate_Data c
on 
    c.sku = a.sku_cod
and 
    c.update_time > a.update_time
and 
    c.ware_house = a.warehouse_id
and 
    c.inventory_type = 'TMALL_ALLOCATED'
left join 
    STG_OMS.OMS_Inventory_Allocate_Data d
on  
    d.sku = a.sku_cod
and 
    d.update_time > a.update_time
and 
    d.ware_house = a.warehouse_id
and 
    d.inventory_type = 'JD_ALLOCATED'
left join 
    STG_OMS.OMS_Inventory_Allocate_Data e
on  
    e.sku = a.sku_cod
and 
    e.update_time > a.update_time
and 
    e.ware_house = a.warehouse_id
and 
    e.inventory_type = 'DOUYIN_ALLOCATED'
where isnull(a.is_delete,0) <> 1
;
END
GO
