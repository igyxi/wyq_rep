/****** Object:  StoredProcedure [STG_OrderCenter].[TRANS_Offline_Orders]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderCenter].[TRANS_Offline_Orders] AS
BEGIN
truncate table STG_OrderCenter.Offline_Orders;
insert into STG_OrderCenter.Offline_Orders
select 
    id,
    case when trim(lower(card_no)) in ('null','') then null else trim(card_no) end as card_no,
    case when trim(lower(store_code)) in ('null','') then null else trim(store_code) end as store_code,
    case when trim(lower(store_name)) in ('null','') then null else trim(store_name) end as store_name,
    case when trim(lower(ticket_number)) in ('null','') then null else trim(ticket_number) end as ticket_number,
    purchase_time,
    total_quantity,
    total_amount,
    discount_amount,
    actual_amount,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_OrderCenter.Offline_Orders
) t
where rownum = 1
END


GO
