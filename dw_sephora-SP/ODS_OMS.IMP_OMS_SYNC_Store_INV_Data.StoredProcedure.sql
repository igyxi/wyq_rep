/****** Object:  StoredProcedure [ODS_OMS].[IMP_OMS_SYNC_Store_INV_Data]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_OMS_SYNC_Store_INV_Data] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.OMS_SYNC_Store_INV_Data  where dt = @dt;
insert into ODS_OMS.OMS_SYNC_Store_INV_Data 
select 
    a.oms_sync_store_inv_data_sys_id,
    sku,
    create_time,
    update_time,
    create_user,
    update_user,
    is_delete,
    soa_qty,
    jd_qty,
    tmall_qty,
    redbook_qty,
    tmall_wei_qty,
    douyin_qty,
    @dt as dt
from 
(    
select * from ODS_OMS.OMS_SYNC_Store_INV_Data where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(select oms_sync_store_inv_data_sys_id from ODS_OMS.WRK_OMS_SYNC_Store_INV_Data) b
on a.oms_sync_store_inv_data_sys_id = b.oms_sync_store_inv_data_sys_id
where b.oms_sync_store_inv_data_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_OMS_SYNC_Store_INV_Data;
delete from ODS_OMS.OMS_SYNC_Store_INV_Data where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
