/****** Object:  StoredProcedure [STG_TMALLHub].[TRANS_TMALL_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_TMALLHub].[TRANS_TMALL_Order] @dt [VARCHAR](10) AS
BEGIN
truncate table STG_TMALLHub.TMALL_Order;
insert into STG_TMALLHub.TMALL_Order
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
    null receiver_address,
    case when trim(receiver_city) in ('null','') then null else trim(receiver_city) end as receiver_city,
    case when trim(receiver_district) in ('null','') then null else trim(receiver_district) end as receiver_district,
    null receiver_mobile,
    case when trim(receiver_name) in ('null','') then null else trim(receiver_name) end as receiver_name,
    null receiver_phone,
    case when trim(receiver_state) in ('null','') then null else trim(receiver_state) end as receiver_state,
    case when trim(receiver_zip) in ('null','') then null else trim(receiver_zip) end as receiver_zip,
    case when trim(type) in ('null','') then null else trim(type) end as type,
    order_tax_fee,	
    is_sync,	
    case when trim(last_sync_status) in ('null','') then null else trim(last_sync_status) end as last_sync_status,	
    case when trim(logistics_number) in ('null','') then null else trim(logistics_number) end as logistics_number,	
    case when trim(logistics_company) in ('null','') then null else trim(logistics_company) end as logistics_company,	
    consign_time,
    case when trim(is_delete) in ('null', '') then null 
         when trim(is_delete) = 'false' then 0 
         when trim(is_delete) = 'true' then 1
    end as is_delete,	
    create_time,
    update_time,
    case when trim(create_user) in ('null','') then null else trim(create_user) end as create_user,		
    case when trim(update_user) in ('null','') then null else trim(update_user) end as update_user,		
    sign_time,	
    end_time,	
    case when trim(member_card_no) in ('null','') then null else trim(member_card_no) end as member_card_no,	
    case when trim(member_card_level) in ('null','') then null else trim(member_card_level) end as member_card_level,	
    jdp_modified,
    case when trim(seller_nick) in ('null','') then null else trim(seller_nick) end as seller_nick,
    is_encrypted,
    current_timestamp as insert_timestamp
from 
    ODS_TMALLHub.TMALL_Order 
where dt = @dt
END


GO
