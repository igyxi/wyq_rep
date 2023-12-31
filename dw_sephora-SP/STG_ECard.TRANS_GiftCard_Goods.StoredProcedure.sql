/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Goods]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Goods] @dt [varchar](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- 2022-11-16       wangzhichun              update
-- ========================================================================================
truncate table STG_Ecard.GiftCard_Goods;
insert into STG_Ecard.GiftCard_Goods
select 
		id,
		case when trim(card_id) in ('', 'null', 'None') then null else trim(card_id) end as card_id,
		case when trim(card_code_type) in ('', 'null', 'None') then null else trim(card_code_type) end as card_code_type,
        goods_type,
        goods_second_type,
		case when trim(goods_name) in ('', 'null', 'None') then null else trim(goods_name) end as goods_name,
		price,
		safety_stock,
		max_stock,
        expire_type,
		case when trim(expire_time) in ('', 'null', 'None') then null else trim(expire_time) end as expire_time,
		start_time,
		end_time,
		case when trim(image) in ('', 'null', 'None') then null else trim(image) end as image,
		case when trim(cdn_image) in ('', 'null', 'None') then null else trim(cdn_image) end as cdn_image,
		case when trim(notice) in ('', 'null', 'None') then null else trim(notice) end as notice,
		case when trim(logo) in ('', 'null', 'None') then null else trim(logo) end as logo,
		case when trim(cdn_logo) in ('', 'null', 'None') then null else trim(cdn_logo) end as cdn_logo,
		case when trim(background_color) in ('', 'null', 'None') then null else trim(background_color) end as background_color,
		case when trim(apply_url) in ('', 'null', 'None') then null else trim(apply_url) end as apply_url,
		case when trim(sap_code) in ('', 'null', 'None') then null else trim(sap_code) end as sap_code,
		case when trim(button_name) in ('', 'null', 'None') then null else trim(button_name) end as button_name,
        status,
		cover_id,
		ticket_id,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
	ODS_Ecard.GiftCard_Goods
where 
	dt=@dt 
END
GO
