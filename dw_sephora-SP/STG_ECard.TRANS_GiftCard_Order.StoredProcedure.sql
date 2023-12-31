/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Order] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- 2022-11-16       wangzhichun              update
-- ========================================================================================
truncate table STG_Ecard.GiftCard_Order;
insert into STG_Ecard.GiftCard_Order
select 
		id,
		case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
		order_type,
		case when trim(wechat_order_id) in ('', 'null', 'None') then null else trim(wechat_order_id) end as wechat_order_id,
		case when trim(trans_id) in ('', 'null', 'None') then null else trim(trans_id) end as trans_id,
		case when trim(page_id) in ('', 'null', 'None') then null else trim(page_id) end as page_id,
		total_price,
		create_time,
		pay_finish_time,
		case when trim(open_id) in ('', 'null', 'None') then null else trim(open_id) end as open_id,
		case when trim(mi_open_id) in ('', 'null', 'None') then null else trim(mi_open_id) end as mi_open_id,
		case when trim(union_id) in ('', 'null', 'None') then null else trim(union_id) end as union_id,
		case when trim(outer_str) in ('', 'null', 'None') then null else trim(outer_str) end as outer_str,
		quantity,
		receive_quantity,
		order_status,
		case when trim(outer_img_id) in ('', 'null', 'None') then null else trim(outer_img_id) end as outer_img_id,
		order_flag,
		theme_id,
		cover_id,
		card_type,
		status,
		add_time,
		update_time,
		receive_type,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.GiftCard_Order
) t
where rownum = 1
END
GO
