/****** Object:  StoredProcedure [STG_OMS].[TRANS_Online_Stkin_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Online_Stkin_Order] AS
BEGIN
truncate table STG_OMS.Online_Stkin_Order ;
insert into STG_OMS.Online_Stkin_Order
select 
    online_stkin_order_sys_id,
    case when trim(lower(sales_order_number)) in ('null','') then null else trim(sales_order_number) end as sales_order_number,
    case when trim(lower(logistics_number)) in ('null','') then null else trim(logistics_number) end as logistics_number,
    case when trim(lower(logistics_company)) in ('null','') then null else trim(logistics_company) end as logistics_company,
    null as mobile,
    return_sku_quantity,
    return_sku_packages,
    apply_logistics_fee,
    case when trim(lower(stkin_order_number)) in ('null','') then null else trim(stkin_order_number) end as stkin_order_number,
    case when trim(lower(process_status)) in ('null','') then null else trim(process_status) end as process_status,
    case when trim(lower(basic_status)) in ('null','') then null else trim(basic_status) end as basic_status,
    post_fee,
    stkin_invoice_flag,
    case when trim(lower(partial_stkin_reason)) in ('null','') then null else trim(partial_stkin_reason) end as partial_stkin_reason,
    case when trim(lower(comment)) in ('null','') then null else trim(comment) end as comment,
    stkin_type,
    case when trim(lower(create_op)) in ('null','') then null else trim(create_op) end as create_op,
    case when trim(lower(update_op)) in ('null','') then null else trim(update_op) end as update_op,
    create_time,
    update_time,
    online_return_apply_order_sys_id,
    super_order_id,
    case when trim(lower(return_exchange_type)) in ('null','') then null else trim(return_exchange_type) end as return_exchange_type,
    logistics_post_back_time,
    case when trim(lower(stkin_exception_type)) in ('null','') then null else trim(stkin_exception_type) end as stkin_exception_type,
    case when trim(lower(stkin_exception_refund_type)) in ('null','') then null else trim(stkin_exception_refund_type) end as stkin_exception_refund_type,
    resend_flag,
    case when trim(lower(purchase_order_numbers)) in ('null','') then null else trim(purchase_order_numbers) end as purchase_order_numbers,
    case when trim(lower(order_ware_house)) in ('null','') then null else trim(order_ware_house) end as order_ware_house,
    virtual_stkin_flag,
    case when trim(lower(stkin_trouble)) in ('null','') then null else trim(stkin_trouble) end as stkin_trouble,
    case when trim(lower(store_id)) in ('null','') then null else trim(store_id) end as store_id,
    case when trim(lower(channel_id)) in ('null','') then null else trim(channel_id) end as channel_id,
    logistics_sign_time,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by online_stkin_order_sys_id order by dt desc) rownum from ODS_OMS.Online_Stkin_Order
) t
where rownum = 1
END


GO
