/****** Object:  StoredProcedure [STG_OrderHub].[TRANS_Order_Invoice]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_OrderHub].[TRANS_Order_Invoice] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-10       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_OrderHub.Order_Invoice;
insert into STG_OrderHub.Order_Invoice
select 
		order_invoice_sys_id,
		case when trim(store_code) in ('', 'null', 'None') then null else trim(store_code) end as store_code,
		case when trim(sales_order_id) in ('', 'null', 'None') then null else trim(sales_order_id) end as sales_order_id,
		case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
		case when trim(invoice_no) in ('', 'null', 'None') then null else trim(invoice_no) end as invoice_no,
		case when trim(card_code) in ('', 'null', 'None') then null else trim(card_code) end as card_code,
		amount,
		invoice_amount,
		discount_amount,
		order_pay_time,
		case when trim(transaction_type) in ('', 'null', 'None') then null else trim(transaction_type) end as transaction_type,
		case when trim(channel_id) in ('', 'null', 'None') then null else trim(channel_id) end as channel_id,
		status,
		is_delete,
		create_time,
		update_time,
		case when trim(create_user) in ('', 'null', 'None') then null else trim(create_user) end as create_user,
		case when trim(update_user) in ('', 'null', 'None') then null else trim(update_user) end as update_user,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by order_invoice_sys_id order by dt desc) rownum from ODS_OrderHub.Order_Invoice
) t
where rownum = 1
END

GO
