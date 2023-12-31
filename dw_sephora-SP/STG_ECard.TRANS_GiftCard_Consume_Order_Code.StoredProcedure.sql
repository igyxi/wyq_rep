/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Consume_Order_Code]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Consume_Order_Code] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-11-01       wangzhichun           Initial Version
-- 2022-11-16       wangzhichun              update
-- ========================================================================================
truncate table STG_ECard.GiftCard_Consume_Order_Code;
insert into STG_ECard.GiftCard_Consume_Order_Code
select 
		id,
		case when trim(consume_order_id) in ('','null') then null else trim(consume_order_id) end as consume_order_id,
		case when trim(consume_sub_order_id) in ('','null') then null else trim(consume_sub_order_id) end as consume_sub_order_id,
		case when trim(code_sn) in ('','null') then null else trim(code_sn) end as code_sn,
		case when trim(verypay_no) in ('','null') then null else trim(verypay_no) end as verypay_no,
		case when trim(wechat_code_no) in ('','null') then null else trim(wechat_code_no) end as wechat_code_no,
		case when trim(channel) in ('','null') then null else trim(channel) end as channel,
		case when trim(store_id) in ('','null') then null else trim(store_id) end as store_id,
		case when trim(store_name) in ('','null') then null else trim(store_name) end as store_name,
		card_fee,
		pay_status,
		create_time,
		update_time,
		flag,
		status,
		has_report,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_ECard.GiftCard_Consume_Order_Code
) t
where rownum = 1
END
GO
