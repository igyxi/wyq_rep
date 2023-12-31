/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Consume_Refund_Batch]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Consume_Refund_Batch] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- 2022-11-16       wangzhichun              update
-- ========================================================================================
truncate table STG_Ecard.GiftCard_Consume_Refund_Batch;
insert into STG_Ecard.GiftCard_Consume_Refund_Batch
select 
		id,
		case when trim(sub_order_id) in ('', 'null', 'None') then null else trim(sub_order_id) end as sub_order_id,
		case when trim(sub_refund_id) in ('', 'null', 'None') then null else trim(sub_refund_id) end as sub_refund_id,
		case when trim(refund_out_sn) in ('', 'null', 'None') then null else trim(refund_out_sn) end as refund_out_sn,
		case when trim(code_sn) in ('', 'null', 'None') then null else trim(code_sn) end as code_sn,
		case when trim(wechat_code_no) in ('', 'null', 'None') then null else trim(wechat_code_no) end as wechat_code_no,
		refund_fee,
		flag,
		code_status,
		has_report,
		case when trim(store_id) in ('', 'null', 'None') then null else trim(store_id) end as store_id,
		case when trim(store_name) in ('', 'null', 'None') then null else trim(store_name) end as store_name,
		case when trim(channel) in ('', 'null', 'None') then null else trim(channel) end as channel,
		status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.GiftCard_Consume_Refund_Batch
) t
where rownum = 1
END
GO
