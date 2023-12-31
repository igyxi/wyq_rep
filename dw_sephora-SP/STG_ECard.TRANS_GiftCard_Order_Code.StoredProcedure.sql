/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Order_Code]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Order_Code] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- 2022-11-16       wangzhichun              update
-- ========================================================================================
truncate table STG_Ecard.GiftCard_Order_Code;
insert into STG_Ecard.GiftCard_Order_Code
select 
    id,
    case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
    case when trim(trans_id) in ('', 'null', 'None') then null else trim(trans_id) end as trans_id,
    case when trim(card_id) in ('', 'null', 'None') then null else trim(card_id) end as card_id,
    case when trim(wechat_order_id) in ('', 'null', 'None') then null else trim(wechat_order_id) end as wechat_order_id,
    case when trim(wechat_code_no) in ('', 'null', 'None') then null else trim(wechat_code_no) end as wechat_code_no,
    case when trim(wechat_card_type) in ('', 'null', 'None') then null else trim(wechat_card_type) end as wechat_card_type,
    case when trim(wechat_card_name) in ('', 'null', 'None') then null else trim(wechat_card_name) end as wechat_card_name,
    case when trim(fuiou_code_no) in ('', 'null', 'None') then null else trim(fuiou_code_no) end as fuiou_code_no,
    case when trim(fuiou_code_pwd) in ('', 'null', 'None') then null else trim(fuiou_code_pwd) end as fuiou_code_pwd,
    goods_id,
    case when trim(goods_name) in ('', 'null', 'None') then null else trim(goods_name) end as goods_name,
    case when trim(goods_image) in ('', 'null', 'None') then null else trim(goods_image) end as goods_image,
    begin_time,
    end_time,
    cover_id,
    case when trim(outer_img_id) in ('', 'null', 'None') then null else trim(outer_img_id) end as outer_img_id,
    price,
    balance,
    case when trim(refund_fee) in ('', 'null', 'None') then null else trim(refund_fee) end as refund_fee,
    case when trim(open_id) in ('', 'null', 'None') then null else trim(open_id) end as open_id,
    case when trim(mi_open_id) in ('', 'null', 'None') then null else trim(mi_open_id) end as mi_open_id,
    case when trim(union_id) in ('', 'null', 'None') then null else trim(union_id) end as union_id,
    case when trim(accepter_openid) in ('', 'null', 'None') then null else trim(accepter_openid) end as accepter_openid,
    case when trim(accepter_unionid) in ('', 'null', 'None') then null else trim(accepter_unionid) end as accepter_unionid,
    card_type,
    has_report,
    case when trim(mchnt_txn_ssn) in ('', 'null', 'None') then null else trim(mchnt_txn_ssn) end as mchnt_txn_ssn,
    order_flag,
	code_status,
	theme_type,
	type,
	status,
    create_time,
    update_time,
    accept_time,
    give_status,
    current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.GiftCard_Order_Code
) t
where rownum = 1
END
GO
