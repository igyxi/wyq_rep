/****** Object:  StoredProcedure [ODS_OMS].[IMP_Merge_Order_Log ]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [ODS_OMS].[IMP_Merge_Order_Log ] @dt [VARCHAR](10) AS
BEGIN
delete from ODS_OMS.Merge_Order_Log  where dt = @dt;
insert into ODS_OMS.Merge_Order_Log 
select 
    a.merge_order_sys_id,
    purchase_order_number,
    purchase_parent_order_number,
    create_time,
    create_user,
    update_time,
    update_user,
    id_delete,
    @dt as dt
from 
(    
select * from ODS_OMS.Merge_Order_Log where dt = cast(DATEADD(day,-1,convert(date, @dt)) as VARCHAR)
) a
left join 
(select merge_order_sys_id from ODS_OMS.WRK_Merge_Order_Log ) b
on a.merge_order_sys_id = b.merge_order_sys_id
where b.merge_order_sys_id is null
union all
select 
    *, 
    @dt as dt 
from 
    ODS_OMS.WRK_Merge_Order_Log;
delete from ODS_OMS.Merge_Order_Log where dt <= cast(DATEADD(day,-7,convert(date, @dt)) as VARCHAR);
END
GO
