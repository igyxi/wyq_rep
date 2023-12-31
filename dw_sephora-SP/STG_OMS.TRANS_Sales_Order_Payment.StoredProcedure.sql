/****** Object:  StoredProcedure [STG_OMS].[TRANS_Sales_Order_Payment]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OMS].[TRANS_Sales_Order_Payment] AS
BEGIN
truncate table STG_OMS.Sales_Order_Payment ;
insert into STG_OMS.Sales_Order_Payment
select 
    sales_order_payment_sys_id,
    sales_order_sys_id,
    case when trim(lower(r_oms_order_sys_id)) in ('null','') then null else trim(r_oms_order_sys_id) end as r_oms_order_sys_id,
    payment_amoutn,
    case when trim(lower(payment_method)) in ('null','') then null else trim(payment_method) end as payment_method,
    case when trim(lower(payment_status)) in ('null','') then null else trim(payment_status) end as payment_status,
    payment_time,
    case when trim(lower(payment_comment)) in ('null','') then null else trim(payment_comment) end as payment_comment,
    case when trim(lower(payment_serial_id)) in ('null','') then null else trim(payment_serial_id) end as payment_serial_id,
    create_time,
    case when trim(lower(create_op)) in ('null','') then null else trim(create_op) end as create_op,
    update_time,
    case when trim(lower(update_op)) in ('null','') then null else trim(update_op) end as update_op,
    case when trim(lower(payment_no)) in ('null','') then null else trim(payment_no) end as payment_no,
    case when trim(lower(payment_code)) in ('null','') then null else trim(payment_code) end as payment_code,
    case when trim(lower(payment_type)) in ('null','') then null else trim(payment_type) end as payment_type,
    case when trim(lower(bank_type_code)) in ('null','') then null else trim(bank_type_code) end as bank_type_code,
    case when trim(lower(bank_type_name)) in ('null','') then null else trim(bank_type_name) end as bank_type_name,
    is_delete,
    current_timestamp as insert_timestamp
from 
(
    select *,row_number() over(partition by sales_order_sys_id, sales_order_payment_sys_id order by dt desc) rownum from ODS_OMS.Sales_Order_Payment 
)t
where rownum = 1
END


GO
