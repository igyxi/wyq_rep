/****** Object:  StoredProcedure [STG_ECard].[TRANS_EntityCard_Order_Code]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_EntityCard_Order_Code] @dt [varchar](10) AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_Ecard.EntityCard_Order_Code;
insert into STG_Ecard.EntityCard_Order_Code
select 
		id,
		case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
		case when trim(card_id) in ('', 'null', 'None') then null else trim(card_id) end as card_id,
		case when trim(card_name) in ('', 'null', 'None') then null else trim(card_name) end as card_name,
		case when trim(code_no) in ('', 'null', 'None') then null else trim(code_no) end as code_no,
		case when trim(code_number) in ('', 'null', 'None') then null else trim(code_number) end as code_number,
		case when trim(openid) in ('', 'null', 'None') then null else trim(openid) end as openid,
		case when trim(mini_openid) in ('', 'null', 'None') then null else trim(mini_openid) end as mini_openid,
		case when trim(accepter_openid) in ('', 'null', 'None') then null else trim(accepter_openid) end as accepter_openid,
		price,
		balance,
        status,
		case when trim(receive_status) in ('', 'null', 'None') then null else trim(receive_status) end as receive_status,
		create_time,
		update_time,
		current_timestamp as insert_timestamp
FROM 
    ODS_Ecard.EntityCard_Order_Code
WHERE
    dt=@dt
END
GO
