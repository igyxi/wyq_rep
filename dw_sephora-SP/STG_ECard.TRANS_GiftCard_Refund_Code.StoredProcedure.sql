/****** Object:  StoredProcedure [STG_ECard].[TRANS_GiftCard_Refund_Code]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_GiftCard_Refund_Code] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- 2022-11-16       wangzhichun              update
-- ========================================================================================
truncate table STG_Ecard.GiftCard_Refund_Code;
insert into STG_Ecard.GiftCard_Refund_Code
select 
		id,
		refund_id,
		case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
		case when trim(code_no) in ('', 'null', 'None') then null else trim(code_no) end as code_no,
		case when trim(open_id) in ('', 'null', 'None') then null else trim(open_id) end as open_id,
		case when trim(mi_open_id) in ('', 'null', 'None') then null else trim(mi_open_id) end as mi_open_id,
		case when trim(accepter_openid) in ('', 'null', 'None') then null else trim(accepter_openid) end as accepter_openid,
		case when trim(accepter_unionid) in ('', 'null', 'None') then null else trim(accepter_unionid) end as accepter_unionid,
		refund_fee,
		status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.GiftCard_Refund_Code
) t
where rownum = 1
END
GO
