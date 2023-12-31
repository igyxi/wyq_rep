/****** Object:  StoredProcedure [STG_OMS].[TRANS_OMS_OMS_to_OIMS_Sync_Fail_Log]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_OMS_OMS_to_OIMS_Sync_Fail_Log] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-05-10       zeyuan        Initial Version
-- ========================================================================================
truncate table STG_OMS.oms_to_oims_sync_fail_log;
insert into STG_OMS.oms_to_oims_sync_fail_log
select 
    oms_to_oims_sync_fail_log_sys_id,
    case when trim(sales_order_number) in ('null','') then null else trim(sales_order_number) end as sales_order_number,
    order_time,
    type,
    try_count,
    sync_status,
    create_time,
    update_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by oms_to_oims_sync_fail_log_sys_id order by dt desc) rownum from ODS_OMS.oms_to_oims_sync_fail_log
) t
where rownum = 1
END


GO
