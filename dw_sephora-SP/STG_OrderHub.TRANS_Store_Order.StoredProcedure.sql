/****** Object:  StoredProcedure [STG_OrderHub].[TRANS_Store_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[TRANS_Store_Order] AS
BEGIN
truncate table STG_OrderHub.Store_Order;
insert into STG_OrderHub.Store_Order
select 
    store_order_sys_id,
    case when trim(lower(order_id)) in ('null','') then null else trim(order_id) end as order_id,
    case when trim(lower(app_poi_code)) in ('null','') then null else trim(app_poi_code) end as app_poi_code,
    total_amount,
    logistics_status,
    order_pay_time,
    logistics_completed_time,
    order_status,
    s_order_status,
    commission,
    delivery_fee,
    case when trim(lower(store_code)) in ('null','') then null else trim(store_code) end as store_code,
    case when trim(lower(card_code)) in ('null','') then null else trim(card_code) end as card_code,
    original_price,
    case when trim(lower(invoice_no)) in ('null','') then null else trim(invoice_no) end as invoice_no,
    day_seq,
    case when trim(lower(customer_remark)) in ('null','') then null else trim(customer_remark) end as customer_remark,
    case when trim(lower(sales_order_id)) in ('null','') then null else trim(sales_order_id) end as sales_order_id,
    case when trim(lower(related_order_id)) in ('null','') then null else trim(related_order_id) end as related_order_id,
    case when trim(lower(refund_order_id)) in ('null','') then null else trim(refund_order_id) end as refund_order_id,
    case when trim(lower(refund_type)) in ('null','') then null else trim(refund_type) end as refund_type,
    case when trim(lower(derived_type)) in ('null','') then null else trim(derived_type) end as derived_type,
    lack_stock_tag,
    pick_time,
    goods_original_total,
    goods_paid_total,
    goods_adjustment_total,
    case when trim(lower(channel_id)) in ('null','') then null else trim(channel_id) end as channel_id,
    is_delete,
    create_time,
    update_time,
    case when trim(lower(create_user)) in ('null','') then null else trim(create_user) end as create_user,
    case when trim(lower(update_user)) in ('null','') then null else trim(update_user) end as update_user,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by store_order_sys_id order by dt desc) rownum from ODS_OrderHub.Store_Order
) t
where rownum = 1
END


GO
