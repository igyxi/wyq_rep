/****** Object:  StoredProcedure [STG_Order].[Trans_Order_Pay_Hourly]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_Order].[Trans_Order_Pay_Hourly] @dt [varchar](10) AS
BEGIN
truncate table STG_Order.Order_Pay_Hourly;
insert into STG_Order.Order_Pay_Hourly
select 
    case when trim(lower(id)) in ('null', '') then null else trim(id) end as id,
    case when trim(lower(order_id)) in ('null', '') then null else trim(order_id) end as order_id,
    case when trim(lower(order_trade_no)) in ('null', '') then null else trim(order_trade_no) end as order_trade_no,
    case when trim(lower(third_trade_no)) in ('null', '') then null else trim(third_trade_no) end as third_trade_no,
    case when trim(lower(order_paytype)) in ('null', '') then null else trim(order_paytype) end as order_paytype,
    should_pay,
    case when trim(lower(payment_code)) in ('null', '') then null else trim(payment_code) end as payment_code,
    case when trim(lower(bank_code)) in ('null', '') then null else trim(bank_code) end as bank_code,
    pay_status,
    refund_flag,
    is_del,
    case when trim(lower(create_userid)) in ('null', '') then null else trim(create_userid) end as create_userid,
    create_time,
    case when trim(lower(update_userid)) in ('null', '') then null else trim(update_userid) end as update_userid,
    case when trim(lower(user_agent)) in ('null', '') then null else trim(user_agent) end as user_agent,
    update_time,
    case when trim(lower(payment_code_sub)) in ('null', '') then null else trim(payment_code_sub) end as payment_code_sub,
    current_timestamp as insert_timestamp
from 
(
    select *, ROW_NUMBER() over(partition by id order by hour desc) as rownum from ODS_Order.Order_Pay_Hourly where dt =@dt
)t
where t.rownum = 1
delete from ODS_Order.Order_Pay_Hourly where dt <= cast(DATEADD(day,-14,convert(date, @dt)) as VARCHAR);
END
GO
