/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Consume_Order]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Consume_Order] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- 2022-11-16       wangzhichun              update
-- ========================================================================================
truncate table STG_Ecard.GiftCard_Consume_Order;
insert into STG_Ecard.GiftCard_Consume_Order
select 
		id,
		case when trim(consume_order_id) in ('', 'null', 'None') then null else trim(consume_order_id) end as consume_order_id,
		case when trim(consume_sub_order_id) in ('', 'null', 'None') then null else trim(consume_sub_order_id) end as consume_sub_order_id,
		case when trim(paynos) in ('', 'null', 'None') then null else trim(paynos) end as paynos,
		case when trim(channel) in ('', 'null', 'None') then null else trim(channel) end as channel,
		pay_total_amount,
        pay_status,
		create_time,
		update_time,
        flag,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.GiftCard_Consume_Order
) t
where rownum = 1
END
GO
