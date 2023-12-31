/****** Object:  StoredProcedure [STG_OMS].[TRANS_Merge_Order_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Merge_Order_Log] AS
BEGIN
truncate table STG_OMS.Merge_Order_Log;
insert into STG_OMS.Merge_Order_Log
select 
    merge_order_sys_id,
    case when trim(purchase_order_number) in ('null','') then null else trim(purchase_order_number) end as purchase_order_number,
    case when trim(purchase_parent_order_number) in ('null','') then null else trim(purchase_parent_order_number) end as purchase_parent_order_number,
    create_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,
    update_time,
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by merge_order_sys_id order by dt desc) rownum from ODS_OMS.Merge_Order_Log
) t
where rownum = 1
END


GO
