/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Equity_Card_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Equity_Card_Order] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       litao           Initial Version
-- ========================================================================================
truncate table STG_ECard.GiftCard_Equity_Card_Order;
insert into STG_ECard.GiftCard_Equity_Card_Order
select 
		id,
		case when trim(order_id) in ('','null','None') then null else trim(order_id) end as order_id,
		order_type,
		case when trim(wechat_order_id) in ('','null','None') then null else trim(wechat_order_id) end as wechat_order_id,
		case when trim(prepay_id) in ('','null','None') then null else trim(prepay_id) end as prepay_id,
		case when trim(page_id) in ('','null','None') then null else trim(page_id) end as page_id,
		total_price,
		pay_finish_time,
		case when trim(open_id) in ('','null','None') then null else trim(open_id) end as open_id,
		case when trim(mi_open_id) in ('','null','None') then null else trim(mi_open_id) end as mi_open_id,
		case when trim(union_id) in ('','null','None') then null else trim(union_id) end as union_id,
		case when trim(outer_str) in ('','null','None') then null else trim(outer_str) end as outer_str,
		quantity,
		cover_id,
		case when trim(outer_img_id) in ('','null','None') then null else trim(outer_img_id) end as outer_img_id,
		order_flag,
		theme_id,
		case when trim(scene) in ('','null','None') then null else trim(scene) end as scene,
		case when trim(trans_id) in ('','null','None') then null else trim(trans_id) end as trans_id,
		status,
		card_status,
		card_status_one,
		card_status_two,
		card_status_three,
		create_time,
		update_time,
		case when trim(member_id) in ('','null','None') then null else trim(member_id) end as member_id,
		point_status,
		case when trim(crm_transaction_id) in ('','null','None') then null else trim(crm_transaction_id) end as crm_transaction_id,
		case when trim(exchange_code) in ('','null','None') then null else trim(exchange_code) end as exchange_code,
		case when trim(batch_no) in ('','null','None') then null else trim(batch_no) end as batch_no,
		origin_price,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_ECard.GiftCard_Equity_Card_Order
) t
where rownum = 1
END

GO
