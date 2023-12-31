/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Consume_Refund]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Consume_Refund] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- 2022-11-16       wangzhichun              update
-- ========================================================================================
truncate table STG_Ecard.GiftCard_Consume_Refund;
insert into STG_Ecard.GiftCard_Consume_Refund
select 
		id,
		case when trim(sub_order_id) in ('', 'null', 'None') then null else trim(sub_order_id) end as sub_order_id,
		case when trim(sub_refund_id) in ('', 'null', 'None') then null else trim(sub_refund_id) end as sub_refund_id,
		case when trim(refund_out_sns) in ('', 'null', 'None') then null else trim(refund_out_sns) end as refund_out_sns,
		status,
		create_time,
		update_time,
		flag,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.GiftCard_Consume_Refund
) t
where rownum = 1
END
GO
