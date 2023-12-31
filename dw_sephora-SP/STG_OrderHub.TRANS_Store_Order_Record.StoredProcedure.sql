/****** Object:  StoredProcedure [STG_OrderHub].[TRANS_Store_Order_Record]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[TRANS_Store_Order_Record] AS
BEGIN
truncate table STG_OrderHub.Store_Order_Record;
insert into STG_OrderHub.Store_Order_Record
select 
    store_order_record_id,
    case when trim(lower(store_code)) in ('null','') then null else trim(store_code) end as store_code,
    case when trim(lower(order_id)) in ('null','') then null else trim(order_id) end as order_id,
    case when trim(lower(type)) in ('null','') then null else trim(type) end as type,
    case when trim(lower(channel_id)) in ('null','') then null else trim(channel_id) end as channel_id,
    is_delete,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    create_time,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    update_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by store_order_record_id order by dt desc) rownum from ODS_OrderHub.Store_Order_Record
) t
where rownum = 1
END


GO
