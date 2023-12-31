/****** Object:  StoredProcedure [STG_SmartBA].[TRANS_T_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_SmartBA].[TRANS_T_Order] AS
BEGIN
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By         Description
-- ----------------------------------------------------------------------------------------
-- 2021-12-31       wangzhichun        Initial Version
-- 2022-06-16       tali               change order_code for unique key
-- ========================================================================================
truncate table STG_SmartBA.T_Order ;
insert into STG_SmartBA.T_Order
select 
    id,
    case when trim(order_code) in ('null','') then null else trim(order_code) end as order_code,
    order_type,
    sale_type,
    case when trim(open_id) in ('null','') then null else trim(open_id) end as open_id,
    case when trim(union_id) in ('null','') then null else trim(union_id) end as union_id,
    should_amount,
    case when trim(member_card) in ('null','') then null else trim(member_card) end as member_card,
    case when trim(card_level) in ('null','') then null else trim(card_level) end as card_level,
    product_amount,
    order_amount,
    user_id,
    null as user_phone,
    receiver_id,
    case when trim(receiver_name) in ('null','') then null else trim(receiver_name) end as receiver_name,
    null as receiver_phone,
    null as receiver_address,
    case when trim(receiver_postcode) in ('null','') then null else trim(receiver_postcode) end as receiver_postcode,
    express_amount,
    reduce_amount,
    coupon_id,
    coupon_amount,
    discount_amount,
    integral,
    integral_amount,
    order_status,
    pay_status,
    pay_type,
    pay_time,
    express_time,
    case when trim(pay_code) in ('null','') then null else trim(pay_code) end as pay_code,
    case when trim(trade_id) in ('null','') then null else trim(trade_id) end as trade_id,
    express_status,
    express_id,
    case when trim(express_code) in ('null','') then null else trim(express_code) end as express_code,
    invoice_id,
    invoice_status,
    case when trim(form_id) in ('null','') then null else trim(form_id) end as form_id,
    emp_id,
    emp_type,
    case when trim(emp_code) in ('null','') then null else trim(emp_code) end as emp_code,
    case when trim(emp_name) in ('null','') then null else trim(emp_name) end as emp_name,
    null as emp_phone,
    seller_id,
    case when trim(remark) in ('null','') then null else trim(remark) end as remark,
    case when trim(oper_remark) in ('null','') then null else trim(oper_remark) end as oper_remark,
    return_status,
    return_amount,
    return_integral,
    null as member_phone,
    finish_time,
    channel,
    sync_status,
    company_id,
    case when trim(company_name) in ('null','') then null else trim(company_name) end as company_name,
    store_id,
    case when trim(store_code) in ('null','') then null else trim(store_code) end as store_code,
    case when trim(store_name) in ('null','') then null else trim(store_name) end as store_name,
    is_take,
    app_type,
    case when trim(take_code) in ('null','') then null else trim(take_code) end as take_code,
    group_status,
    is_deleted,
    tenant_id,
    create_time,
    case when trim(update_at) in ('null','') then null else trim(update_at) end as update_at,
    update_time,
    current_timestamp as insert_timestamp
from 
(
    select *, ROW_NUMBER()over(partition by order_code order by dt desc) rownum from ODS_SmartBA.T_Order
) t
where rownum = 1
END

GO
