/****** Object:  StoredProcedure [STG_ECard].[TRANS_EntityCard_Refund]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_EntityCard_Refund] @dt [varchar](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_Ecard.EntityCard_Refund;
insert into STG_Ecard.EntityCard_Refund
select 
		id,
		case when trim(openid) in ('', 'null', 'None') then null else trim(openid) end as openid,
		case when trim(unionid) in ('', 'null', 'None') then null else trim(unionid) end as unionid,
		case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
		case when trim(username) in ('', 'null', 'None') then null else trim(username) end as username,
		case when trim(phone) in ('', 'null', 'None') then null else trim(phone) end as phone,
		case when trim(nickname) in ('', 'null', 'None') then null else trim(nickname) end as nickname,
		case when trim(headimgurl) in ('', 'null', 'None') then null else trim(headimgurl) end as headimgurl,
		refund_fee,
		case when trim(refund_reason) in ('', 'null', 'None') then null else trim(refund_reason) end as refund_reason,
        invoice_status,
		case when trim(pos_number) in ('', 'null', 'None') then null else trim(pos_number) end as pos_number,
		case when trim(refund_sn) in ('', 'null', 'None') then null else trim(refund_sn) end as refund_sn,
		case when trim(store_sn) in ('', 'null', 'None') then null else trim(store_sn) end as store_sn,
		case when trim(store_staff) in ('', 'null', 'None') then null else trim(store_staff) end as store_staff,
		case when trim(store_name) in ('', 'null', 'None') then null else trim(store_name) end as store_name,
		case when trim(remark) in ('', 'null', 'None') then null else trim(remark) end as remark,
		case when trim(operation_user) in ('', 'null', 'None') then null else trim(operation_user) end as operation_user,
		case when trim(operation_name) in ('', 'null', 'None') then null else trim(operation_name) end as operation_name,
		case when trim(operation_time) in ('', 'null', 'None') then null else trim(operation_time) end as operation_time,
        status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
	ODS_ECard.EntityCard_Refund
where 
	dt=@dt 
END
GO
