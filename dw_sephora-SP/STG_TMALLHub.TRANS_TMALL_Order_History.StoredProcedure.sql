/****** Object:  StoredProcedure [STG_TMALLHub].[TRANS_TMALL_Order_History]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TMALLHub].[TRANS_TMALL_Order_History] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_TMALLHub.TMALL_Order_History;
insert into STG_TMALLHub.TMALL_Order_History
select 
    id,	
    case when trim(order_id) in ('null','') then null else trim(order_id) end as order_id,
    case when trim(oaid) in ('null','') then null else trim(oaid) end as oaid,    
    discount_fee,
    case when trim(buyer_nick) in ('null','') then null else trim(buyer_nick) end as buyer_nick,
    created,
    case when trim(status) in ('null','') then null else trim(status) end as status,
    pay_time,
    case when trim(buyer_memo) in ('null','') then null else trim(buyer_memo) end as buyer_memo,
    case when trim(buyer_message) in ('null','') then null else trim(buyer_message) end as buyer_message,
    payment,
    post_fee,
    null as receiver_address,
    case when trim(receiver_city) in ('null','') then null else trim(receiver_city) end as receiver_city,
    case when trim(receiver_district) in ('null','') then null else trim(receiver_district) end as receiver_district,
    null as receiver_mobile,
    case when trim(receiver_name) in ('null','') then null else trim(receiver_name) end as receiver_name,
    null as receiver_phone,
    case when trim(receiver_state) in ('null','') then null else trim(receiver_state) end as receiver_state,
    case when trim(receiver_zip) in ('null','') then null else trim(receiver_zip) end as receiver_zip,
    case when trim(type) in ('null','') then null else trim(type) end as type,
    order_tax_fee,
    is_sync,
    consign_time,
    create_time,
    update_time,
    sign_time,
    end_time,
    push_times,
    case when trim(seller_nick) in ('null','') then null else trim(seller_nick) end as seller_nick,
    is_encrypted,
    current_timestamp as insert_timestamp
from 
    ODS_TMALLHub.TMALL_Order_History
where dt = @dt
END


GO
