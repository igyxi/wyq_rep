/****** Object:  StoredProcedure [STG_OrderHub].[TRANS_Refund_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[TRANS_Refund_Order] AS
BEGIN
truncate table STG_OrderHub.Refund_Order;
insert into STG_OrderHub.Refund_Order
select 
    refund_order_sys_id,
    case when trim(lower(sales_order_id)) in ('null','') then null else trim(sales_order_id) end as sales_order_id,
    case when trim(lower(refund_id)) in ('null','') then null else trim(refund_id) end as refund_id,
    case when trim(lower(refund_order_id)) in ('null','') then null else trim(refund_order_id) end as refund_order_id,
    refund_time,
    case when trim(lower(refund_reason)) in ('null','') then null else trim(refund_reason) end as refund_reason,
    res_type,
    case when trim(lower(notify_type)) in ('null','') then null else trim(notify_type) end as notify_type,
    audit_time,
    case when trim(lower(audit_result)) in ('null','') then null else trim(audit_result) end as audit_result,
    refund_amount,
    case when trim(lower(refund_type)) in ('null','') then null else trim(refund_type) end as refund_type,
    event_type,
	approve_type,
	case when trim(lower(apply_deal)) in ('null','') then null else trim(apply_deal) end as apply_deal,
	duty_assume,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    is_delete,
    status,
    case when trim(lower(channel_id)) in ('null','') then null else trim(channel_id) end as channel_id,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by refund_order_sys_id order by dt desc) rownum from ODS_OrderHub.Refund_Order
) t
where rownum = 1
END


GO
