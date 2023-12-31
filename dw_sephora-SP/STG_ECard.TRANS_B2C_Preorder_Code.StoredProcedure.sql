/****** Object:  StoredProcedure [STG_ECard].[TRANS_B2C_Preorder_Code]    Script Date: 2023/6/28 11:31:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [STG_ECard].[TRANS_B2C_Preorder_Code] AS
BEGIN 
-- ========================================================================================
-- --------------------------------- Change Log -------------------------------------------
-- Date Generated   Updated By     Description
-- ----------------------------------------------------------------------------------------
-- 2022-10-31       houshuangqiang           Initial Version
-- ========================================================================================
truncate table STG_Ecard.B2C_Preorder_Code;
insert into STG_Ecard.B2C_Preorder_Code
select 
		id,
		case when trim(order_id) in ('', 'null', 'None') then null else trim(order_id) end as order_id,
		case when trim(card_id) in ('', 'null', 'None') then null else trim(card_id) end as card_id,
		case when trim(card_name) in ('', 'null', 'None') then null else trim(card_name) end as card_name,
		card_amount,
		case when trim(code) in ('', 'null', 'None') then null else trim(code) end as code,
		case when trim(code_no) in ('', 'null', 'None') then null else trim(code_no) end as code_no,
		case when trim(code_number) in ('', 'null', 'None') then null else trim(code_number) end as code_number,
		case when trim(fuiou_code_no) in ('', 'null', 'None') then null else trim(fuiou_code_no) end as fuiou_code_no,
		case when trim(fuiou_code_pwd) in ('', 'null', 'None') then null else trim(fuiou_code_pwd) end as fuiou_code_pwd,
		case when trim(openid) in ('', 'null', 'None') then null else trim(openid) end as openid,
        [status],
		create_time,
		update_time,
		current_timestamp as insert_timestamp
from 
(
    select *, row_number() over(partition by id order by dt desc) rownum from ODS_Ecard.B2C_Preorder_Code
) t
where rownum = 1
END
GO
