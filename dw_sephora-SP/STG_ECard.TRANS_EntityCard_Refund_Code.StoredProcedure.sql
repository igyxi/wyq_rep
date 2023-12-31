/****** Object:  StoredProcedure [STG_ECard].[TRANS_EntityCard_Refund_Code]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_EntityCard_Refund_Code] @dt [varchar](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_Ecard.EntityCard_Refund_Code;
insert into STG_Ecard.EntityCard_Refund_Code
select 
		id,
		refund_id,
		case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
		case when trim(card_id) in ('', 'null', 'None') then null else trim(card_id) end as card_id,
		case when trim(code_no) in ('', 'null', 'None') then null else trim(code_no) end as code_no,
		case when trim(code_number) in ('', 'null', 'None') then null else trim(code_number) end as code_number,
		case when trim(openid) in ('', 'null', 'None') then null else trim(openid) end as openid,
		case when trim(unionid) in ('', 'null', 'None') then null else trim(unionid) end as unionid,
		case when trim(accepter_openid) in ('', 'null', 'None') then null else trim(accepter_openid) end as accepter_openid,
		case when trim(accepter_unionid) in ('', 'null', 'None') then null else trim(accepter_unionid) end as accepter_unionid,
		refund_fee,
        prepaid_status,
        wechat_status,
		case when trim(card_status) in ('', 'null', 'None') then null else trim(card_status) end as card_status,
		status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
	ODS_ECard.EntityCard_Refund_Code
where 
	dt=@dt 
END
GO
