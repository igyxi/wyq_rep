/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Equity_Card_Order_Code]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Equity_Card_Order_Code] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2023-01-11       litao           Initial Version
-- ========================================================================================
truncate table STG_ECard.GiftCard_Equity_Card_Order_Code;
insert into STG_ECard.GiftCard_Equity_Card_Order_Code
select 
		id,
		case when trim(order_id) in ('','null','None') then null else trim(order_id) end as order_id,
		case when trim(trans_id) in ('','null','None') then null else trim(trans_id) end as trans_id,
		case when trim(wechat_order_id) in ('','null','None') then null else trim(wechat_order_id) end as wechat_order_id,
		goods_id,
		case when trim(goods_name) in ('','null','None') then null else trim(goods_name) end as goods_name,
		case when trim(goods_image) in ('','null','None') then null else trim(goods_image) end as goods_image,
		cover_id,
		case when trim(outer_img_id) in ('','null','None') then null else trim(outer_img_id) end as outer_img_id,
		quantity,
		price,
		refund_fee,
		order_flag,
		status,
		card_status,
		card_status_one,
		card_status_two,
		card_status_three,
		point_status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_ECard.GiftCard_Equity_Card_Order_Code
) t
where rownum = 1 
END

GO
