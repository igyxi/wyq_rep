/****** Object:  StoredProcedure [STG_OrderHub].[TRANS_Store_Order_Statistics]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[TRANS_Store_Order_Statistics] AS
BEGIN
truncate table STG_OrderHub.Store_Order_Statistics;
insert into STG_OrderHub.Store_Order_Statistics
select 
    order_statistics_id,
    case when trim(lower(store_code)) in ('null','') then null else trim(store_code) end as store_code,
    sales_amount,
    sales_order_number,
    refund_amount,
    refund_number,
    case when trim(lower(channel_id)) in ('null','') then null else trim(channel_id) end as channel_id,
    is_delete,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    create_time,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    update_time,
    original_sales_amount,
    synt_time,
    synt_flag,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by order_statistics_id order by dt desc) rownum from ODS_OrderHub.Store_Order_Statistics
) t
where rownum = 1
END


GO
